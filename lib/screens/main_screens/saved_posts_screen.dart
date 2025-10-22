import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/reacao_provider.dart';
import '../../utils/app_theme.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar posts e reações salvos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final reacaoProvider = Provider.of<ReacaoProvider>(context, listen: false);
      
      // Conectar os providers
      reacaoProvider.setPostProvider(postProvider);
      
      postProvider.loadPosts();
      reacaoProvider.loadReacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text('Posts salvos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Consumer2<PostProvider, ReacaoProvider>(
        builder: (context, postProvider, reacaoProvider, child) {
          // Buscar posts salvos usando ReacaoProvider
          final savedPostIds = reacaoProvider.getSavedPostIds(1); // TODO: Pegar ID do usuário atual
          final savedPosts = postProvider.posts.where((post) => 
            savedPostIds.contains(int.parse(post.id))
          ).toList();
          
          if (savedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum post salvo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posts que você salvar aparecerão aqui',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              return _buildSavedPost(savedPosts[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSavedPost(dynamic post) {
    return GestureDetector(
      onTap: () => context.go('/post/${post.id}'),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: post.imageUrl.isNotEmpty
                        ? Image.network(
                            post.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                                child: const Icon(Icons.image, size: 40),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.image, size: 40),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.bookmark),
                      color: AppTheme.primaryColor,
                      onPressed: () {
                        _removeFromSaved(post.id);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Informações
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar e nome do usuário
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: post.userAvatar.isNotEmpty
                            ? NetworkImage(post.userAvatar)
                            : null,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: post.userAvatar.isEmpty
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Estatísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(Icons.favorite_border, '${post.likes}'),
                      _buildStat(Icons.comment_outlined, '${post.comments}'),
                      _buildStat(Icons.share_outlined, '0'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  void _removeFromSaved(String postId) {
    Provider.of<PostProvider>(context, listen: false).toggleSavePost(postId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post removido dos salvos'),
        backgroundColor: Colors.green,
      ),
    );
  }
}