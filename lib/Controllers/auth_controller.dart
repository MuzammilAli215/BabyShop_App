


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _Firestore = FirebaseFirestore.instance;

  //Signup

  Future<String> signupUser(String username, String email,
      String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _Firestore.collection("users").doc(userCredential.user!.uid).set({
        "Uid": userCredential.user!.uid,
        "email": email,
        "role": "user"
      });
      return "User Created Successful";
    } catch (e) {
      return e.toString();
    }
  }

  //Login

  Future<String> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "User Logged in Successful";
    } catch (e) {
      return e.toString();
    }
  }


  //Forget password

  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset email sent successfully";
    } catch (e) {
      return e.toString();
    }
  }


  //Logout
  Future<String> logoutUser() async {
    try {
      await _auth.signOut();
      return "User Logged Out Successful";
    } catch (e) {
      return e.toString();
    }
  }
}



