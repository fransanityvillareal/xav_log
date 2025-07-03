import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/login_button.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/textfield_login.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_service.dart';

class LoginPageMarketPlace extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final void Function()? onTap;

  LoginPageMarketPlace({super.key, required this.onTap});

  void login(BuildContext context) async {
    final authenticationService = AuthenticationService();

    try {
      await authenticationService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        context, // Added the missing argument
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Failed"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color ateneoBlue = Color(0xFF003A70);
    const Color goldAccent = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: const Color(0xFFE6ECF3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forum_rounded, size: 70, color: ateneoBlue),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      "Welcome to Xavlog Market Place Chat",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ateneoBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      "Sign in with your GBox account to continue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextfieldLogin(
                    hintText: "GBox Email",
                    obsecuretext: false,
                    controller: _emailController,
                    prefixIcon:
                        Icon(Icons.email, color: const Color(0xFFBDBDBD)),
                  ),
                  const SizedBox(height: 16),
                  TextfieldLogin(
                    hintText: "Password",
                    obsecuretext: true,
                    controller: _passwordController,
                    prefixIcon:
                        Icon(Icons.lock, color: const Color(0xFFBDBDBD)),
                  ),
                  const SizedBox(height: 32),
                  LoginButton(
                    text: "Log In",
                    onTap: () => login(context),
                    buttonColor: ateneoBlue,
                    textColor: Colors.white,
                    paddingVertical: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  const SizedBox(height: 30),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Don't have a GBox account?",
                  //       style: TextStyle(color: Colors.grey.shade600),
                  //     ),
                  //     const SizedBox(width: 6),
                  //     GestureDetector(
                  //       onTap: onTap,
                  //       child: Text(
                  //         "Register now",
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           color: goldAccent,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
