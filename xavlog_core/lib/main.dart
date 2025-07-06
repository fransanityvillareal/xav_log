import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:xavlog_core/features/login/log_in_main.dart';
import 'package:xavlog_core/features/login/account_choose.dart';
import 'package:xavlog_core/features/market_place/providers/product_provider.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/firebase_options.dart';
import 'package:xavlog_core/route/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xavlog_core/widget/bottom_nav_wrapper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await supabase.Supabase.initialize(
    url: 'https://hmhqztwsyyzujxgelveb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhtaHF6dHdzeXl6dWp4Z2VsdmViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTM0NTk2OSwiZXhwIjoyMDY2OTIxOTY5fQ._w35gtuLUCtIyQ1vmExgKuVmYkHJUAJ64Gw-JupRKvE',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                ProductProvider()), // Updated to use Firestore-backed ProductProvider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Jost',
          fontFamilyFallback: [
            'Rubik',
          ],
        ),
        home: AuthWrapper(),
        routes: {
          '/choose_account': (context) => const AccountChoosePage(),
          '/welcome': (context) =>
              const WelcomeScreen(), // Ensure the route is initialized
        },
      ),
    ),
  );
}

// Add this AuthWrapper class
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, go to home
          return const HomeWrapper(initialTab: 2);
        } else {
          // User is not logged in, go to login page
          return LoginPage();
        }
      },
    );
  }
}