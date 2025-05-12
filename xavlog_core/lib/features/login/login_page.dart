/// Login Page
///
/// Purpose: Allows existing users to log in to their xavLog accounts
///
/// Flow:
/// 1. User enters their email and password
/// 2. User clicks "Log-in" button to authenticate
/// 3. Upon successful authentication, user is directed to their dashboard
/// 4. Users without accounts can navigate to sign-up page
///
/// Backend Implementation Needed:
/// - User authentication against database
/// - Password hashing and verification
/// - Session token generation and management
/// - Failed login attempt handling and account lockout
/// - Password recovery option (future enhancement)
library;

import 'package:flutter/material.dart';
import 'signin_page.dart';
import '../dash_board/home_page_dashboard.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onTap; // Add this line to accept the onTap callback

  const LoginPage(
      {super.key, required this.onTap}); // Add 'required this.onTap'

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // UI state variables for interactive elements
  bool isLoginHovered = false;
  bool isTermsHovered = false;
  bool isFAQsHovered = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    // Calculate responsive dimensions based on screen size
    final logoSize = width * 0.45; // Logo size is 45% of screen width
    final buttonWidth = width * 0.30; // Button width is 30% of screen width
    final fontSize = width * 0.03; // Font size scales with screen width

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents keyboard from pushing elements up
      body: Container(
        width: width,
        height: height,
        // Xavier blue background color
        decoration: const BoxDecoration(
          color: Color(0xFF132BB2),
        ),
        child: Column(
          children: [
            SizedBox(height: height * 0.03),
            // Logo at the top of the page
            Image.asset(
              'assets/images/fulllogo.png',
              width: logoSize,
              height: logoSize,
            ),
            SizedBox(height: height * 0.04),
            Expanded(
              // Triangle-peeked white container for login form
              child: ClipPath(
                clipper: TrianglePeekClipper(),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(width * 0.01),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: height * 0.06), // More space at top of card
                      // Login page title
                      Text(
                        'Log-in',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 16, 16, 16),
                          fontFamily: 'Jost',
                          fontSize: fontSize * 2.7, // Larger title
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(
                          height: height * 0.045), // Space before email field
                      // Email input field
                      SizedBox(
                        width: buttonWidth * 2,
                        child: TextField(
                          style: TextStyle(
                            fontSize: fontSize * 1.25, // Larger input text
                            fontFamily: 'Jost',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              fontSize: fontSize * 1.6, // Larger label
                              fontFamily: 'Jost',
                            ),
                            suffixIcon: Icon(
                              Icons.email,
                              size: fontSize * 2.1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03), // Space between fields
                      // Password input field with visibility toggle
                      SizedBox(
                        width: buttonWidth * 2,
                        child: TextField(
                          style: TextStyle(
                            fontSize: fontSize * 1.25, // Larger input text
                            fontFamily: 'Jost',
                          ),
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: fontSize * 1.6, // Larger label
                              fontFamily: 'Jost',
                            ),
                            suffixIcon: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => setState(() =>
                                    isPasswordVisible = !isPasswordVisible),
                                child: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: fontSize * 2.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: height * 0.05), // More space before button
                      // Login button with hover effect
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => setState(() => isLoginHovered = true),
                        onExit: (_) => setState(() => isLoginHovered = false),
                        child: GestureDetector(
                          onTap: () {
                            // BACKEND TODO: Implement login authentication logic
                            // - Validate credentials against database
                            // - Generate and store auth token
                            // - Handle failed login attempts
                            // - Track login activity for security

                            // Navigate to user dashboard after successful login
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Homepage(),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: buttonWidth *
                                2.0, // Slightly narrower for balance
                            height: buttonWidth *
                                0.39, // Reduced height for better proportion
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    height * 0.008), // Less vertical padding
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(width * 0.018),
                              gradient: LinearGradient(
                                colors: [
                                  isLoginHovered
                                      ? const Color.fromARGB(255, 244, 202, 86)
                                      : const Color(0xFFBFA547),
                                  isLoginHovered
                                      ? const Color.fromARGB(255, 244, 202, 86)
                                      : const Color(0xFFBFA547),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    fontSize * 1.7, // Reduced button text size
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: height * 0.04), // More space after button
                      // GBOX helper text
                      Text(
                        'Please use your assigned GBOX account to Log-in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: fontSize *
                              1.6, // Slightly smaller for compactness
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: height * 0.012),
                      SizedBox(
                          height: height * 0.1), // Small space before Spacer
                      Spacer(),
                      // Move the sign-up link to the very bottom
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => setState(() => isTermsHovered = true),
                        onExit: (_) => setState(() => isTermsHovered = false),
                        child: GestureDetector(
                          onTap: () =>
                              _showCreateAccountDialog(context, fontSize),
                          child: Text(
                            "Don't have an account? Create now",
                            style: TextStyle(
                              color: isTermsHovered
                                  ? const Color(0xFFD7A61F)
                                  : const Color.fromARGB(255, 16, 16, 16),
                              fontSize:
                                  fontSize * 1.6, // Match button text size
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                              letterSpacing: 0.7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.06),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//comment
  /**
   * Shows a confirmation dialog for creating a new account
   * 
   * @param context The BuildContext for showing the dialog
   * @param fontSize The font size to use for consistent UI
   */
  void _showCreateAccountDialog(BuildContext context, double fontSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Create Account',
            style: TextStyle(
              color: const Color(0xFF071D99),
              fontWeight: FontWeight.bold,
              fontSize: fontSize * 1.8,
            ),
          ),
          content: Text(
            'Do you want to create a new account?',
            style: TextStyle(fontSize: 1.9 * fontSize),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: const Color(0xFF071D99),
                  fontWeight: FontWeight.bold,
                  fontSize: 1.7 * fontSize,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SigninPage(onTap: () {}),
                  ),
                );
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: const Color(0xFF071D99),
                  fontSize: 1.7 * fontSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/**
 * Custom Clipper for Triangle Peek Design
 * 
 * Creates a custom shape for the login container with a triangular
 * peek at the top, matching the design of the sign-in page for consistency.
 */
class TrianglePeekClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Calculate responsive triangle dimensions
    double triangleHeight = size.height * 0.15; // 15% of container height
    double triangleWidth = size.width;
    double startY = triangleHeight;

    // Create the path with a triangle at the top
    path.moveTo(0, startY);
    path.lineTo(triangleWidth / 2, 0);
    path.lineTo(triangleWidth, startY);
    path.lineTo(triangleWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
