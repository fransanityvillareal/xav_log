import 'package:flutter/material.dart';
import 'initial_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Rubik', // Set global font to Rubik
        scaffoldBackgroundColor:
            Colors.white, // Ensure white background globally
      ),
      debugShowCheckedModeBanner: false,
      home: InitialPage(), // Load your renamed page
    );
  }
}
