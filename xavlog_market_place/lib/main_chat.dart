import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_market_place/firebase_options.dart';
import 'package:xavlog_market_place/login_authentication/authentication_gate.dart';
import 'package:xavlog_market_place/login_authentication/login_or%20register.dart';
import 'screens/themes/light_mode.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthenticationGate(),
      theme: lightMode,
    );
  }
}
