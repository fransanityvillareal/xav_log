import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:xavlog_core/features/market_place/providers/product_provider.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/firebase_options.dart'; // Firebase config
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/widget/bottom_nav_wrapper.dart';

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
      child: const XavLog(),
    ),
  );
}

class XavLog extends StatelessWidget {
  const XavLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xavLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        fontFamily: 'Jost',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const HomeWrapper(), // Use the wrapper with navigation bar
    );
  }
}

// add image
// add name
// fix the ui
// add navigation
// add background white
