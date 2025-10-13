import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'dart:io';

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

  // Verifica o status de autenticação ao iniciar o app
  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    notifyListeners();
  }

  // Função de login que chama a API
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.loginUser(email: email, senha: password);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _userId = responseData['id']?.toString() ?? '';
        _userEmail = responseData['email'] ?? email;
        _userName = responseData['nome'] ?? responseData['name'] ?? 'Usuário';

        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userId', _userId!);
        await prefs.setString('userEmail', _userEmail!);
        await prefs.setString('userName', _userName!);

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  // Função de registro que chama a API
 Future<void> register(String email, String password, String name) async {
  try {
    final response = await ApiService.registerUser(nome: name, email: email, senha: password);

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // final responseData = jsonDecode(response.body);
      // _userId = responseData['id'];
      // _userEmail = responseData['email'];
      // _userName = responseData['name'];

      

      _isAuthenticated = true;

      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('isAuthenticated', true);
      // await prefs.setString('userId', _userId!);
      // await prefs.setString('userEmail', _userEmail!);
      // await prefs.setString('userName', _userName!);

      notifyListeners();
    } else {
      throw Exception('Falha no registro');
    }
  } catch (e, stacktrace) {
    print('Erro no registro: $e');
    print('Stacktrace: $stacktrace');
    throw Exception('Erro ao registrar usuário');
  }
}


  // Função para realizar logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // Função de recuperação de senha - ainda precisa ser implementada
//   Future<void> forgotPassword(String email) async {
//     try {
//       // Chamada para a API de recuperação de senha
//       await ApiService.forgotPassword(email: email); // Você pode implementar a função na sua API
//     } catch (e) {
//       print('Erro na recuperação de senha: $e');
//     }
//   }
 }
