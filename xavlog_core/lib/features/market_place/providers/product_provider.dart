import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products;

  ProductProvider(List<Product> products)
      : _products = List<Product>.from(products);

  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
}
