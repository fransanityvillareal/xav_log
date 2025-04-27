import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/firebase_options.dart';
import 'buy_page.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed before async stuff
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buy Page Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BuyPage(product: products[2]), // <<< Here: use an existing product!
    );
  }
}
