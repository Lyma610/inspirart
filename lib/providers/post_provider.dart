import 'package:flutter/material.dart';

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
}

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  String _selectedCategory = 'Todas';

  List<Post> get posts => _posts;
  List<Post> get filteredPosts => _filteredPosts;
  String get selectedCategory => _selectedCategory;

  PostProvider() {
    _loadSamplePosts();
  }

  void _loadSamplePosts() {
    _posts = [
      Post(
        id: '1',
        userId: 'user1',
        userName: 'ArtistaGrafite',
        userAvatar: 'https://via.placeholder.com/50',
        imageUrl: 'https://via.placeholder.com/400x500/6B46C1/FFFFFF?text=Grafite+Arte',
        caption: 'Nova obra de rua inspirada na cultura urbana! 🎨 #grafite #arte #rua',
        categories: const ['Grafite', 'Arte Urbana'],
        likes: 124,
        comments: 18,
        shares: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isLiked: false,
        isSaved: false,
      ),
      Post(
        id: '2',
        userId: 'user2',
        userName: 'FotógrafoPro',
        userAvatar: 'https://via.placeholder.com/50',
        imageUrl: 'https://via.placeholder.com/400x500/ED8936/FFFFFF?text=Fotografia',
        caption: 'Capturando momentos únicos da vida urbana 📸 #fotografia #arte #vida',
        categories: const ['Fotografia', 'Arte Digital'],
        likes: 89,
        comments: 12,
        shares: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isLiked: false,
        isSaved: false,
      ),
      Post(
        id: '3',
        userId: 'user3',
        userName: 'DesignerCriativo',
        userAvatar: 'https://via.placeholder.com/50',
        imageUrl: 'https://via.placeholder.com/400x500/38A169/FFFFFF?text=Design',
        caption: 'Novo conceito de design minimalista ✨ #design #minimalismo #criatividade',
        categories: const ['Design', 'Arte Digital'],
        likes: 156,
        comments: 24,
        shares: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isLiked: false,
        isSaved: false,
      ),
      Post(
        id: '4',
        userId: 'user4',
        userName: 'IlustradorArte',
        userAvatar: 'https://via.placeholder.com/50',
        imageUrl: 'https://via.placeholder.com/400x500/9F7AEA/FFFFFF?text=Ilustração',
        caption: 'Personagem criado com muito carinho 💕 #ilustração #arte #personagem',
        categories: const ['Ilustração', 'Arte Digital'],
        likes: 203,
        comments: 31,
        shares: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        isLiked: false,
        isSaved: false,
      ),
    ];
    _filteredPosts = _posts;
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'Todas') {
      _filteredPosts = _posts;
    } else {
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

  List<String> getCategories() {
    final categories = <String>{};
    for (final post in _posts) {
      categories.addAll(post.categories);
    }
    return ['Todas', ...categories];
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
