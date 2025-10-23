import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/post_provider.dart';
import '../../widgets/comment_section.dart';
import '../../widgets/cached_image.dart';
import '../../utils/app_theme.dart';

class PostScreen extends StatefulWidget {
  final String postId;
  
  const PostScreen({super.key, required this.postId});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
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
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPostOptions();
            },
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          final post = postProvider.posts.firstWhere(
            (p) => p.id == widget.postId,
            orElse: () => postProvider.posts.first,
          );
          
          if (post == null) {
            return const Center(
              child: Text('Post não encontrado'),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do post
                _buildPostHeader(post),
                
                // Imagem do post
                _buildPostImage(post),
                
                // Ações do post
                _buildPostActions(post),
                
                // Informações do post
                _buildPostInfo(post),
                
                // Comentários
                _buildCommentsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(Post post) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: ClipOval(
              child: CachedImage(
                imageUrl: post.userAvatar,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatTimeAgo(post.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _showPostOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(Post post) {
    return Container(
      width: double.infinity,
      height: 400,
      child: CachedImage(
        imageUrl: post.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 400,
      ),
    );
  }

  Widget _buildPostActions(Post post) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          // Botão de curtir
          GestureDetector(
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              // Chamar API para curtir
              Provider.of<PostProvider>(context, listen: false)
                .toggleLike(post.id);
            },
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? AppTheme.errorColor : AppTheme.textColor,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.likes}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Botão de comentar
          GestureDetector(
            onTap: () {
              // Focar no campo de comentário
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.comments}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Botão de compartilhar
          GestureDetector(
            onTap: () {
              Share.share('Confira esta arte incrível no Inspirart!');
            },
            child: const Icon(
              Icons.share_outlined,
              size: 28,
            ),
          ),
          
          const Spacer(),
          
          // Botão de salvar
          GestureDetector(
            onTap: () {
              setState(() {
                _isSaved = !_isSaved;
              });
              // Chamar API para salvar
              Provider.of<PostProvider>(context, listen: false)
                .toggleSavePost(post.id);
            },
            child: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppTheme.primaryColor : AppTheme.textColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfo(Post post) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do usuário e legenda
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textColor,
              ),
              children: [
                TextSpan(
                  text: post.userName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' '),
                TextSpan(text: post.caption),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Categorias
          Wrap(
            spacing: 8,
            children: post.categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Tempo
          Text(
            _formatTimeAgo(post.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return CommentSection(
      postagemId: int.parse(widget.postId),
      usuarioId: 1, // TODO: Pegar do AuthProvider
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(
              icon: Icons.report,
              title: 'Reportar',
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post reportado')),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.link,
              title: 'Copiar link',
              onTap: () {
                context.pop();
                Clipboard.setData(const ClipboardData(text: 'https://inspirart.app/post/1'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copiado')),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.share,
              title: 'Compartilhar',
              onTap: () {
                context.pop();
                Share.share('Confira esta arte incrível no Inspirart!');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.textColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : AppTheme.textColor,
        ),
      ),
      onTap: onTap,
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
}



