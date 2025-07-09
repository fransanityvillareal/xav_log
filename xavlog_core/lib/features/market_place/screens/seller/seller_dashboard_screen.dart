import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_core/features/login/authentication_service.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import '../../providers/product_provider.dart';
import 'seller_product_create_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Seller Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final currentUserEmail =
              AuthenticationService().getCurrentUser?.email;
          final sellerProducts = productProvider.products
              .where((product) => product.sellerEmail == currentUserEmail)
              .toList();

          final estimatedEarnings = sellerProducts.fold<double>(
              0, (sum, product) => sum + product.price);

          return Column(
            children: [
              // Products Management Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: Colors.white, // Explicit white background
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Simplify your selling experience! Add your items to the marketplace and connect with buyers quickly and securely.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_business,
                              color: Colors.white),
                          label: const Text(
                            'Add New Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SellerProductCreateScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Total Products Card
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.inventory_2,
                        title: 'Total Products',
                        value: sellerProducts.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Estimated Earnings Card
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.attach_money,
                        title: 'Estimated Earnings',
                        value: currencyFormatter.format(estimatedEarnings),
                      ),
                    ),
                  ],
                ),
              ),

              // Products List Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Text(
                      '${sellerProducts.length} item(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Products List
              Expanded(
                child: sellerProducts.isEmpty
                    ? _buildEmptyState(context) // Pass context here
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: sellerProducts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = sellerProducts[index];
                          return _buildProductCard(
                              context, product, currencyFormatter);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.white, // Explicit white background
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF1E3A8A)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Product product, NumberFormat currencyFormatter) {
    return Card(
      color: Colors.white, // Explicit white background
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: product.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // White background
                    title: const Text('Delete Product'),
                    content: const Text(
                        'Are you sure you want to delete this product?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    // Remove from database
                    await Provider.of<ProductProvider>(context, listen: false)
                        .deleteProductByImageUrl(product.image);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete product: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      // White background container
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_mall_directory_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'You haven\'t added any products yet. Start by adding your first product to sell.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add First Product'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellerProductCreateScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
