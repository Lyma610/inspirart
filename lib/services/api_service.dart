import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.getBaseUrl();
  
  // Testar conectividade com o backend
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/usuario/findAll');
      print('Testando conexão com: $url');
      final response = await http.get(url);
      print('Teste de conexão - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Erro no teste de conexão: $e');
      return false;
    }
  }

  // Testar se usuário tem foto
  static Future<bool> testUserHasPhoto(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/usuario/findById/$userId');
      print('Testando se usuário tem foto: $url');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hasPhoto = data['foto'] != null && 
                        (data['foto'] is List ? (data['foto'] as List).isNotEmpty : 
                         data['foto'].toString().isNotEmpty);
        print('Usuário tem foto: $hasPhoto');
        return hasPhoto;
      }
      return false;
    } catch (e) {
      print('Erro no teste de foto do usuário: $e');
      return false;
    }
  }

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
    int? generoId,
    XFile? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/postagem/create');
    
    var request = http.MultipartRequest('POST', url);
    
    // Adicionar campos do formulário conforme esperado pelo backend
    request.fields['legenda'] = titulo;
    request.fields['descricao'] = descricao;
    request.fields['categoria.id'] = categoriaId.toString();
    request.fields['usuario.id'] = usuarioId.toString();
    
    // Adicionar genero.id se fornecido
    if (generoId != null) {
      request.fields['genero.id'] = generoId.toString();
    }
    
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

  // ========== MÉTODOS PARA USUÁRIO ==========
  
  // Buscar usuário por ID
  static Future<http.Response> getUserById(int id) async {
    final url = Uri.parse('$baseUrl/usuario/findById/$id');
    final response = await http.get(url);
    return response;
  }

  // Buscar todos os usuários
  static Future<http.Response> getAllUsers() async {
    final url = Uri.parse('$baseUrl/usuario/findAll');
    final response = await http.get(url);
    return response;
  }

  // Buscar usuários ativos
  static Future<http.Response> getActiveUsers() async {
    final url = Uri.parse('$baseUrl/usuario/findAllAtivos');
    final response = await http.get(url);
    return response;
  }

  // Criar usuário (com senha padrão)
  static Future<http.Response> createUser({
    required String nome,
    required String email,
    required String nivelAcesso,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'nivelAcesso': nivelAcesso,
      }),
    );
    return response;
  }

  // Editar usuário
  static Future<http.Response> editUser({
    required int id,
    required String nome,
    required String nivelAcesso,
    String? bio,
    String? email,
    String? senha,
    XFile? imageFile,
  }) async {
    print('API: Editando usuário ID: $id');
    print('API: Nome: $nome, Bio: $bio, Tem imagem: ${imageFile != null}');
    
    final url = Uri.parse('$baseUrl/usuario/editar/$id');
    print('API: URL: $url');
    
    var request = http.MultipartRequest('PUT', url);
    
    request.fields['nome'] = nome;
    request.fields['nivelAcesso'] = nivelAcesso;
    if (bio != null && bio.isNotEmpty) {
      request.fields['bio'] = bio;
    }
    if (email != null && email.isNotEmpty) {
      request.fields['email'] = email;
    }
    if (senha != null && senha.isNotEmpty) {
      request.fields['senha'] = senha;
    }
    
    if (imageFile != null) {
      try {
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ));
        print('API: Arquivo de imagem adicionado: ${imageFile.name}');
      } catch (e) {
        print('API: Erro ao ler arquivo de imagem: $e');
        throw Exception('Erro ao processar imagem: $e');
      }
    }
    
    try {
      print('API: Enviando requisição...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('API: Resposta recebida - Status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('API: Erro na requisição: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  // Alterar senha
  static Future<http.Response> changePassword({
    required int id,
    required String novaSenha,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/alterarSenha/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'senha': novaSenha,
      }),
    );
    return response;
  }

  // Inativar usuário
  static Future<http.Response> deactivateUser(int id) async {
    final url = Uri.parse('$baseUrl/usuario/inativar/$id');
    final response = await http.put(url);
    return response;
  }

  // ========== MÉTODOS PARA MENSAGEM ==========
  
  // Buscar mensagem por ID
  static Future<http.Response> getMessageById(int id) async {
    final url = Uri.parse('$baseUrl/mensagem/findById/$id');
    final response = await http.get(url);
    return response;
  }

  // Buscar todas as mensagens
  static Future<http.Response> getAllMessages() async {
    final url = Uri.parse('$baseUrl/mensagem/findAll');
    final response = await http.get(url);
    return response;
  }

  // Buscar mensagens por email
  static Future<http.Response> getMessagesByEmail(String email) async {
    final url = Uri.parse('$baseUrl/mensagem/findByEmail/$email');
    final response = await http.get(url);
    return response;
  }

  // Buscar mensagens ativas
  static Future<http.Response> getActiveMessages() async {
    final url = Uri.parse('$baseUrl/mensagem/findAllAtivos');
    final response = await http.get(url);
    return response;
  }

  // Enviar mensagem
  static Future<http.Response> sendMessage({
    required String nome,
    required String email,
    required String assunto,
    required String mensagem,
  }) async {
    final url = Uri.parse('$baseUrl/mensagem/save');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'assunto': assunto,
        'mensagem': mensagem,
      }),
    );
    return response;
  }

  // Inativar mensagem
  static Future<http.Response> deactivateMessage(int id) async {
    final url = Uri.parse('$baseUrl/mensagem/inativar/$id');
    final response = await http.put(url);
    return response;
  }

  // ========== MÉTODOS PARA REAÇÃO ==========
  
  // Buscar reação por ID
  static Future<http.Response> getReactionById(int id) async {
    final url = Uri.parse('$baseUrl/reacao/findById/$id');
    final response = await http.get(url);
    return response;
  }

  // Buscar todas as reações
  static Future<http.Response> getAllReactions() async {
    final url = Uri.parse('$baseUrl/reacao/findAll');
    final response = await http.get(url);
    return response;
  }

  // Criar reação (like/save/comentário)
  static Future<http.Response> createReaction({
    required int usuarioId,
    required int postagemId,
    required String tipoReacao,
    String? comentario,
  }) async {
    final url = Uri.parse('$baseUrl/reacao/create');
    final body = {
      'usuario': {'id': usuarioId},
      'postagem': {'id': postagemId},
      'tipoReacao': tipoReacao,
    };
    
    if (comentario != null && comentario.isNotEmpty) {
      body['comentario'] = comentario;
    }
    
    print('API: Criando reação - URL: $url');
    print('API: Body: ${jsonEncode(body)}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('API: Resposta da reação - Status: ${response.statusCode}');
      print('API: Resposta da reação - Body: ${response.body}');
      return response;
    } catch (e) {
      print('API: Erro ao criar reação: $e');
      rethrow;
    }
  }

  // Buscar reações de um post específico
  static Future<http.Response> getPostReactions(int postagemId) async {
    // Como o backend pode não ter o endpoint específico, vamos buscar todas e filtrar
    final url = Uri.parse('$baseUrl/reacao/findAll');
    final response = await http.get(url);
    print('API: Buscando reações do post $postagemId - URL: $url');
    print('API: Status: ${response.statusCode}');
    return response;
  }

  // Inativar reação
  static Future<http.Response> deactivateReaction(int id) async {
    final url = Uri.parse('$baseUrl/reacao/inativar/$id');
    final response = await http.put(url);
    return response;
  }

  // ========== MÉTODOS PARA CATEGORIA ==========
  
  // Buscar categoria por ID
  static Future<http.Response> getCategoryById(int id) async {
    final url = Uri.parse('$baseUrl/categoria/findById/$id');
    final response = await http.get(url);
    return response;
  }

  // Buscar todas as categorias
  static Future<http.Response> getAllCategories() async {
    final url = Uri.parse('$baseUrl/categoria/findAll');
    final response = await http.get(url);
    return response;
  }

  // Excluir postagem
  static Future<http.Response> deletePost(int postId) async {
    final url = Uri.parse('$baseUrl/postagem/delete/$postId');
    final response = await http.delete(url);
    return response;
  }
}
