import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/buy/buy_page.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_screen.dart';
import 'package:xavlog_core/features/market_place/screens/details/components/body.dart'
    as details_body;
import 'package:xavlog_core/features/market_place/screens/search/search_screen.dart';

class DetailsScreen extends StatelessWidget {
  final Product product;
  const DetailsScreen({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: product.color,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: details_body.Body(product: product),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddToCartButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/back.svg",
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/search.svg",
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                onPressed: () {
                  showSearch(
                      context: context, delegate: ProductSearchDelegate());
                },
              ),
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/cart.svg",
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 5),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // Navigate to BuyPage with the current product
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BuyPage(product: product), // Pass the product here
            ),
          );
        },
        child: const Text(
          "Buy Now",
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
