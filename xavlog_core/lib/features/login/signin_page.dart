/// Sign-in Page
///
/// Purpose: Provides the initial sign-in interface for all users
///
/// Flow:
/// 1. User enters email and password
/// 2. User clicks "Sign In" button to create a new account
/// 3. User can navigate to existing login page if already has an account
/// 4. User can access Terms & Conditions and FAQs from the footer
///
/// Backend Implementation Needed:
/// - Email validation
/// - Password strength validation
/// - User authentication against backend server
/// - Error handling for authentication failures
/// - Secure credential storage
library;

import 'package:flutter/material.dart';
import 'package:xavlog_core/features/login/login_page.dart';
import 'account_choose.dart';
import 'terms_and_conditions.dart';
import 'faqs.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key, required Null Function() onTap});
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  // State variables for UI interaction effects
  bool isSignInHovered = false;
  bool isLoginHovered = false;
  bool isTermsHovered = false;
  bool isFAQsHovered = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Get device dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    // Calculate responsive dimensions based on screen size
    final logoSize = width * 0.45; // Logo size is 45% of screen width
    final buttonWidth = width * 0.30; // Button width is 30% of screen width
    final fontSize = width * 0.04; // Increased base font size scaling

    // Get the height of the keyboard if it's visible

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap everything with SingleChildScrollView
        child: Container(
          width: width,
          height: height,
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
              SizedBox(height: height * 0.04), // More space below logo
              Expanded(
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
                        // Sign-in page title
                        Text(
                          'Sign-in',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 16, 16, 16),
                            fontFamily: 'Jost',
                            fontSize: fontSize * 2.0, // Larger title
                            fontWeight: FontWeight.w800,
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
                                fontSize: fontSize * 1.18, // Larger label
                                fontFamily: 'Jost',
                              ),
                              suffixIcon: Icon(
                                Icons.email,
                                size: fontSize * 1.5,
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
                                fontSize: fontSize * 1.18, // Larger label
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
                                    size: fontSize * 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: height * 0.045), // More space before button
                        // Sign In button with hover effect
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) =>
                              setState(() => isSignInHovered = true),
                          onExit: (_) =>
                              setState(() => isSignInHovered = false),
                          child: GestureDetector(
                            onTap: () {
                              // Backend functionality here
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AccountChoosePage(),
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
                                    isSignInHovered
                                        ? const Color.fromARGB(
                                            255, 244, 202, 86)
                                        : const Color(0xFFBFA547),
                                    isSignInHovered
                                        ? const Color.fromARGB(
                                            255, 244, 202, 86)
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
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize *
                                      1.18, // Reduced button text size
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
                        // Helper text for users
                        Text(
                          'Please use your assigned GBOX account to sign in',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: fontSize * 1.1, // Larger helper text
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                            height:
                                height * 0.04), // More space before login link
                        // Login to existing account link
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          margin: EdgeInsets.only(
                              top: height * 0.01, bottom: height * 0.01),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) =>
                                setState(() => isLoginHovered = true),
                            onExit: (_) =>
                                setState(() => isLoginHovered = false),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LoginPage(onTap: () {}),
                                  ),
                                );
                              },
                              child: Text(
                                'Log-in to my account',
                                style: TextStyle(
                                  color: isLoginHovered
                                      ? const Color(0xFFD7A61F)
                                      : const Color.fromARGB(255, 16, 16, 16),
                                  fontSize: fontSize * 1.25, // Larger link text
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: height * 0.08), // More space before footer
                        // Footer with Terms & Conditions and FAQs links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Terms & Conditions link with hover effect
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) =>
                                  setState(() => isTermsHovered = true),
                              onExit: (_) =>
                                  setState(() => isTermsHovered = false),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TermsAndConditions(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    color: isTermsHovered
                                        ? const Color(0xFF0529CC)
                                        : const Color.fromARGB(255, 16, 16, 16),
                                    fontSize:
                                        fontSize * 1.1, // Larger footer link
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            // Separator between links
                            Text(
                              ' | ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // FAQs link with hover effect
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) =>
                                  setState(() => isFAQsHovered = true),
                              onExit: (_) =>
                                  setState(() => isFAQsHovered = false),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FAQs(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'FAQs',
                                  style: TextStyle(
                                    color: isFAQsHovered
                                        ? const Color(0xFF0529CC)
                                        : const Color.fromARGB(255, 16, 16, 16),
                                    fontSize:
                                        fontSize * 1.1, // Larger footer link
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.03), // More space at bottom
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/**
 * Custom Clipper for Triangle Peek Design
 * 
 * Creates a custom shape for the sign-in container with a triangular
 * peek at the top, giving the UI a distinctive appearance.
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










/// Sign-in Page
///
/// Purpose: Provides the initial sign-in interface for all users
///
/// Flow:
/// 1. User enters email and password
/// 2. User clicks "Sign In" button to create a new account
/// 3. User can navigate to existing login page if already has an account
/// 4. User can access Terms & Conditions and FAQs from the footer
///
/// Backend Implementation Needed:
/// - Email validation
/// - Password strength validation
/// - User authentication against backend server
/// - Error handling for authentication failures
/// - Secure credential storage
// library;

// import 'package:flutter/material.dart';
// import 'package:xavlog_core/features/login/login_page.dart';
// import 'account_choose.dart';
// import 'terms_and_conditions.dart';
// import 'faqs.dart';

// class SigninPage extends StatefulWidget {
//   const SigninPage({super.key});
//   @override
//   State<SigninPage> createState() => _SigninPageState();
// }

// class _SigninPageState extends State<SigninPage> {
//   bool isSignInHovered = false;
//   bool isLoginHovered = false;
//   bool isTermsHovered = false;
//   bool isFAQsHovered = false;
//   bool isPasswordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final width = screenSize.width;
//     final height = screenSize.height;

//     final logoSize = width * 0.4;
//     final contentPadding = width * 0.05;
//     final fontSize = width * 0.04;

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           width: width,
//           height: height,
//           color: const Color(0xFF132BB2),
//           child: Column(
//             children: [
//               SizedBox(height: height * 0.05),
//               Image.asset(
//                 'assets/images/fulllogo.png',
//                 width: logoSize,
//                 height: logoSize,
//               ),
//               Expanded(
//                 child: ClipPath(
//                   clipper: TrianglePeekClipper(),
//                   child: Container(
//                     width: width,
//                     padding: EdgeInsets.symmetric(horizontal: contentPadding),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(width * 0.02),
//                         topRight: Radius.circular(width * 0.02),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         SizedBox(height: height * 0.08),
//                         Text(
//                           'Sign-in',
//                           style: TextStyle(
//                             color: Colors.black87,
//                             fontFamily: 'Jost',
//                             fontSize: fontSize * 2,
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                         SizedBox(height: height * 0.04),
//                         _buildInputField(
//                           label: 'Email Address',
//                           icon: Icons.email,
//                           fontSize: fontSize,
//                         ),
//                         SizedBox(height: height * 0.025),
//                         _buildPasswordField(fontSize),
//                         SizedBox(height: height * 0.04),
//                         _buildSignInButton(width, fontSize),
//                         SizedBox(height: height * 0.03),
//                         Text(
//                           'Please use your assigned GBOX account to sign in',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: fontSize * 0.9,
//                             fontFamily: 'Jost',
//                           ),
//                         ),
//                         SizedBox(height: height * 0.03),
//                         _buildLoginLink(fontSize),
//                         const Spacer(),
//                         _buildFooterLinks(fontSize),
//                         SizedBox(height: height * 0.03),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required String label,
//     required IconData icon,
//     required double fontSize,
//   }) {
//     return TextField(
//       style: TextStyle(
//         fontSize: fontSize,
//         fontFamily: 'Jost',
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(
//           fontSize: fontSize,
//           fontFamily: 'Jost',
//         ),
//         prefixIcon: Icon(icon, size: fontSize * 1.2),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   Widget _buildPasswordField(double fontSize) {
//     return TextField(
//       style: TextStyle(
//         fontSize: fontSize,
//         fontFamily: 'Jost',
//       ),
//       obscureText: !isPasswordVisible,
//       decoration: InputDecoration(
//         labelText: 'Password',
//         labelStyle: TextStyle(
//           fontSize: fontSize,
//           fontFamily: 'Jost',
//         ),
//         prefixIcon: const Icon(Icons.lock_outline),
//         suffixIcon: GestureDetector(
//           onTap: () => setState(() => isPasswordVisible = !isPasswordVisible),
//           child: Icon(
//             isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//             size: fontSize * 1.2,
//           ),
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   Widget _buildSignInButton(double width, double fontSize) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => isSignInHovered = true),
//       onExit: (_) => setState(() => isSignInHovered = false),
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AccountChoosePage(),
//             ),
//           );
//         },
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               colors: [
//                 isSignInHovered
//                     ? const Color(0xFFF4CA56)
//                     : const Color(0xFFBFA547),
//                 isSignInHovered
//                     ? const Color(0xFFF4CA56)
//                     : const Color(0xFFBFA547),
//               ],
//             ),
//           ),
//           child: Center(
//             child: Text(
//               'Sign In',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: fontSize,
//                 fontFamily: 'Jost',
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginLink(double fontSize) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => isLoginHovered = true),
//       onExit: (_) => setState(() => isLoginHovered = false),
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => LoginPage(onTap: () {}),
//             ),
//           );
//         },
//         child: Text(
//           'Log-in to my account',
//           style: TextStyle(
//             color: isLoginHovered
//                 ? const Color(0xFFD7A61F)
//                 : const Color.fromARGB(255, 16, 16, 16),
//             fontSize: fontSize,
//             fontFamily: 'Jost',
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFooterLinks(double fontSize) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildFooterLink('Terms & Conditions', fontSize, isTermsHovered, () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const TermsAndConditions(),
//             ),
//           );
//         }),
//         const Text(
//           ' | ',
//           style: TextStyle(color: Colors.grey),
//         ),
//         _buildFooterLink('FAQs', fontSize, isFAQsHovered, () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const FAQs(),
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildFooterLink(
//       String text, double fontSize, bool isHovered, VoidCallback onTap) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() {
//         if (text == 'Terms & Conditions') isTermsHovered = true;
//         if (text == 'FAQs') isFAQsHovered = true;
//       }),
//       onExit: (_) => setState(() {
//         if (text == 'Terms & Conditions') isTermsHovered = false;
//         if (text == 'FAQs') isFAQsHovered = false;
//       }),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Text(
//           text,
//           style: TextStyle(
//             color: isHovered
//                 ? const Color(0xFF0529CC)
//                 : const Color.fromARGB(255, 16, 16, 16),
//             fontSize: fontSize * 0.9,
//             fontFamily: 'Jost',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

// /**
//  * Custom Clipper for Triangle Peek Design
//  * 
//  * Creates a custom shape for the sign-in container with a triangular
//  * peek at the top, giving the UI a distinctive appearance.
//  */
// class TrianglePeekClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();

//     // Calculate responsive triangle dimensions
//     double triangleHeight = size.height * 0.15; // 15% of container height
//     double triangleWidth = size.width;
//     double startY = triangleHeight;

//     // Create the path with a triangle at the top
//     path.moveTo(0, startY);
//     path.lineTo(triangleWidth / 2, 0);
//     path.lineTo(triangleWidth, startY);
//     path.lineTo(triangleWidth, size.height);
//     path.lineTo(0, size.height);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
