import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Simulação de login - em produção, isso seria uma chamada para API
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = email;
      _userName = email.split('@')[0];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', _userId!);
      await prefs.setString('userEmail', _userEmail!);
      await prefs.setString('userName', _userName!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> register(String email, String password, String name) async {
    // Simulação de registro - em produção, isso seria uma chamada para API
    _isAuthenticated = true;
    _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = email;
    _userName = name;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userId', _userId!);
    await prefs.setString('userEmail', _userEmail!);
    await prefs.setString('userName', _userName!);

    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    // Simulação de recuperação de senha - em produção, isso seria uma chamada para API
    await Future.delayed(const Duration(seconds: 2));
  }
} 