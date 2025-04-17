import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw (e.code);
    }
  }

  //sign up with email and password

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }


  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }


  //errors 
}