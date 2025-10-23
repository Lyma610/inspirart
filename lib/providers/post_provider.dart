import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String imageUrl;
  final String caption;
  final List<String> categories;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final bool isLiked;
  final bool isSaved;

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.imageUrl,
    required this.caption,
    required this.categories,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
  });


  factory Post.fromJson(Map<String, dynamic> json) {
    // Construir URL para buscar imagem do backend
    String imageUrl = '';
    if (json['id'] != null) {
      imageUrl = 'https://tccbackend-completo.onrender.com/postagem/image/${json['id']}';
      print('Post ID: ${json['id']} - URL da imagem: $imageUrl');
    } else {
      print('Post sem ID - JSON: $json');
    }
    
    // Processar foto do usuário diretamente do JSON
    String userAvatar = '';
    if (json['usuario']?['foto'] != null) {
      print('Processando foto do usuário: ${json['usuario']['nome']}');
      print('Tipo da foto: ${json['usuario']['foto'].runtimeType}');
      try {
        if (json['usuario']['foto'] is List) {
          final fotoBytes = List<int>.from(json['usuario']['foto']);
          print('Foto como List - tamanho: ${fotoBytes.length} bytes');
          if (fotoBytes.isNotEmpty) {
            final base64String = base64Encode(fotoBytes);
            userAvatar = 'data:image/jpeg;base64,$base64String';
            print('Foto convertida para base64 - tamanho: ${base64String.length} caracteres');
          }
        } else if (json['usuario']['foto'] is String && json['usuario']['foto'].isNotEmpty) {
          final fotoString = json['usuario']['foto'] as String;
          print('Foto como String - tamanho: ${fotoString.length} caracteres');
          
          // Verificar se a string não é muito grande (limite de 500KB)
          if (fotoString.length > 500000) {
            print('Foto muito grande (${fotoString.length} caracteres), usando placeholder');
            userAvatar = '';
          } else if (fotoString.startsWith('data:image')) {
            userAvatar = fotoString;
            print('Foto já está em formato data:image');
          } else {
            userAvatar = 'data:image/jpeg;base64,$fotoString';
            print('Foto convertida para data:image/jpeg');
          }
        }
      } catch (e) {
        print('Erro ao processar foto do usuário: $e');
        userAvatar = '';
      }
    } else {
      print('Usuário ${json['usuario']?['nome']} não tem foto');
    }
    
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['usuario']?['id']?.toString() ?? '',
      userName: json['usuario']?['nome'] ?? 'Usuário',
      userAvatar: userAvatar,
      imageUrl: imageUrl,
      caption: json['descricao'] ?? '',
      categories: [json['categoria']?['nome'] ?? 'Geral'],
      likes: 0,
      comments: 0,
      shares: 0,
      createdAt: DateTime.tryParse(json['dataCadastro'] ?? '') ?? DateTime.now(),
    );
  }
}

class Category {
  final int id;
  final String nome;

  Category({required this.id, required this.nome});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
    );
  }
}

class Genre {
  final int id;
  final String nome;

  Genre({required this.id, required this.nome});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
    );
  }
}

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  List<Category> _categories = [];
  List<Genre> _genres = [];
  String _selectedCategory = 'Todas';
  bool _isLoading = false;
  
  // Rastrear posts curtidos e salvos pelo usuário atual
  Set<String> _userLikedPosts = <String>{};
  Set<String> _userSavedPosts = <String>{};
  
  // Inicializar Sets no construtor
  PostProvider() {
    _userLikedPosts = <String>{};
    _userSavedPosts = <String>{};
    loadPosts();
    loadCategories();
    loadGenres();
  }

  List<Post> get posts => _posts;
  List<Post> get filteredPosts => _filteredPosts;
  List<Category> get categories => _categories;
  List<Genre> get genres => _genres;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  
  // Getters para verificar likes e saves do usuário
  Set<String> get userLikedPosts => _userLikedPosts;
  Set<String> get userSavedPosts => _userSavedPosts;
  
  // Verificar se o usuário curtiu um post específico
  bool isPostLikedByUser(String postId) => _userLikedPosts.contains(postId);
  
  // Verificar se o usuário salvou um post específico
  bool isPostSavedByUser(String postId) => _userSavedPosts.contains(postId);


  Future<void> loadPosts() async {
    print('Carregando posts...');
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.getAllPosts();
      print('Resposta da API - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Posts recebidos: ${data.length}');
        
        if (data.isEmpty) {
          print('Nenhum post encontrado no backend');
          _posts = [];
          _filteredPosts = [];
        } else {
          _posts = data.map((json) {
            try {
              final post = Post.fromJson(json);
              print('Post processado - ID: ${post.id}, Usuário: ${post.userName}, Imagem: ${post.imageUrl}');
              return post;
            } catch (e) {
              print('Erro ao processar post: $e');
              print('JSON do post: $json');
              return null;
            }
          }).where((post) => post != null).cast<Post>().toList();
          _filteredPosts = _posts;
          print('Posts processados: ${_posts.length}');
        }
      } else {
        print('Erro na API - Status: ${response.statusCode}, Body: ${response.body}');
        _posts = [];
        _filteredPosts = [];
      }
    } catch (e) {
      print('Erro ao carregar posts: $e');
      print('Stack trace: ${StackTrace.current}');
      _posts = [];
      _filteredPosts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      
      // Carregar reações para todos os posts após carregar os posts
      if (_posts.isNotEmpty) {
        print('Carregando reações para ${_posts.length} posts...');
        await loadReactionsForAllPosts();
      }
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await ApiService.getCategories();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _categories = data.map((json) => Category.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar categorias: $e');
    }
  }

  Future<void> loadGenres() async {
    try {
      final response = await ApiService.getGenres();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _genres = data.map((json) => Genre.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar gêneros: $e');
    }
  }



  Future<void> loadPostsByCategory(int categoryId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.getPostsByCategory(categoryId);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _filteredPosts = data.map((json) => Post.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao carregar posts por categoria: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'Todas') {
      _filteredPosts = _posts;
    } else {
      final categoryObj = _categories.firstWhere(
        (c) => c.nome == category,
        orElse: () => Category(id: 0, nome: ''),
      );
      if (categoryObj.id > 0) {
        loadPostsByCategory(categoryObj.id);
        return;
      }
      _filteredPosts = _posts
          .where((post) => post.categories.contains(category))
          .toList();
    }
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      try {
        // Sempre criar uma nova reação (o backend vai gerenciar duplicatas)
        final response = await ApiService.createReaction(
          usuarioId: 1, // TODO: Pegar do AuthProvider
          postagemId: int.parse(postId),
          tipoReacao: 'CURTIR',
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Recarregar contadores do backend
          await _updatePostCounters(postId);
        }
      } catch (e) {
        print('Erro ao alternar like: $e');
      }
    }
  }

  void addPost(Post post) {
    _posts.insert(0, post);
    if (_selectedCategory == 'Todas' || post.categories.contains(_selectedCategory)) {
      _filteredPosts.insert(0, post);
    }
    notifyListeners();
  }

  List<String> getCategoryNames() {
    final categoryNames = _categories.map((c) => c.nome).toList();
    return ['Todas', ...categoryNames];
  }

  List<Post> getFilteredPosts(String query, String? category) {
    List<Post> posts = _posts;
    
    // Filtrar por categoria se especificada
    if (category != null && category != 'Todas') {
      posts = posts.where((post) => post.categories.contains(category)).toList();
    }
    
    // Filtrar por query de busca
    if (query.isNotEmpty) {
      posts = posts.where((post) =>
        post.userName.toLowerCase().contains(query.toLowerCase()) ||
        post.caption.toLowerCase().contains(query.toLowerCase()) ||
        post.categories.any((cat) => cat.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }
    
    return posts;
  }

  void incrementShares(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = Post(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userAvatar: post.userAvatar,
        imageUrl: post.imageUrl,
        caption: post.caption,
        categories: post.categories,
        likes: post.likes,
        comments: post.comments,
        shares: post.shares + 1,
        createdAt: post.createdAt,
        isLiked: post.isLiked,
        isSaved: post.isSaved,
      );
      
      // Atualizar também na lista filtrada
      final filteredIndex = _filteredPosts.indexWhere((post) => post.id == postId);
      if (filteredIndex != -1) {
        _filteredPosts[filteredIndex] = _posts[postIndex];
      }
      
      notifyListeners();
    }
  }

  Future<void> toggleSavePost(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      try {
        // Sempre criar uma nova reação (o backend vai gerenciar duplicatas)
        final response = await ApiService.createReaction(
          usuarioId: 1, // TODO: Pegar do AuthProvider
          postagemId: int.parse(postId),
          tipoReacao: 'SALVAR',
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Recarregar contadores do backend
          await _updatePostCounters(postId);
        }
      } catch (e) {
        print('Erro ao alternar salvar: $e');
      }
    }
  }

  // Criar nova postagem
  Future<bool> createPost({
    required String titulo,
    required String descricao,
    required int categoriaId,
    required int usuarioId,
    int? generoId,
    XFile? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.createPost(
        titulo: titulo,
        descricao: descricao,
        categoriaId: categoriaId,
        usuarioId: usuarioId,
        generoId: generoId,
        imageFile: imageFile,
      );
      
      if (response.statusCode == 200) {
        // Recarregar posts após criação
        await loadPosts();
        return true;
      } else if (response.statusCode == 500) {
        // Erro 500 - problema no servidor
        print('Erro 500: Problema no servidor - ${response.body}');
        return false;
      }
      return false;
    } catch (e) {
      print('Erro ao criar post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar comentário
  Future<bool> createComment({
    required int postagemId,
    required String comentario,
  }) async {
    try {
      final response = await ApiService.createReaction(
        usuarioId: 1, // TODO: Pegar do AuthProvider
        postagemId: postagemId,
        tipoReacao: 'COMENTAR',
        comentario: comentario,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recarregar contadores do backend
        await _updatePostCounters(postagemId.toString());
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao criar comentário: $e');
      return false;
    }
  }

  // Atualizar contadores de um post específico
  Future<void> _updatePostCounters(String postId) async {
    try {
      print('Atualizando contadores para post $postId');
      
      // Buscar reações específicas do post
      final response = await ApiService.getPostReactions(int.parse(postId));
      print('Resposta da API para post $postId: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('Total de reações encontradas: ${data.length}');
        
        // Filtrar reações específicas do post
        final postReacoes = data.where((reacao) => 
          reacao['postagem'] != null && 
          reacao['postagem']['id'] == int.parse(postId)
        ).toList();
        
        print('Reações específicas do post $postId: ${postReacoes.length}');
        
        // Contar likes e comentários ativos
        int likesCount = 0;
        int commentsCount = 0;
        bool userLiked = false;
        bool userSaved = false;
        
        for (var reacao in postReacoes) {
          if (reacao['statusReacao'] == 'ATIVO') {
            switch (reacao['tipoReacao']) {
              case 'CURTIR':
                likesCount++;
                // Verificar se o usuário atual curtiu
                if (reacao['usuario'] != null && reacao['usuario']['id'] == 1) {
                  userLiked = true;
                }
                break;
              case 'COMENTAR':
                commentsCount++;
                break;
              case 'SALVAR':
                // Verificar se o usuário atual salvou
                if (reacao['usuario'] != null && reacao['usuario']['id'] == 1) {
                  userSaved = true;
                }
                break;
            }
          }
        }
        
        print('Contadores para post $postId - Likes: $likesCount, Comentários: $commentsCount');
        
        // Atualizar post na lista principal
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _posts[postIndex];
          _posts[postIndex] = Post(
            id: post.id,
            userId: post.userId,
            userName: post.userName,
            userAvatar: post.userAvatar,
            imageUrl: post.imageUrl,
            caption: post.caption,
            categories: post.categories,
            likes: likesCount,
            comments: commentsCount,
            shares: post.shares,
            createdAt: post.createdAt,
            isLiked: userLiked,
            isSaved: userSaved,
          );
          
          // Atualizar sets de likes e saves do usuário
          print('Atualizando sets - userLiked: $userLiked, userSaved: $userSaved, postId: $postId');
          print('_userLikedPosts antes: $_userLikedPosts');
          print('_userSavedPosts antes: $_userSavedPosts');
          
          
          try {
            if (userLiked) {
              _userLikedPosts.add(postId);
              print('Adicionado $postId aos likes');
            } else {
              _userLikedPosts.remove(postId);
              print('Removido $postId dos likes');
            }
            
            if (userSaved) {
              _userSavedPosts.add(postId);
              print('Adicionado $postId aos saves');
            } else {
              _userSavedPosts.remove(postId);
              print('Removido $postId dos saves');
            }
            
            print('_userLikedPosts depois: $_userLikedPosts');
            print('_userSavedPosts depois: $_userSavedPosts');
          } catch (e) {
            print('Erro ao atualizar sets: $e');
            // Tentar reinicializar os Sets
            _userLikedPosts = <String>{};
            _userSavedPosts = <String>{};
            print('Sets reinicializados');
          }
          
          // Atualizar também na lista filtrada
          final filteredIndex = _filteredPosts.indexWhere((post) => post.id == postId);
          if (filteredIndex != -1) {
            _filteredPosts[filteredIndex] = _posts[postIndex];
          }
          
          print('Post $postId atualizado - Likes: $likesCount, Comentários: $commentsCount');
          notifyListeners();
        } else {
          print('Post $postId não encontrado na lista');
        }
      } else {
        print('Erro ao buscar reações do post $postId: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao atualizar contadores para post $postId: $e');
    }
  }

  // Remover post do estado local
  void removePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    _filteredPosts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  // Atualizar reações de todos os posts
  void updateReactions() {
    // Este método será chamado quando as reações forem carregadas
    // para sincronizar os estados dos posts
    notifyListeners();
  }

  // Carregar reações para todos os posts
  Future<void> loadReactionsForAllPosts() async {
    print('Carregando reações para todos os posts...');
    
    for (final post in _posts) {
      try {
        await _updatePostCounters(post.id);
      } catch (e) {
        print('Erro ao carregar reações para post ${post.id}: $e');
      }
    }
    
    notifyListeners();
  }

  // Excluir post via API
  Future<http.Response> deletePost(int postId) async {
    print('Excluindo post ID: $postId');
    try {
      final response = await ApiService.deletePost(postId);
      print('Resposta da exclusão - Status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Erro ao excluir post: $e');
      rethrow;
    }
  }
}
