import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Troque pela URL do seu backend
  static const String baseUrl = 'http://localhost:8080/usuario';

  // Registro de usuário
  static Future<http.Response> registerUser({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/save');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );
    return response;
  }

  // Login de usuário
  static Future<http.Response> loginUser({
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );
    return response;
  }
}
