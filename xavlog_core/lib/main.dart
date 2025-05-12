import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/providers/product_provider.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/firebase_options.dart';

import 'onboarding/main_onboarding.dart';
import 'features/login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider(products)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const OnboardingPageStart(),
        routes: {
          '/login': (context) => LoginPage(onTap: () {}),
          // Add other routes here as needed
        },
      ),
    ),
  );
}
