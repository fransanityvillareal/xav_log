import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/buy/buy_page.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_screen.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_home_page.dart';
import 'package:xavlog_core/features/market_place/screens/details/components/body.dart'
    as details_body;
import 'package:xavlog_core/features/market_place/screens/search/search_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Product product;
  const DetailsScreen({required this.product, super.key});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _showArrow = true;
  late AnimationController _animationController;
  late Animation<double> _arrowAnimation;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Ensure _arrowAnimation is initialized correctly
    _arrowAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.product.color,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              _showArrow = false;
            });

            // Cancel any existing timer and start a new one
            _scrollTimer?.cancel();
            _scrollTimer = Timer(const Duration(seconds: 2), () {
              setState(() {
                _showArrow = true;
              });
            });
          }
          return true;
        },
        child: Stack(
          children: [
            // Fullscreen content
            Column(
              children: [
                Expanded(
                  child: details_body.Body(product: widget.product),
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
                      colorFilter: const ColorFilter.mode(
                          Color.fromARGB(255, 0, 0, 0), BlendMode.srcIn),
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
                            MaterialPageRoute(
                                builder: (context) => CartScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Adjust the Positioned widget to ensure the description is not covered
            Positioned(
              bottom: MediaQuery.of(context).size.height *
                  0.02, // Add some spacing from the bottom
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // Top Row: Chat Now + Add to Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CHAT NOW BUTTON
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatHomePage(
                                    initialSearchQuery:
                                        widget.product.sellerEmail,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF071D99),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Chat Now",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Jost',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ADD TO CART BUTTON
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          margin: const EdgeInsets.only(left: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false)
                                  .addToCart(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline,
                                          color: Color(0xFFD7A61F)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "${widget.product.title} added to cart!",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Jost',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: const Color(0xFF071D99),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 8,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF071D99),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Add to Cart",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Jost',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // BUY NOW BUTTON (centered below)
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BuyPage(product: widget.product),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD7A61F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        "BUY NOW",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Add a downward-pointing arrow in the center for small screens
            if (_showArrow && MediaQuery.of(context).size.height < 600)
              Positioned(
                bottom: MediaQuery.of(context).size.height *
                    0.20, // Position above the buttons
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _arrowAnimation.value),
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 32,
                      color: Color.fromARGB(255, 167, 165, 165),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  final Product product;

  const ProductDetails({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and price row
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 45),
                          const Text(
                            "Condition",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Jost',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.condition,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Rubik',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            NumberFormat.currency(locale: 'en_PH', symbol: 'P ')
                                .format(product.price),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                              color: Color(0xFF071D99),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
