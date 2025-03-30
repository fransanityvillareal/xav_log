import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xavlog_market_place/models/product.dart';
import 'package:xavlog_market_place/screens/cart/cart_screen.dart';
import 'package:xavlog_market_place/screens/search/search_screen.dart'; 
import 'package:xavlog_market_place/screens/details/components/body.dart' as details_body;

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
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                onPressed: () {
                  showSearch(context: context, delegate: ProductSearchDelegate());
                },
              ),
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/cart.svg",
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  CartScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
