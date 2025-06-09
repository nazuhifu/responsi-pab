import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  bool _isFirstTime = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isFirstTime => _isFirstTime;

  AuthProvider() {
    _loadUserFromFirebase();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    _isFirstTime = false;
    notifyListeners();
  }

  Future<void> _loadUserFromFirebase() async {
    final fbUser = _auth.currentUser;
    if (fbUser != null) {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (doc.exists) {
        _user = User.fromJson(doc.data()!);
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        final doc = await _firestore.collection('users').doc(fbUser.uid).get();
        if (doc.exists) {
          _user = User.fromJson(doc.data()!);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Login Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      await credential.user?.reload(); // memastikan displayName langsung update
      final fbUser = _auth.currentUser;

      if (fbUser != null) {
        final newUser = User(
          id: fbUser.uid,
          name: name,
          email: fbUser.email ?? email,
          phone: fbUser.phoneNumber ?? '',
          avatar: fbUser.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());

        _user = newUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Register Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email, String phone) async {
    if (_user != null) {
      await _auth.currentUser?.updateDisplayName(name);

      _user = _user!.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      await _firestore.collection('users').doc(_user!.id).update(_user!.toJson());

      notifyListeners();
    }
  }
}
