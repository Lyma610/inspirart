import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

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
      imageUrl = 'http://localhost:8080/postagem/image/${json['id']}';
    }
    
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['usuario']?['id']?.toString() ?? '',
      userName: json['usuario']?['nome'] ?? 'Usuário',
      userAvatar: 'https://via.placeholder.com/50',
      imageUrl: imageUrl.isEmpty ? 'https://via.placeholder.com/400x500' : imageUrl,
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

  List<Post> get posts => _posts;
  List<Post> get filteredPosts => _filteredPosts;
  List<Category> get categories => _categories;
  List<Genre> get genres => _genres;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  PostProvider() {
    loadPosts();
    loadCategories();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.getAllPosts();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _posts = data.map((json) => Post.fromJson(json)).toList();
        _filteredPosts = _posts;
      }
    } catch (e) {
      print('Erro ao carregar posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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

  void toggleLike(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final newLikes = post.isLiked ? post.likes - 1 : post.likes + 1;
      _posts[postIndex] = Post(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userAvatar: post.userAvatar,
        imageUrl: post.imageUrl,
        caption: post.caption,
        categories: post.categories,
        likes: newLikes,
        comments: post.comments,
        shares: post.shares,
        createdAt: post.createdAt,
        isLiked: !post.isLiked,
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

  void toggleSavePost(String postId) {
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
        shares: post.shares,
        createdAt: post.createdAt,
        isLiked: post.isLiked,
        isSaved: !post.isSaved,
      );
      
      // Atualizar também na lista filtrada
      final filteredIndex = _filteredPosts.indexWhere((post) => post.id == postId);
      if (filteredIndex != -1) {
        _filteredPosts[filteredIndex] = _posts[postIndex];
      }
      
      notifyListeners();
    }
  }
}
