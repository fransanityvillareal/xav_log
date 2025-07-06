import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xavlog_core/features/login/log_in_main.dart';
import 'package:xavlog_core/widget/bottom_nav_wrapper.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Check Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      
      // Also check SharedPreferences for additional login state
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      if (session != null && isLoggedIn) {
        // User is logged in, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User is not logged in, go to login page
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Error checking auth, default to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}