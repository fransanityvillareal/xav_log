import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/features/login/account_choose.dart';
import 'package:xavlog_core/widget/bottom_nav_wrapper.dart';
import 'package:xavlog_core/features/login/signin_page.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get getCurrentUser {
    return _auth.currentUser;
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      // Validate email domain
      if (!email.endsWith('@gbox.adnu.edu.ph')) {
        showDomainErrorPopup(context);
        return null;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final userDoc = await _firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String? firstName = userDoc.data()?['firstName'];

        // Check if firstName is null
        if (firstName == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AccountChoosePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeWrapper(initialTab: 0)),
          );
        }
      } else {
        // Initialize user data for new users
        await _firestore.collection('Users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
        }, SetOptions(merge: true));

        // Navigate to SigninPage for new users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SigninPage(onTap: () {})),
        );
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw (e.code);
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      // Validate email domain
      if (!email.endsWith('@gbox.adnu.edu.ph')) {
        showDomainErrorPopup(context);
        return Future.error('Invalid email domain');
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user info
      _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Show domain error popup
  void showDomainErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Email Domain'),
          content: const Text(
              'Please use your GBox email (@adnu.edu.ph) to sign in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
