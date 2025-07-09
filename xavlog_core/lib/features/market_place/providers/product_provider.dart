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

  Future<void> deleteProductByImageUrl(String imageUrl) async {
    try {
      // Query the database to find the product with the matching image URL
      final querySnapshot = await _firestore
          .collection('products')
          .where('image', isEqualTo: imageUrl)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the matching product
        final docId = querySnapshot.docs.first.id;

        // Delete the product document from the database
        await _firestore.collection('products').doc(docId).delete();

        // Update the local product list
        _products.removeWhere((product) => product.image == imageUrl);
        notifyListeners();
      } else {
        throw Exception('No product found with the provided image URL.');
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}
