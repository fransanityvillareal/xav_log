import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:xavlog_core/features/login/signin_page.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/firebase_options.dart'; // Firebase config

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed before async stuff
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => CartProvider()), // Add your providers here
      ],
      child: const XavLog(), // Load the app
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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Jost'),
          bodyMedium: TextStyle(fontFamily: 'Jost'),
          titleLarge: TextStyle(fontFamily: 'Jost'),
          titleMedium: TextStyle(fontFamily: 'Jost'),
          labelLarge: TextStyle(fontFamily: 'Jost'),
        ),
      ),
      home: const SigninPage(),
    );
  }
}

// add image
// add name
// fix the ui
