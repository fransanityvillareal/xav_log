import 'package:flutter/material.dart';
import 'package:xavlog_core/constants.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_home_page.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  final Product product;
  const Body({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top grey section with product image
                Container(
                  height: 350,
                  alignment: Alignment.center,
                  child: Image.network(
                    product.image,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),

                // White info container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.only(left: 7.0),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                color: Color.fromARGB(221, 70, 70, 70),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 7.0),
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
                                      const SizedBox(height: kDefaultPaddin),
                                      const Text(
                                        "Description",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Jost',
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        product.description,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontFamily: 'Rubik',
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPaddin),
                                      const Text(
                                        "Seller Email",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Jost',
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        product.sellerEmail,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontFamily: 'Rubik',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      "PHP ${product.price}",
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Jost',
                                        color: Color(0xFF071D99),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom Buttons - fixed
            Positioned(
              bottom: 32,
              left: kDefaultPaddin,
              child: Row(
                children: [
                  // CHAT NOW BUTTON
                  SizedBox(
                    width: 90,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatHomePage(
                              initialSearchQuery: product.sellerEmail,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF071D99),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        elevation: 6,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                          SizedBox(height: 2),
                          Text(
                            "Chat Now",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ADD TO CART BUTTON
                  SizedBox(
                    width: 90,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Color(0xFFD7A61F)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "${product.title} added to cart!",
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        elevation: 6,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
                          SizedBox(height: 2),
                          Text(
                            "Add to Cart",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
