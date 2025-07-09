import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/buy/buy_page.dart';
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
      body: Stack(
        children: [
          // Fullscreen content
          Column(
            children: [
              Expanded(
                child: details_body.Body(product: product),
              ),
            ],
          ),

          // Floating app bar icons (no vertical padding)
          Positioned(
            top: 43, // push a bit from the top edge
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/back.svg",
                    colorFilter:
                        const ColorFilter.mode(Color.fromARGB(255, 0, 0, 0), BlendMode.srcIn),
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
                        colorFilter: const ColorFilter.mode(
                            Color.fromARGB(255, 0, 0, 0), BlendMode.srcIn),
                      ),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: ProductSearchDelegate(),
                        );
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/cart.svg",
                        colorFilter: const ColorFilter.mode(
                            Color.fromARGB(255, 0, 0, 0), BlendMode.srcIn),
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
          ),
        ],
      ),
      floatingActionButton: _buildAddToCartButton(context),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: SizedBox(
        width: 155,
        height: 55,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyPage(product: product),
              ),
            );
          },
          label: const Text(
            "Buy Now",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFD7A61F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
