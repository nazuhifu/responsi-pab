import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isFirstTime = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isFirstTime => _isFirstTime;

  AuthProvider() {
    _loadUserFromStorage();
    _checkFirstTime();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      // In a real app, you would parse the JSON and create a User object
      _user = User(
        id: '1',
        name: 'Demo User',
        email: 'demo@solhome.com',
        phone: '+1 (555) 123-4567',
      );
      notifyListeners();
    }
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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Demo credentials
      if (email == 'demo@solhome.com' && password == 'password') {
        _user = User(
          id: '1',
          name: 'Demo User',
          email: email,
          phone: '+1 (555) 123-4567',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', 'demo_user_data');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: '',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', 'demo_user_data');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email, String phone) async {
    if (_user != null) {
      _user = _user!.copyWith(name: name, email: email, phone: phone);
      notifyListeners();
    }
  }
}
