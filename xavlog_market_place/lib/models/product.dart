import 'package:flutter/material.dart';

class Product {
  final String image, title, description, condition, category;
  final int price, id;
  final Color color;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.price,
    required this.description,
    required this.condition,
    required this.color,
    required this.category, // Added category field
  });
}


List<Product> products = [
  Product(
      id: 1,
      title: "Cost Accounting Book",
      price: 10000,
      condition: "Like New",
      description: "Almost new, no damage.",
      image: "assets/images/item_1.png",
      color: const Color(0xFFB0BEC5),
      category: "Books"), // Category added

  Product(
      id: 2,
      title: "C++ Book",
      price: 234,
      condition: "Used - Very Good",
      description: "A comprehensive guide to C++ programming.",
      image: "assets/images/item_2.png",
      color: const Color(0xFFA1887F),
      category: "Books"), // Category added

  Product(
      id: 3,
      title: "Foundation of Nursing",
      price: 234,
      condition: "Used - Good",
      description: "Noticeable wear but fully functional.",
      image: "assets/images/item_3.png",
      color: const Color(0xFF8D6E63),
      category: "Books"), // Category added

  Product(
      id: 4,
      title: "Basketball",
      price: 500,
      condition: "New",
      description: "Official size and weight basketball.",
      image: "assets/images/item_4.png",
      color: const Color(0xFF757575),
      category: "PE Equipment"), // PE Equipment category

  Product(
      id: 5,
      title: "Running Shoes",
      price: 1500,
      condition: "Like New",
      description: "Worn only a few times, great condition.",
      image: "assets/images/item_5.png",
      color: const Color(0xFF546E7A),
      category: "PE Equipment"), // PE Equipment category

  Product(
    id: 6,
    title: "Flutter for Dummies",
    price: 234,
    condition: "Sold for Repair",
    description: "Not functional, for parts or repair only.",
    image: "assets/images/item_6.png",
    color: const Color(0xFF37474F),
    category: "Books", // Books category
  ),
];
