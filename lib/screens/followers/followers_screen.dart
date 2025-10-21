import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Carregar dados de seguidores
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Seguidores'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Seguidores'),
            Tab(text: 'Seguindo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowersTab(),
          _buildFollowingTab(),
        ],
      ),
    );
  }

  Widget _buildFollowersTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final followers = userProvider.followers;
        
        if (followers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum seguidor ainda',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quando pessoas começarem a seguir você, elas aparecerão aqui',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: followers.length,
          itemBuilder: (context, index) {
            final user = followers[index];
            return _buildUserCard(user, false);
          },
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final following = userProvider.following;
        
        if (following.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 64,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Você não está seguindo ninguém',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comece a seguir artistas para ver suas obras no seu feed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.go('/discover');
                  },
                  child: const Text('Descobrir Artistas'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: following.length,
          itemBuilder: (context, index) {
            final user = following[index];
            return _buildUserCard(user, true);
          },
        );
      },
    );
  }

  Widget _buildUserCard(User user, bool isFollowing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar do usuário
            CircleAvatar(
              radius: 30,
              backgroundImage: user.avatar.isNotEmpty
                  ? NetworkImage(user.avatar)
                  : null,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: user.avatar.isEmpty
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Informações do usuário
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
                  
                  // Estatísticas
                  Row(
                    children: [
                      _buildUserStat('${user.posts} posts'),
                      const SizedBox(width: 16),
                      _buildUserStat('${user.followers} seguidores'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botão de ação
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return ElevatedButton(
                  onPressed: () {
                    userProvider.toggleFollow(user.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.isFollowing 
                        ? AppTheme.textSecondaryColor 
                        : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    minimumSize: const Size(100, 40),
                  ),
                  child: Text(
                    user.isFollowing ? 'Seguindo' : 'Seguir',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStat(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: AppTheme.textSecondaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
} 