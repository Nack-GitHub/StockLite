import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header & Search
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'OVERVIEW',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF50606D),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product Catalog',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search SKU, name, or category...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    fillColor: const Color(0xFFE1E3E4).withOpacity(0.5),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ]),
            ),
          ),

          // StreamBuilder for Products
          StreamBuilder<List<Product>>(
            stream: dbService.products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final products = snapshot.data ?? [];
              final lowStockCount = products.where((p) => p.stock < 10).length;

              return SliverMainAxisGroup(
                slivers: [
                  // Stats Pills
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildStatPill(context, 'All Items', '${products.length}', true),
                          _buildStatPill(context, 'Low Stock', '$lowStockCount', false, const Color(0xFFFFB871)),
                          _buildStatPill(context, 'In Transit', '5', false, const Color(0xFFD1E2F1)),
                        ],
                      ),
                    ),
                  ),

                  // Product Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < products.length) {
                            return _buildProductCard(context, products[index], index);
                          } else if (index == products.length) {
                            return _buildAddPlaceholder(context);
                          }
                          return null;
                        },
                        childCount: products.length + 1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ).animate().scale(delay: 1.seconds),
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
              child: _buildNavItem(context, Icons.grid_view, 'Home', true),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/add_product'),
              child: _buildNavItem(context, Icons.add_circle_outline, 'Add', false),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: _buildNavItem(context, Icons.person_outline, 'Profile', false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(BuildContext context, String label, String count, bool active, [Color? color]) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: active ? Theme.of(context).primaryColor : (color ?? const Color(0xFFEDEEEF)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : const Color(0xFF191C1D),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 10,
                color: active ? Colors.white : const Color(0xFF191C1D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, int index) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/product_detail',
        arguments: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: product.imageUrl.startsWith('http')
                        ? NetworkImage(product.imageUrl)
                        : const NetworkImage('https://images.unsplash.com/photo-1553413077-190dd305871c?auto=format&fit=crop&q=80&w=400') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF50606D),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.more_vert, size: 18, color: Color(0xFF70787E)),
                      ],
                    ),
                  Text(
                    'SKU: ${product.sku}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF50606D)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT STOCK',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF70787E)),
                          ),
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: product.stock < 10 ? Colors.red : Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.stock == 0 
                            ? const Color(0xFFE1E3E4) 
                            : product.stock < 10 
                              ? const Color(0xFFFFDAD6) 
                              : const Color(0xFFD1E2F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.status.toUpperCase(),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildAddPlaceholder(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/add_product'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC0C7CE), width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 40, color: const Color(0xFF70787E)),
            const SizedBox(height: 8),
            const Text(
              'Add Product',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF70787E)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
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
