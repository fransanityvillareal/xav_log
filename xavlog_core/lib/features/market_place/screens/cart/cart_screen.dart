import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_core/features/market_place/screens/buy/buy_page.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white, // Set white background
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return cartProvider.cartItems.isEmpty
                ? Center(
                    child: Text(
                      'Your Cart is Empty',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  )
                : ListView.builder(
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final product = cartProvider.cartItems[index];
                      return ListTile(
                        leading: product.image.isNotEmpty
                            ? Image.network(
                                product.image,
                                width: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                              )
                            : const Icon(Icons.image_not_supported, size: 50),
                        title: Text(product.title),
                        subtitle: Text('PHP ${product.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () {
                            cartProvider.removeFromCart(product);
                          },
                        ),
                      );
                    },
                  );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white, // Set white background for padding
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            final cartProvider =
                Provider.of<CartProvider>(context, listen: false);
            if (cartProvider.cartItems.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BuyPage(product: cartProvider.cartItems.first),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your cart is empty! Add items to proceed.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
