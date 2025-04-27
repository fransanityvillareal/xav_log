import 'package:flutter/material.dart';
import 'package:xavlog_market_place/market_place/screens/welcome/intro_seller.dart';

void main() {
  runApp(const BuyerIntroduction());
}

class BuyerIntroduction extends StatelessWidget {
  const BuyerIntroduction({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const IntroductionBuyer(),
    );
  }
}

class IntroductionBuyer extends StatelessWidget {
  const IntroductionBuyer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // Yellow Dot (Bottom Center)
          Positioned(
            left: MediaQuery.of(context).size.width *
                0.32, // Adjusted for screen width
            bottom: MediaQuery.of(context).size.height *
                0.1, // Adjusted for screen height
            child: Container(
              width: 24,
              height: 24,
              decoration: const ShapeDecoration(
                color: Color(0xFFFFD037),
                shape: CircleBorder(),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height *
                    0.06, 
                right: MediaQuery.of(context).size.width *
                    0.07, // Adjusted right spacing
              ),
              child: GestureDetector(
                onTap: () {
                  
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF848487),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),

          // Main Image
          Positioned(
            left: -MediaQuery.of(context).size.width *
                0.17, // Adjusted for screen width
            top: MediaQuery.of(context).size.height *
                0.3, // Adjusted for screen height
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  1.3, // Adjusted for screen width
              height: MediaQuery.of(context).size.height *
                  0.7, // Adjusted for screen height
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/513x580"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Next Button 
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.08,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.85, 
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IntroductionSeller(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF071D99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: Colors.black.withAlpha((0.2 * 255).toInt()),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),


          // Blue Dot 
          Positioned(
            left: MediaQuery.of(context).size.width *
                0.08, // Adjusted for screen width
            top: MediaQuery.of(context).size.height *
                0.3, // Adjusted for screen height
            child: Container(
              width: 24,
              height: 24,
              decoration: const ShapeDecoration(
                color: Color(0xFF2CB4EC),
                shape: CircleBorder(),
              ),
            ),
          ),

          // Red Dot 
          Positioned(
            left: -MediaQuery.of(context).size.width *
                0.05, 
            top: MediaQuery.of(context).size.height *
                0.6, 
            child: Container(
              width: 94,
              height: 87,
              decoration: const ShapeDecoration(
                color: Color(0xFFE14B5A),
                shape: CircleBorder(),
              ),
            ),
          ),

          // Yellow Circle 
          Positioned(
            right: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * 0.50,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.47,
              height: MediaQuery.of(context).size.width * 0.47,
              decoration: const BoxDecoration(
                color: Color(0xFFF9D048),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width *
                0.1, 
            top: MediaQuery.of(context).size.height *
                0.08, 
            child: SizedBox(
              width: 70.22,
              child: Text(
                'Buy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF161C2B),
                  fontSize: 35,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width *
                0.08, 
            top: MediaQuery.of(context).size.height *
                0.16, 
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, 
              child: Text(
                'Find great deals on pre-loved items from fellow ADNU students! Browse listings, connect with sellers, and get what you need at affordable prices—quick, easy, and hassle-free! 🛍️',
                style: TextStyle(
                  color: const Color(0xFF6F6F79),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
