import 'package:flutter/material.dart';
import 'package:xavlog_market_place/market_place/services/login_authentication/authentication_gate.dart';
import 'market_place/screens/themes/light_mode.dart';

class MyAppChat extends StatelessWidget {
  const MyAppChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthenticationGate(),
      theme: lightMode,
    );
  }
}
