import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import 'seller_product_create_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final sellerProducts = productProvider.products;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SellerProductCreateScreen(),
                        ));
                  },
                ),
              ),
              Expanded(
                child: sellerProducts.isEmpty
                    ? const Center(child: Text('No products yet.'))
                    : ListView.builder(
                        itemCount: sellerProducts.length,
                        itemBuilder: (context, index) {
                          final product = sellerProducts[index];
                          return ListTile(
                            leading: product.image.isNotEmpty
                                ? Image.asset(product.image,
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.image_not_supported),
                            title: Text(product.title),
                            subtitle: Text(product.description),
                            trailing: Text('₱${product.price}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
