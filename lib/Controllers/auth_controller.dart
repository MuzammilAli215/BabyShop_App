import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _userRole; // 'user' or 'admin'
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _userRole == 'admin';

  // Check if user is already logged in
  void checkAuthStatus() {
    _user = _auth.currentUser;
    if (_user != null) {
      _loadUserRole();
    }
    notifyListeners();
  }

  // Load user role from Firestore
  Future<void> _loadUserRole() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      _userRole = doc.data()?['role'] ?? 'user';
      notifyListeners();
    } catch (e) {
      _userRole = 'user'; // Default to user if error
      notifyListeners();
    }
  }

  // Login method for both admin and user
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Sign in with Firebase Auth
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = result.user;

      // Load user role from Firestore
      if (_user != null) {
        await _loadUserRole();
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register method for users
  Future<bool> register(
      String name, String email, String password, String phone) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create user in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = result.user;

      if (_user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(_user!.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'user', // New users are always 'user' role
          'addresses': [],
          'paymentMethods': [],
          'isDisabled': false,
          'totalOrders': 0,
          'totalSpent': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        });

        _userRole = 'user';
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      _userRole = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error logging out';
      notifyListeners();
    }
  }

  // Forgot password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email.trim());

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user is disabled
  Future<bool> isUserDisabled() async {
    if (_user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.data()?['isDisabled'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get Firebase error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'User not found. Please check your email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different credentials.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      default:
        return 'Authentication error: $code';
    }
  }
}
