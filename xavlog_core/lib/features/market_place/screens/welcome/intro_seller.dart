import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/dashboard/dashboardpage.dart';

void main() {
  runApp(const SellerIntroduction());
}

class SellerIntroduction extends StatelessWidget {
  const SellerIntroduction({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const IntroductionSeller(),
    );
  }
}

class IntroductionSeller extends StatelessWidget {
  const IntroductionSeller({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
          Positioned(
            left: -screenWidth * 0.05,
            bottom: screenHeight * 0.18,
            child: Container(
              width: screenWidth * 0.1,
              height: screenWidth * 0.1,
              decoration: const ShapeDecoration(
                color: Color(0xFFFFD037),
                shape: OvalBorder(),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.12,
            top: screenHeight * 0.35,
            child: Container(
              width: screenWidth * 0.28,
              height: screenWidth * 0.28,
              decoration: const ShapeDecoration(
                color: Color(0xFFFFD037),
                shape: OvalBorder(),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.05,
            top: screenHeight * 0.65,
            child: Container(
              width: screenWidth * 0.32,
              height: screenWidth * 0.3,
              decoration: const ShapeDecoration(
                color: Color(0xFFE14B5A),
                shape: OvalBorder(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.06,
                right: MediaQuery.of(context).size.width * 0.07,
              ),
              child: GestureDetector(
                onTap: () {},
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
          Positioned(
            left: screenWidth * 0.1,
            top: screenHeight * 0.08,
            child: Text(
              'Sell',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF161C2B),
                fontSize: 35,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.16,
            right: screenWidth * 0.08,
            child: Text(
              'Turn your pre-loved items into cash by selling directly to fellow ADNU students. List your items, set your price, and connect with buyers hassle-free!',
              style: const TextStyle(
                color: Color(0xFF6F6F79),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.08,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeWidget(),
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
        ],
      ),
    );
  }
}
