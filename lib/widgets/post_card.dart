import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/post_provider.dart';
import '../utils/app_theme.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do post
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/user/${post.userId}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(post.userAvatar),
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/user/${post.userId}'),
                        child: Text(
                          post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    _showPostOptions(context);
                  },
                ),
              ],
            ),
          ),
          
          // Imagem do post
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(post.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Ações do post
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botões de ação
                Row(
                  children: [
                    Consumer<PostProvider>(
                      builder: (context, postProvider, child) {
                        return IconButton(
                          icon: Icon(
                            post.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: post.isLiked ? Colors.red : null,
                          ),
                          onPressed: () {
                            postProvider.toggleLike(post.id);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {
                        // Navegar para a tela do post com foco nos comentários
                        context.go('/post/${post.id}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {
                        Share.share('Confira esta arte incrível no Inspirart!');
                        // Atualizar contador de compartilhamentos
                        Provider.of<PostProvider>(context, listen: false)
                          .incrementShares(post.id);
                      },
                    ),
                    const Spacer(),
                    Consumer<PostProvider>(
                      builder: (context, postProvider, child) {
                        return IconButton(
                          icon: Icon(
                            post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: post.isSaved ? AppTheme.primaryColor : null,
                          ),
                          onPressed: () {
                            postProvider.toggleSavePost(post.id);
                          },
                        );
                      },
                    ),
                  ],
                ),
                
                // Contadores
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${post.likes} curtidas',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Legenda
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.go('/user/${post.userId}'),
                          child: Text(
                            post.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Categorias
                Wrap(
                  spacing: 8,
                  children: post.categories.map((category) {
                    return Chip(
                      label: Text(
                        category,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 8),
                
                // Comentários
                GestureDetector(
                  onTap: () => context.go('/post/${post.id}'),
                  child: Text(
                    'Ver todos os ${post.comments} comentários',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Reportar'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Reportar Post'),
                    content: Text('Você tem certeza que deseja reportar este post?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Post reportado com sucesso'))
                          );
                        },
                        child: Text('Reportar'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar link'),
              onTap: () async {
                Navigator.pop(context);
                await Clipboard.setData(ClipboardData(text: 'https://inspirart.app/post/${post.id}'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Link copiado para a área de transferência'))
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
} 