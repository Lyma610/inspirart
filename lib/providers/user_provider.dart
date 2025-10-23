import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final List<String> categories;
  final bool isFollowing;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    required this.categories,
    this.isFollowing = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String avatarUrl = '';
    
    // Verificar se há foto no formato de array de bytes (como no seu projeto web)
    if (json['foto'] != null) {
      try {
        // Se foto vem como array de bytes
        if (json['foto'] is List) {
          final fotoBytes = List<int>.from(json['foto']);
          if (fotoBytes.isNotEmpty) {
            // Converter bytes para base64
            final base64String = base64Encode(fotoBytes);
            avatarUrl = 'data:image/jpeg;base64,$base64String';
          }
        }
        // Se foto já vem como string base64
        else if (json['foto'] is String && json['foto'].isNotEmpty) {
          final fotoString = json['foto'] as String;
          // Verificar se já é um data URL
          if (fotoString.startsWith('data:image')) {
            avatarUrl = fotoString;
          } else {
            // Assumir que é base64 puro
            avatarUrl = 'data:image/jpeg;base64,$fotoString';
          }
        }
      } catch (e) {
        print('Erro ao processar foto do usuário: $e');
        // Fallback para string vazia
        avatarUrl = '';
      }
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      name: json['nome'] ?? '',
      email: json['email'] ?? '',
      avatar: avatarUrl,
      bio: json['bio'] ?? '',
      followers: 0, // Será implementado quando houver sistema de seguidores
      following: 0, // Será implementado quando houver sistema de seguidores
      posts: 0, // Será implementado quando houver contagem de posts
      categories: [], // Será implementado quando houver categorias de usuário
    );
  }
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  List<User> _followers = [];
  List<User> _following = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<User> get users => _users;
  List<User> get followers => _followers;
  List<User> get following => _following;
  bool get isLoading => _isLoading;

  UserProvider() {
    loadUsers();
    _loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    await _loadCurrentUser();
  }

  // Carregar usuários da API
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.getAllUsers();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((json) => User.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao carregar usuários: $e');
      // Fallback para dados de exemplo se a API falhar
      _loadSampleUsers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar usuário por ID
  Future<User?> getUserById(int id) async {
    try {
      final response = await ApiService.getUserById(id);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
    }
    return null;
  }

  // Editar perfil do usuário
  Future<bool> editProfile({
    required int id,
    required String nome,
    required String nivelAcesso,
    String? bio,
    String? email,
    String? senha,
    XFile? imageFile,
  }) async {
    print('Iniciando edição de perfil para usuário ID: $id');
    print('Nome: $nome, Bio: $bio, Tem imagem: ${imageFile != null}');
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Primeiro, tentar com a API
      final response = await ApiService.editUser(
        id: id,
        nome: nome,
        nivelAcesso: nivelAcesso,
        bio: bio,
        email: email,
        senha: senha,
        imageFile: imageFile,
      );
      
      print('Resposta da API - Status: ${response.statusCode}');
      print('Resposta da API - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('Perfil editado com sucesso via API!');
        // Recarregar usuários após edição
        await loadUsers();
        return true;
      } else {
        print('Erro na API - Status: ${response.statusCode}, Body: ${response.body}');
        // Fallback: atualizar dados localmente
        return _updateProfileLocally(id, nome, bio);
      }
    } catch (e) {
      print('Erro ao editar perfil via API: $e');
      print('Tentando atualização local...');
      // Fallback: atualizar dados localmente
      return _updateProfileLocally(id, nome, bio);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método de fallback para atualizar perfil localmente
  bool _updateProfileLocally(int id, String nome, String? bio) {
    try {
      // Atualizar o usuário atual se for o mesmo ID
      if (_currentUser != null && _currentUser!.id == id.toString()) {
        _currentUser = User(
          id: _currentUser!.id,
          name: nome,
          email: _currentUser!.email,
          avatar: _currentUser!.avatar,
          bio: bio ?? _currentUser!.bio,
          followers: _currentUser!.followers,
          following: _currentUser!.following,
          posts: _currentUser!.posts,
          categories: _currentUser!.categories,
        );
      }

      // Atualizar na lista de usuários
      final userIndex = _users.indexWhere((user) => user.id == id.toString());
      if (userIndex != -1) {
        _users[userIndex] = User(
          id: _users[userIndex].id,
          name: nome,
          email: _users[userIndex].email,
          avatar: _users[userIndex].avatar,
          bio: bio ?? _users[userIndex].bio,
          followers: _users[userIndex].followers,
          following: _users[userIndex].following,
          posts: _users[userIndex].posts,
          categories: _users[userIndex].categories,
        );
      }

      print('Perfil atualizado localmente com sucesso!');
      notifyListeners();
      return true;
    } catch (e) {
      print('Erro ao atualizar perfil localmente: $e');
      return false;
    }
  }

  // Alterar senha
  Future<bool> changePassword({
    required int id,
    required String novaSenha,
  }) async {
    try {
      final response = await ApiService.changePassword(
        id: id,
        novaSenha: novaSenha,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao alterar senha: $e');
      return false;
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Tentar carregar dados reais do usuário atual
      // Por enquanto, manter dados de exemplo até implementar autenticação completa
      // Usar uma imagem PNG transparente que será substituída pelo ícone
      final avatarUrl = '';
      
      _currentUser = User(
        id: 'current_user',
        name: 'Meu Perfil',
        email: 'meu@email.com',
        avatar: avatarUrl,
        bio: 'Artista apaixonado por criar e compartilhar arte digital 🎨',
        followers: 156,
        following: 89,
        posts: 23,
        categories: ['Arte Digital', 'Ilustração', 'Design'],
      );
      
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar usuário atual: $e');
      // Em caso de erro, usar dados padrão
      _currentUser = User(
        id: 'current_user',
        name: 'Usuário',
        email: 'usuario@email.com',
        avatar: '',
        bio: 'Bem-vindo ao Eteria!',
        followers: 0,
        following: 0,
        posts: 0,
        categories: [],
      );
      notifyListeners();
    }
  }

  void _loadSampleUsers() {
    _users = [
      User(
        id: 'user1',
        name: 'ArtistaGrafite',
        email: 'grafite@email.com',
        avatar: 'https://via.placeholder.com/100',
        bio: 'Especialista em arte urbana e grafite 🎨',
        followers: 1240,
        following: 89,
        posts: 67,
        categories: ['Grafite', 'Arte Urbana'],
      ),
      User(
        id: 'user2',
        name: 'FotógrafoPro',
        email: 'foto@email.com',
        avatar: 'https://via.placeholder.com/100',
        bio: 'Capturando momentos únicos através da lente 📸',
        followers: 892,
        following: 156,
        posts: 45,
        categories: ['Fotografia', 'Arte Digital'],
      ),
      User(
        id: 'user3',
        name: 'DesignerCriativo',
        email: 'design@email.com',
        avatar: 'https://via.placeholder.com/100',
        bio: 'Criando experiências visuais únicas ✨',
        followers: 1567,
        following: 234,
        posts: 89,
        categories: ['Design', 'Arte Digital'],
      ),
      User(
        id: 'user4',
        name: 'IlustradorArte',
        email: 'ilustra@email.com',
        avatar: 'https://via.placeholder.com/100',
        bio: 'Transformando ideias em arte visual 🎭',
        followers: 2034,
        following: 189,
        posts: 123,
        categories: ['Ilustração', 'Arte Digital'],
      ),
    ];

    _followers = _users.take(3).toList();
    _following = _users.take(2).toList();
    notifyListeners();
  }

  void toggleFollow(String userId) {
    // Não pode seguir a si mesmo
    if (userId == _currentUser?.id) return;

    final userIndex = _users.indexWhere((user) => user.id == userId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      final isCurrentlyFollowing = user.isFollowing;
      final newFollowers = isCurrentlyFollowing ? user.followers - 1 : user.followers + 1;
      
      // Atualiza o usuário na lista principal
      _users[userIndex] = User(
        id: user.id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
        bio: user.bio,
        followers: newFollowers,
        following: user.following,
        posts: user.posts,
        categories: user.categories,
        isFollowing: !isCurrentlyFollowing,
      );

      // Atualizar listas de seguidores/seguindo
      _updateFollowLists(userId, !isCurrentlyFollowing);
      
      // Atualiza o contador de following do usuário atual
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          avatar: _currentUser!.avatar,
          bio: _currentUser!.bio,
          followers: _currentUser!.followers,
          following: isCurrentlyFollowing ? _currentUser!.following - 1 : _currentUser!.following + 1,
          posts: _currentUser!.posts,
          categories: _currentUser!.categories,
        );
      }

      notifyListeners();
    }
  }

  void _updateFollowLists(String userId, bool isFollowing) {
    final user = _users.firstWhere((u) => u.id == userId);
    
    if (isFollowing) {
      // Adiciona à lista de seguindo apenas se ainda não estiver lá
      if (!_following.any((u) => u.id == userId)) {
        _following.add(user);
      }
    } else {
      // Remove da lista de seguindo
      _following.removeWhere((u) => u.id == userId);
    }
  }

  void updateProfile({
    String? name,
    String? bio,
    String? avatar,
  }) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: _currentUser!.email,
        avatar: avatar ?? _currentUser!.avatar,
        bio: bio ?? _currentUser!.bio,
        followers: _currentUser!.followers,
        following: _currentUser!.following,
        posts: _currentUser!.posts,
        categories: _currentUser!.categories,
      );
      notifyListeners();
    }
  }

  User? getUserByIdFromList(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;
    return _users
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.bio.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
} 