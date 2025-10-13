import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  // Registro de usuário
  static Future<http.Response> registerUser({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/save');
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
    final url = Uri.parse('$baseUrl/usuario/login');
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

  // Buscar todas as postagens
  static Future<http.Response> getAllPosts() async {
    final url = Uri.parse('$baseUrl/postagem/findAll');
    final response = await http.get(url);
    return response;
  }

  // Buscar postagem por ID
  static Future<http.Response> getPostById(int id) async {
    final url = Uri.parse('$baseUrl/postagem/findById/$id');
    final response = await http.get(url);
    return response;
  }

  // Buscar categorias
  static Future<http.Response> getCategories() async {
    final url = Uri.parse('$baseUrl/postagem/findCategorias');
    final response = await http.get(url);
    return response;
  }

  // Buscar gêneros
  static Future<http.Response> getGenres() async {
    final url = Uri.parse('$baseUrl/postagem/findGeneros');
    final response = await http.get(url);
    return response;
  }

  // Buscar postagens por categoria
  static Future<http.Response> getPostsByCategory(int categoryId) async {
    final url = Uri.parse('$baseUrl/postagem/findByCategoria/$categoryId');
    final response = await http.get(url);
    return response;
  }

  // Buscar postagens por gênero
  static Future<http.Response> getPostsByGenre(int genreId) async {
    final url = Uri.parse('$baseUrl/postagem/findByGenero/$genreId');
    final response = await http.get(url);
    return response;
  }

  // Buscar postagens por categoria e gênero
  static Future<http.Response> getPostsByCategoryAndGenre(int categoryId, int genreId) async {
    final url = Uri.parse('$baseUrl/postagem/findByCategoriaAndGenero/$categoryId/$genreId');
    final response = await http.get(url);
    return response;
  }

  // Criar postagem
  static Future<http.Response> createPost({
    required String titulo,
    required String descricao,
    required int categoriaId,
    required int usuarioId,
    XFile? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/postagem/create');
    
    var request = http.MultipartRequest('POST', url);
    
    // Adicionar campos do formulário
    request.fields['titulo'] = titulo;
    request.fields['descricao'] = descricao;
    request.fields['categoria.id'] = categoriaId.toString();
    request.fields['usuario.id'] = usuarioId.toString();}
    
    // Adicionar arquivo se fornecido
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ));
    }
    
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // Buscar imagem da postagem
  static Future<http.Response> getPostImage(int postId) async {
    final url = Uri.parse('$baseUrl/postagem/image/$postId');
    final response = await http.get(url);
    return response;
  }
}
