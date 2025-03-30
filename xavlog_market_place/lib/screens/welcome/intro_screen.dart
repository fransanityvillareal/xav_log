import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xavlog_market_place/screens/welcome/intro_buy.dart';
import 'package:xavlog_market_place/screens/welcome/intro_seller.dart';


class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          children: [
            // Background Circles (these will be behind the SVG)
            // Red Circle Center Left
            Positioned(
              left: MediaQuery.of(context).size.width * 0.14,
              top: MediaQuery.of(context).size.height * 0.36,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.48,
                height: MediaQuery.of(context).size.width * 0.48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE14B5A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Yellow Circle Top Right
            Positioned(
              left: MediaQuery.of(context).size.width * 0.77,
              top: MediaQuery.of(context).size.height * 0.13,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.47,
                height: MediaQuery.of(context).size.width * 0.47,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9D048),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Blue Circle Bottom Right
            Positioned(
              left: -MediaQuery.of(context).size.width * 0.15,
              top: MediaQuery.of(context).size.height * 0.17,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.24,
                height: MediaQuery.of(context).size.width * 0.24,
                decoration: BoxDecoration(
                  color: const Color(0xFF5C5BFD),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Blue Circle Bottom Left
            Positioned(
              left: MediaQuery.of(context).size.width * 0.81,
              top: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.06,
                height: MediaQuery.of(context).size.width * 0.06,
                decoration: BoxDecoration(
                  color: const Color(0xFF2CB4EC),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Yellow Circle Top Left
            Positioned(
              left: MediaQuery.of(context).size.width * 0.16,
              top: MediaQuery.of(context).size.height * 0.22,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.06,
                height: MediaQuery.of(context).size.width * 0.06,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD037),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Welcome Text
            Positioned(
              top: MediaQuery.of(context).size.height * 0.6,
              left: 0,
              right: 0,
              child: Text(
                'Welcome to xavLOG Marketplace',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF161C2B),
                  fontSize: 27,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            // Description Text
            Positioned(
              top: MediaQuery.of(context).size.height * 0.75,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'A marketplace where you can buy directly from fellow ADNU students affordable, and convenient!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF6F6F79),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            // Get Started Button with Hover Effect
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.08,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            IntroductionBuyer()), // Navigate to HomeScreen
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
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Skip Text
            // Skip Button (Top Right)
            Align(
  alignment: Alignment.topRight,
  child: Padding(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).size.height * 0.06, // Adjusted top spacing
      right: MediaQuery.of(context).size.width * 0.07, // Adjusted right spacing
    ),
    child: GestureDetector(
      onTap: () {
        // Navigate to the next screen when "Skip" is pressed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IntroductionSeller(),
          ),
        );
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

            // Center SVG Background (placed LAST to be on top)
            Center(
              child: SvgPicture.asset(
                'assets/icons/girl_laptop.svg', // Replace with your SVG path
                width: MediaQuery.of(context).size.width *
                    0.6, // Adjust width as needed
                height: MediaQuery.of(context).size.width *
                    0.6, // Adjust height as needed
                fit: BoxFit.contain, // Adjust fit as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
