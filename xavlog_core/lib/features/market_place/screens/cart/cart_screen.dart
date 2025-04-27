import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      body: Consumer<CartProvider>(
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
                      leading: Image.asset(product.image, width: 50),
                      title: Text(product.title),
                      subtitle: Text('\$${product.price}'),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          cartProvider.removeFromCart(product);
                        },
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
