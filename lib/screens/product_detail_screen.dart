import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _localStock;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _localStock = widget.product.stock;
  }

  Future<void> _updateStock(int newStock) async {
    if (newStock < 0) return;
    
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    setState(() {
      _localStock = newStock;
      _isLoading = true;
    });

    try {
      await dbService.updateProductStock(widget.product.id, newStock);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stock: $e'), backgroundColor: Colors.red),
        );
        setState(() => _localStock = widget.product.stock);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to remove this product from inventory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      try {
        await dbService.deleteProduct(widget.product.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // TopAppBar
              SliverAppBar(
                leadingWidth: 70,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        onPressed: () => Navigator.pop(context),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _deleteProduct,
                  ),
                  const SizedBox(width: 8),
                ],
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.product.imageUrl.startsWith('http')
                            ? widget.product.imageUrl
                            : 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&q=80&w=400',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Info section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SKU: ${widget.product.sku}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF191C1D),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1E2F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00425E),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE1E3E4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(color: Color(0xFF40484E), fontWeight: FontWeight.w500),
                            ),
                            _buildStatusBadge(
                              _localStock == 0 ? 'OUT OF STOCK' : (_localStock < 10 ? 'LOW STOCK' : 'IN STOCK'),
                              _localStock == 0 
                                ? const Color(0xFFE1E3E4) 
                                : (_localStock < 10 ? const Color(0xFFFFDAD6) : const Color(0xFFD1E2F1)),
                              const Color(0xFF191C1D),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 32),

                      // Stock Management Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'CURRENT STOCK LEVEL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Color(0xFF70787E),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStockButton(Icons.remove, false, () => _updateStock(_localStock - 1)),
                                const SizedBox(width: 32),
                                Column(
                                  children: [
                                    if (_isLoading)
                                      const SizedBox(height: 64, width: 64, child: Center(child: CircularProgressIndicator()))
                                    else
                                      Text(
                                        '$_localStock',
                                        style: TextStyle(
                                          fontSize: 64,
                                          fontWeight: FontWeight.w900,
                                          color: Theme.of(context).primaryColor,
                                          height: 1,
                                        ),
                                      ),
                                    const Text(
                                      'Units in Inventory',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF50606D)),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 32),
                                _buildStockButton(Icons.add, true, () => _updateStock(_localStock + 1)),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockButton(IconData icon, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF00425E) : const Color(0xFFEDEEEF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: const Color(0xFF00425E).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: primary ? Colors.white : const Color(0xFF00425E),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
