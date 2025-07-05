import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/market_place/models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all products from Firestore
  Future<List<Product>> fetchProducts() async {
    try {
      final snapshot = await _db.collection('products').get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Add a product to Firestore
  Future<void> addProduct(Product product) async {
    try {
      await _db.collection('products').add(product.toFirestore());
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  // Update a product in Firestore
  Future<void> updateProduct(String id, Product product) async {
    try {
      await _db.collection('products').doc(id).update(product.toFirestore());
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // Delete a product from Firestore
  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}
