import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Fotografia',
    'Ilustração',
    'Design',
    'Arte Digital',
    'Grafite',
    'Arte Urbana',
    'Pintura',
    'Escultura',
  ];

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pesquisar'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Digite sua pesquisa...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            context.pop();
            // Implementar lógica de pesquisa
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pesquisando por: $value'),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Carregar usuários para descobrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text('Descobrir'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorias
          Container(
            height: 50,
            color: AppTheme.surfaceColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de artistas
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final users = userProvider.users;

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum artista encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: () => context.go('/user/${user.id}'),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: user.avatar.isNotEmpty
                                  ? NetworkImage(user.avatar)
                                  : null,
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              child: user.avatar.isEmpty
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Info do usuário
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.go('/user/${user.id}'),
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (user.followers > 1000)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              size: 12,
                                              color: AppTheme.primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Popular',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.bio,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                
                                // Categorias
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: user.categories.map((category) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          
                          // Botão de seguir
                          const SizedBox(width: 16),
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final isFollowing = userProvider.following.any((u) => u.id == user.id);
                              return ElevatedButton(
                                onPressed: () => userProvider.toggleFollow(user.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing ? AppTheme.surfaceColor : AppTheme.primaryColor,
                                  foregroundColor: isFollowing ? AppTheme.primaryColor : Colors.white,
                                  side: isFollowing ? BorderSide(color: AppTheme.primaryColor) : null,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: Text(isFollowing ? 'Seguindo' : 'Seguir'),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}