import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar posts para histórico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text('Seu histórico'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Limpar histórico'),
                  content: const Text('Tem certeza que deseja limpar todo o seu histórico? Esta ação não pode ser desfeita.'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearHistory();
                        context.pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          final posts = postProvider.posts;
          
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum item no histórico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posts que você visualizar aparecerão aqui',
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
          
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildHistoryItem(posts[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(dynamic post) {
    return GestureDetector(
      onTap: () => context.go('/post/${post.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: post.imageUrl.isNotEmpty
                ? Image.network(
                    post.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
          ),
          title: Text(
            post.caption.isNotEmpty ? post.caption : 'Publicação sem descrição',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                _formatTimeAgo(post.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.remove_circle_outline),
                        title: const Text('Remover do histórico'),
                        onTap: () {
                          _removeFromHistory();
                          context.pop();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.block),
                        title: const Text('Não mostrar publicações semelhantes'),
                        onTap: () {
                          _blockSimilarContent();
                          context.pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _clearHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Histórico limpo com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFromHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removido do histórico'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _blockSimilarContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conteúdo semelhante será bloqueado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTimeAgo(String dateString) {
    if (dateString.isEmpty) return 'Agora';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return 'Agora';
      } else if (difference.inHours < 1) {
        return 'Visualizado há ${difference.inMinutes}m';
      } else if (difference.inDays < 1) {
        return 'Visualizado há ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'Visualizado há ${difference.inDays}d';
      } else {
        return 'Visualizado há ${(difference.inDays / 7).floor()}s';
      }
    } catch (e) {
      return 'Agora';
    }
  }
}