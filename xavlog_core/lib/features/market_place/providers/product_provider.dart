import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];

  ProductProvider() {
    _fetchProductsFromFirestore();
  }

  List<Product> get products => _products;

  void _fetchProductsFromFirestore() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _products =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  void addProduct(Product product) {
    _firestore.collection('products').add(product.toFirestore());
  }
}
