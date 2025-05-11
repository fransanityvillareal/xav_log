import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_core/features/login/signin_page.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/providers/product_provider.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/firebase_options.dart';
import 'package:xavlog_core/onboarding/onboarding_materials/page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed before async stuff
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => CartProvider()), // Add your providers here
        ChangeNotifierProvider(create: (context) => ProductProvider(products)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const OnboardingPageStart(),
      ),
    ),
  );
}

final pages = [
  const PageData(
    imageAssetPath:
        'assets/lottie/campus_life.json', // Correct Lottie JSON file path
    title: "Your Campus Life, Centralized",
    description:
        "Explore events, track grades, buy/sell in the marketplace, and more — all in one app built for Ateneans.",
    bgColor: Color(0xFF071D99),
    textColor: Colors.white,
  ),
  const PageData(
    imageAssetPath:
        'assets/lottie/event_life.json', // Correct Lottie JSON file path
    title: "Find Events Instantly",
    description:
        "Never miss out. Discover campus events, activities, and announcements in real time.",
    bgColor: Color(0xFF2E7D32),
    textColor: Colors.white,
    lottieSize: 340,
  ),
  const PageData(
    imageAssetPath:
        'assets/lottie/analytics_life.json', // Correct Lottie JSON file path
    title: "Grades at Your Fingertips",
    description: "Monitor your academic performance throughout the semester.",
    bgColor: Color(0xFFD7A61F),
    textColor: Colors.black,
    lottieSize: 360,
  ),
  const PageData(
    imageAssetPath:
        'assets/lottie/shop_life.json', // Correct Lottie JSON file path
    title: "Your Ateneo Marketplace",
    description:
        "Buy and sell items safely with fellow students books, uniforms, gadgets, and more.",
    bgColor: Color(0xFFBFA547),
    textColor: Colors.black,
    lottieSize: 360,
  ),
  const PageData(
    imageAssetPath:
        'assets/lottie/notifications_life.json', // Correct Lottie JSON file path
    title: "Customize Your Experience",
    description:
        "Tailor your dashboard and notifications based on your interests.",
    bgColor: Color(0xFF512DA8),
    textColor: Colors.white,
    lottieSize: 280,
  ),
  const PageData(
    imageAssetPath:
        'assets/lottie/login_life.json', // Correct Lottie JSON file path
    title: "Ready to Explore?",
    description: "Sign up or log in to start your xavLog journey.",
    bgColor: Color(0xFFEB202C),
    textColor: Colors.white,
    lottieSize: 300,
  ),
];

class OnboardingPageStart extends StatelessWidget {
  const OnboardingPageStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEB202C), Color(0xFFFF5252)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: screenWidth * 0.08,
            ),
          ),
        ),
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(child: _Page(page: page));
        },
        onFinish: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SigninPage()),
          );
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final String? description;
  final String imageAssetPath;
  final Color bgColor;
  final Color textColor;
  final double lottieSize; // New

  const PageData({
    this.title,
    this.description,
    required this.imageAssetPath,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
    this.lottieSize = 280,
  });
}

class _Page extends StatelessWidget {
  final PageData page;
  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        children: [
          _LottieAnimation(page: page, size: page.lottieSize),
          const SizedBox(height: 16),
          Text(
            page.title ?? '',
            style: TextStyle(
              color: page.textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.description ?? '',
            style: TextStyle(
              color: page.textColor.withOpacity(0.85),
              fontSize: 16,
              fontFamily: 'Helvetica',
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _LottieAnimation extends StatelessWidget {
  final PageData page;
  final double size;

  const _LottieAnimation({Key? key, required this.page, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          page.imageAssetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
