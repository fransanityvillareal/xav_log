import 'package:flutter/material.dart';
import 'package:xavlog_market_place/services/login_authentication/authentication_service.dart';
import 'package:xavlog_market_place/screens/chat/components/login_button.dart';
import 'package:xavlog_market_place/screens/chat/components/textfield_login.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  void register(BuildContext context) async {
    final _authenticationService = AuthenticationService();

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match"),
        ),
      );
      return;
    }

    // Try registering
    try {
      await _authenticationService.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Registration Error"),
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 65,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 50),
              Text(
                "Oh Welcome back!, you've been missed",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),
              TextfieldLogin(
                hintText: "Email",
                obsecuretext: false,
                controller: _emailController,
              ),
              const SizedBox(height: 10),
              TextfieldLogin(
                hintText: "Password",
                obsecuretext: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 10),
              TextfieldLogin(
                hintText: "Confirm Password",
                obsecuretext: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 20),
              LoginButton(
                text: "Register",
                onTap: () => register(context),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Log-in Now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
