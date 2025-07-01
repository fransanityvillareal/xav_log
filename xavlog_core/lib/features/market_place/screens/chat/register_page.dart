import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/login_button.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/textfield_login.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_service.dart';


class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void register(BuildContext context) async {
    final _authenticationService = AuthenticationService();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Incomplete Form"),
          content: Text("Please fill in all the fields."),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match"),
          content: Text("Make sure both password fields match."),
        ),
      );
      return;
    }

    try {
      await _authenticationService.signUpWithEmailAndPassword(email, password, context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Registration Error"),
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
                  Icon(Icons.person_add_alt_1, size: 70, color: ateneoBlue),
                  const SizedBox(height: 28),
                  Text(
                    "Create Your Xavlog Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ateneoBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Register with your GBox email to join the chat.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextfieldLogin(
                    hintText: "GBox Email",
                    obsecuretext: false,
                    controller: _emailController,
                    prefixIcon: Icon(Icons.email, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  TextfieldLogin(
                    hintText: "Password",
                    obsecuretext: true,
                    controller: _passwordController,
                    prefixIcon:
                        Icon(Icons.lock, color: const Color(0xFFBDBDBD)),
                  ),
                  const SizedBox(height: 16),
                  TextfieldLogin(
                    hintText: "Confirm Password",
                    obsecuretext: true,
                    controller: _confirmPasswordController,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 32),
                  LoginButton(
                    text: "Register",
                    onTap: () => register(context),
                    buttonColor: ateneoBlue,
                    textColor: Colors.white,
                    paddingVertical: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Log-in Now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: goldAccent,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
