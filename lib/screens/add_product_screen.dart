import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../widgets/stock_lite_button.dart';
import '../widgets/stock_lite_input.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Electronics';
  int _initialStock = 10;
  bool _isLoading = false;

  final List<String> _categories = ['Electronics', 'Office Supplies', 'Furniture', 'Apparel', 'Other'];

  void _incrementStock() => setState(() => _initialStock++);
  void _decrementStock() {
    if (_initialStock > 0) setState(() => _initialStock--);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final dbService = Provider.of<DatabaseService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: '', // Firestore will generate this
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        category: _selectedCategory,
        stock: _initialStock,
        status: _initialStock == 0 ? 'Out of Stock' : (_initialStock < 10 ? 'Low Stock' : 'In Stock'),
        imageUrl: '', // Default empty for now
      );
      await dbService.addProduct(product);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NEW DISPATCH', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text('Add Product', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Register a new item into the precision system.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 48),

                _buildLabel('Product Designation'),
                StockLiteInput(
                  label: '',
                  hintText: 'e.g. Precision Lathe V3',
                  prefixIcon: Icons.inventory_2_outlined,
                  controller: _nameController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter a product name' : null,
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('SKU / ID'),
                          StockLiteInput(
                            label: '',
                            hintText: 'SL-001',
                            prefixIcon: Icons.tag,
                            controller: _skuController,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Category'),
                          _buildDropdown(_categories),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildLabel('Initial Stock Level'),
                Row(
                  children: [
                    Text(
                      '$_initialStock',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF191C1D)),
                    ).animate(target: _initialStock.toDouble()).shimmer(),
                    const Spacer(),
                    const Text('UNITS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF50606D))),
                    const SizedBox(width: 16),
                    _buildCounterButton(Icons.remove, _decrementStock),
                    const SizedBox(width: 8),
                    _buildCounterButton(Icons.add, _incrementStock),
                  ],
                ),
                
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : StockLiteButton(
                        text: 'Add Product to Inventory',
                        onPressed: _handleSubmit,
                        icon: Icons.add_circle,
                      ),
                const SizedBox(height: 32),

                // Preview Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PREVIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF00425E))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDCBE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('REAL-TIME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.image_outlined, color: Color(0xFFC0C7CE), size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ListenableBuilder(
                              listenable: _nameController,
                              builder: (context, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nameController.text.isEmpty ? 'Product Title' : _nameController.text,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00425E)),
                                    ),
                                    Text(_selectedCategory, style: const TextStyle(fontSize: 12, color: Color(0xFF50606D))),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
              child: _buildNavItem(context, Icons.grid_view, 'Home', false),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/add_product'),
              child: _buildNavItem(context, Icons.add_circle, 'Add', true),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
              child: _buildNavItem(context, Icons.person_outline, 'Profile', false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF00425E),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEEEF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF00425E), size: 20),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD1E2F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Theme.of(context).primaryColor : const Color(0xFF70787E)),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: active ? Theme.of(context).primaryColor : const Color(0xFF70787E),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
