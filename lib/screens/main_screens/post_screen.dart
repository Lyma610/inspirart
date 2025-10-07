import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/post_provider.dart';
import '../../utils/app_theme.dart';

class PostScreen extends StatefulWidget {
  final String postId;
  
  const PostScreen({super.key, required this.postId});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  bool _isSaved = false;
  // Lista local de comentários (simulação)
  List<Map<String, dynamic>> _comments = [
    {
      'id': '1',
      'userName': 'ArtistaGrafite',
      'comment': 'Que obra incrível! 👏',
      'timeAgo': '1 hora atrás',
      'likes': 5,
      'isLiked': false,
    },
    {
      'id': '2',
      'userName': 'FotógrafoPro',
      'comment': 'Adorei as cores! 🎨',
      'timeAgo': '45 min atrás',
      'likes': 3,
      'isLiked': false,
    },
    {
      'id': '3',
      'userName': 'DesignerCriativo',
      'comment': 'Muito inspirador! ✨',
      'timeAgo': '30 min atrás',
      'likes': 2,
      'isLiked': false,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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
          onPressed: () => context.go('/home'),
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
          // Obter o post correto baseado no ID passado
          final post = postProvider.posts.firstWhere(
            (p) => p.id == widget.postId,
            orElse: () => postProvider.posts.first,
          );
          
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
      bottomNavigationBar: _buildCommentInput(),
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
            backgroundImage: NetworkImage(post.userAvatar),
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                  '2 horas atrás',
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
      child: Image.network(
        post.imageUrl,
        fit: BoxFit.cover,
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
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Row(
              children: [
                const Icon(
                  Icons.comment_outlined,
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
              final provider = Provider.of<PostProvider>(context, listen: false);
              provider.incrementShares(post.id);
            },
            child: Row(
              children: [
                const Icon(
                  Icons.share_outlined,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.shares}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Botão de salvar
          GestureDetector(
            onTap: () {
              setState(() {
                _isSaved = !_isSaved;
              });
            },
            child: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 28,
              color: _isSaved ? AppTheme.primaryColor : AppTheme.textColor,
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
          // Caption
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
            '2 horas atrás',
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
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppTheme.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comentários (${_comments.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
          // Lista dinâmica de comentários
          ..._comments.map((c) => _buildCommentItem(
            c['userName'] ?? '',
            c['comment'] ?? '',
            c['timeAgo'] ?? '',
            likes: c['likes'] ?? 0,
            isLiked: c['isLiked'] ?? false,
          )),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String userName, String comment, String timeAgo, {int likes = 0, bool isLiked = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://via.placeholder.com/32'),
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor,
                    ),
                    children: [
                      TextSpan(
                        text: userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: comment),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isLiked ? AppTheme.errorColor : AppTheme.textSecondaryColor,
                ),
                onPressed: () {
                  setState(() {
                    final commentIndex = _comments.indexWhere((c) => c['userName'] == userName && c['comment'] == comment);
                    if (commentIndex != -1) {
                      final Map<String, dynamic> updatedComment = Map.from(_comments[commentIndex]);
                      updatedComment['isLiked'] = !updatedComment['isLiked'];
                      updatedComment['likes'] += updatedComment['isLiked'] ? 1 : -1;
                      _comments[commentIndex] = updatedComment;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(updatedComment['isLiked'] ? 'Comentário curtido!' : 'Curtida removida'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  });
                },
              ),
              if (likes > 0)
                Text(
                  '$likes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://via.placeholder.com/36'),
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Adicione um comentário...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                setState(() {
                  _comments.insert(0, {
                    'userName': 'Você',
                    'comment': _commentController.text,
                    'timeAgo': 'Agora',
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comentário enviado!'),
                    ),
                  );
                });
                _commentController.clear();
              }
            },
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildOptionItem(
                icon: Icons.report,
                title: 'Reportar',
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
                isDestructive: true,
              ),
              
              _buildOptionItem(
                icon: Icons.copy,
                title: 'Copiar link',
                onTap: () async {
                  Navigator.pop(context);
                  final provider = Provider.of<PostProvider>(context, listen: false);
                  final post = provider.posts.first;
                  await Clipboard.setData(ClipboardData(text: 'https://inspirart.app/post/${post.id}'));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copiado para a área de transferência'))
                    );
                  }
                },
              ),
              
              _buildOptionItem(
                icon: Icons.share,
                title: 'Compartilhar',
                onTap: () {
                  Navigator.pop(context);
                  final provider = Provider.of<PostProvider>(context, listen: false);
                  final post = provider.posts.first;
                  Share.share('Confira esta arte incrível no Inspirart! ${post.imageUrl}');
                  setState(() {
                    provider.incrementShares(post.id);
                  });
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
} 