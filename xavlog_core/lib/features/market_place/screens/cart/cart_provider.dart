import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _cartItems = [];

  List<Product> get cartItems => _cartItems;

  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners(); // Updates UI when cart changes
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  int get cartCount => _cartItems.length;
}
