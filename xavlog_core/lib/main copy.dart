/// XavLog - Main Application Entry Point
/// 
/// Purpose: Main entry point for the XavLog application that initializes the app
/// and sets up the theme and initial route.
/// 
/// Flow:
/// 1. App is launched
/// 2. MaterialApp is initialized with the app theme
/// 3. Initial route is set to SigninPage
/// 
/// Backend Implementation Needed:
/// - User authentication state management
/// - Session persistence across app launches
/// - Environment configuration for dev/staging/production
// library;

// import 'package:flutter/material.dart';
// import 'package:xavlog_core/features/login/signin_page.dart';

/* Authored by: Arsent Bico
Company: ASCEND
Project: xavLog
Feature: [XLG-001] Registration Page
Description: 
  This page will serve as the initial registration page/sign-in page for the xavLog application.
  The page will contain the following elements:
    - Logo of the application
    - Application name
    - Sign-in form
      - Email Address field
      - Password field
      - Sign-in button
    - Footer
      - Terms & Conditions
      - FAQs
 */

// void main() {
//   // Entry point for the application
//   runApp(const XavLog());
// }

// class XavLog extends StatelessWidget {
//   const XavLog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'xavLog', // Application title shown in OS task switchers
      
//       // Application-wide theme configuration
//       theme: ThemeData(
//         primaryColor: Colors.blueAccent,
//         fontFamily: 'Jost', // Primary font throughout the app
        
//         // Text theme definitions for consistent typography
//         textTheme: const TextTheme(
//           bodyLarge: TextStyle(fontFamily: 'Jost'),
//           bodyMedium: TextStyle(fontFamily: 'Jost'),
//           titleLarge: TextStyle(fontFamily: 'Jost'),
//           titleMedium: TextStyle(fontFamily: 'Jost'),
//           labelLarge: TextStyle(fontFamily: 'Jost'),
//         ),
//       ),
//       // Remove the debug banner in all environments
//       debugShowCheckedModeBanner: false,
      
//       // Initial route of the application
//       home: const SigninPage(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:xavlog_core/features/login/signin_page.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/firebase_options.dart'; // Firebase config

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed before async stuff
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()), // Add your providers here
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
      home: const SigninPage(), // Start with Chat Sign-in
    );
  }
}

