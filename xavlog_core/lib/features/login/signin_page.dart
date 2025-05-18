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

class _SigninPageState extends State<SigninPage>
    with SingleTickerProviderStateMixin {
  // final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  late final AnimationController _entranceController;
  late final Animation<Offset> _logoOffsetAnim;
  late final Animation<Offset> _cardOffsetAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _logoOffsetAnim = Tween<Offset>(
      begin: const Offset(0, -0.7),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _cardOffsetAnim = Tween<Offset>(
      begin: const Offset(0, 0.7),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    // Ensure the animation starts after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _loadSavedCredentials() async {
  //   try {
  //     final email = await _storage.read(key: 'saved_email');
  //     final password = await _storage.read(key: 'saved_password');

  //     if (email != null && password != null) {
  //       setState(() {
  //         _emailController.text = email;
  //         _passwordController.text = password;
  //         _rememberMe = true;
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading credentials: $e');
  //   }
  // }

  // Future<void> _handleSignIn() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => _isLoading = true);

  // //   try {
  // //     // Simulate authentication
  // //     await Future.delayed(const Duration(seconds: 1));

  // //     if (_rememberMe) {
  // //       await _storage.write(
  // //         key: 'saved_email',
  // //         value: _emailController.text,
  // //       );
  // //       await _storage.write(
  // //         key: 'saved_password',
  // //         value: _passwordController.text,
  // //       );
  // //     } else {
  // //       await _storage.delete(key: 'saved_email');
  // //       await _storage.delete(key: 'saved_password');
  // //     }

  // //     if (!mounted) return;
  // //     Navigator.pushReplacement(
  // //       context,
  // //       MaterialPageRoute(
  // //         builder: (context) => const AccountChoosePage(),
  // //       ),
  // //     );
  // //   } catch (e) {
  // //     if (!mounted) return;
  // //     ScaffoldMessenger.of(context).showSnackBar(
  // //       SnackBar(
  // //         content: Text('Sign in failed: ${e.toString()}'),
  // //         backgroundColor: Colors.red,
  // //       ),
  // //     );
  // //   } finally {
  // //     if (mounted) {
  // //       setState(() => _isLoading = false);
  // //     }
  // //   }
  // // }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadSavedCredentials();
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF132BB2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 40),
                    SlideTransition(
                      position: _logoOffsetAnim,
                      child: Hero(
                        tag: 'app-logo',
                        child: Image.asset(
                          'assets/images/fulllogo.png',
                          width: size.width * 0.5,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.account_circle, size: 100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

                // Sign-in card
                SlideTransition(
                  position: _cardOffsetAnim,
                  child: AnimatedSlide(
                    offset: _isLoading ? const Offset(0, 0.04) : Offset.zero,
                    duration: const Duration(milliseconds: 2500), // much longer
                    curve: Curves.easeInOutCubic,
                    child: AnimatedScale(
                      scale: _isLoading ? 0.98 : 1.0,
                      duration:
                          const Duration(milliseconds: 1800), // much longer
                      curve: Curves.easeInOutCubic,
                      child: Container(
                        width: size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.12),
                            width: 1.2,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    // Button Text
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 32,
                                    letterSpacing: 1.1,
                                    color: const Color.fromARGB(255, 0, 0, 0), // or Theme.of(context).primaryColor
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    errorStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.redAccent),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Remember me checkbox
                                Row(
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        unselectedWidgetColor: Colors.grey,
                                      ),
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor:
                                            const Color(0xFFBFA547), // Gold
                                        checkColor: Colors.white,
                                        side:
                                            MaterialStateBorderSide.resolveWith(
                                                (states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return const BorderSide(
                                                color: Color(0xFF003A70),
                                                width:
                                                    2); // Blue border when checked
                                          }
                                          return const BorderSide(
                                              color: Colors.grey, width: 1.5);
                                        }),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    const Text('Remember me'),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        // Add forgot password functionality
                                      },
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Sign in button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() => _isLoading = true);
                                              // Placeholder for backend authentication
                                              await Future.delayed(
                                                  const Duration(seconds: 1));
                                              if (!mounted) return;
                                              setState(
                                                  () => _isLoading = false);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AccountChoosePage(),
                                                ),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: const Color(0xFFBFA547),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              fontFamily: 'Jost',
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Please use your assigned GBOX account to sign in',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Login link
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LoginPage(onTap: () {}),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Log in to my account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer links
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsAndConditions(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: const Text('Terms & Conditions'),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FAQs(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: const Text('FAQs'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
