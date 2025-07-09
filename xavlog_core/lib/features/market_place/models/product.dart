import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class Product {
  final String image, title, description, condition, category;
  final int price, id;
  final Color color;
  final String sellerEmail;
  final String sellerProfileImageUrl;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.price,
    required this.description,
    required this.condition,
    required this.color,
    required this.category,
    required this.sellerEmail,
    required this.sellerProfileImageUrl,
  });

  // Convert a Firestore document to a Product instance
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id.hashCode, // Use hashCode as a unique ID
      image: data['image'] ?? '',
      title: data['title'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      condition: data['condition'] ?? '',
      color: Color(int.parse(data['color'] ?? '0xFFB0BEC5')),
      category: data['category'] ?? '',
      sellerEmail: data['sellerEmail'] ?? '',
      sellerProfileImageUrl: data['sellerProfileImageUrl'] ?? '',
    );
  }

  get rating => null;

  // Convert a Product instance to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'image': image,
      'title': title,
      'price': price,
      'description': description,
      'condition': condition,
      'color': color.value.toString(),
      'category': category,
      'sellerEmail': sellerEmail,
      'sellerProfileImageUrl': sellerProfileImageUrl,
    };
  }
}

Stream<List<Product>> fetchProductsFromDatabase() {
  return FirebaseFirestore.instance.collection('products').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
      );
}

Stream<List<Product>> fetchProductsWithImages() {
  return FirebaseFirestore.instance.collection('products').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return Product(
            id: doc.id.hashCode,
            image: data['image'] ?? '',
            title: data['title'] ?? '',
            price: data['price'] ?? 0,
            description: data['description'] ?? '',
            condition: data['condition'] ?? '',
            color: Color(int.parse(data['color'] ?? '0xFFB0BEC5')),
            category: data['category'] ?? '',
            sellerEmail: data['sellerEmail'] ?? '',
            sellerProfileImageUrl: data['sellerProfileImageUrl'] ?? '',
          );
        }).toList(),
      );
}

Future<void> uploadProfileImageAndStoreUserData() async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final supabaseUser = Supabase.instance.client.auth.currentUser;

  if (firebaseUser == null || supabaseUser == null) {
    throw Exception('User not authenticated');
  }

  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result == null || result.files.single.path == null) {
    throw Exception('No file selected');
  }

  final file = File(result.files.single.path!);
  final fileExt = file.path.split('.').last;
  final fileName =
      '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

  await Supabase.instance.client.storage
      .from('xavlog-profile')
      .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

  final publicUrl = Supabase.instance.client.storage
      .from('xavlog-profile')
      .getPublicUrl(fileName);

  await FirebaseFirestore.instance
      .collection('Users')
      .doc(firebaseUser.uid)
      .set({'profileImageUrl': publicUrl, 'email': firebaseUser.email},
          SetOptions(merge: true));
}

// Remove the hardcoded products list
// List<Product> products = [];

// Make sure to import this file in your main copy.dart
// and use `ProductProvider(products)` for your provider initialization.
