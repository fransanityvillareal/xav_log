import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/market_place/services/login_authentication/login_or%20register.dart';
import 'package:xavlog_core/market_place/screens/chat/chat_home_page.dart';

class AuthenticationGate extends StatelessWidget {
  const AuthenticationGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is login

          if (snapshot.hasData) {
            return ChatHomePage();
          }

          //user is not login
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
