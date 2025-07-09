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
        title: const Text(
          'Cart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 75, 75, 75),
          ),
        ),
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
      elevation: 0,
    ),   
      body: Stack(
        children: [
          Container(
            color: Colors.white,
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
                        padding: const EdgeInsets.only(bottom: 100),
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
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
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

          // Checkout Button Positioned Upwards
          Positioned(
            bottom: 40, // ← move it up by increasing this number
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                if (cartProvider.cartItems.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyPage(product: cartProvider.cartItems.first),
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
                backgroundColor: const Color(0xFF071D99),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
        ],
      ),
    );
  }
}
