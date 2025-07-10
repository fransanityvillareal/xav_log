import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xavlog_core/constants.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/buy/buy_page.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_home_page.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  final Product product;
  const Body({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
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
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),

                // White info container
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height *
                                    0.2, // Increased bottom padding
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 7.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                              const SizedBox(
                                                  height: kDefaultPaddin),
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
                                              const SizedBox(
                                                  height: kDefaultPaddin),
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
                                              NumberFormat.currency(
                                                      locale: 'en_PH',
                                                      symbol: 'P ')
                                                  .format(product.price),
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
                            );
                          },
                        ),

                        // Scroll indicator (arrow) centered
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom Buttons - fixed
           
          ],
        ),
      ),
    );
  }
}
