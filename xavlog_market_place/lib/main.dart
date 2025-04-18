import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:xavlog_market_place/firebase_options.dart';
import 'package:xavlog_market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_market_place/screens/welcome/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyAppMarketPlace(),
    ),
  );
}

class MyAppMarketPlace extends StatelessWidget {
  const MyAppMarketPlace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'xavLOG Marketplace',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: IntroScreen(), // Start at IntroScreen or HomeScreen
    );
  }
}
