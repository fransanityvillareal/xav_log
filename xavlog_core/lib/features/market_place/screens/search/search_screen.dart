import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/details/details_screen.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  Stream<List<Product>> fetchProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching products'));
        }

        final results = snapshot.data!
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (results.isEmpty) {
          return const Center(child: Text("No results found"));
        }

        return Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(results[index].image, width: 50, height: 50),
                title: Text(results[index].title),
                subtitle: Text("\$${results[index].price} - ${results[index].condition}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(product: results[index]),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching products'));
        }

        final suggestions = snapshot.data!
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestions[index].title),
                onTap: () {
                  query = suggestions[index].title;
                  showResults(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
