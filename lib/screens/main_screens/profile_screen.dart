import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/cached_image.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;
  User? _currentUserData;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    // Carregar postagens e dados do usuário atual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Não recarregar dados automaticamente para evitar problemas de navegação
  }

  Future<void> _loadInitialData() async {
    final postProvider = context.read<PostProvider>();
    final authProvider = context.read<AuthProvider>();
    postProvider.loadPosts();
    
    // Carregar dados completos do usuário da API
    if (authProvider.userId != null) {
      await _loadUserData(int.parse(authProvider.userId!));
    }
  }

  Future<void> _loadUserData(int userId) async {
    setState(() {
      _isLoadingUser = true;
    });
    
    try {
      final userProvider = context.read<UserProvider>();
      final userData = await userProvider.getUserById(userId);
      
      if (mounted) {
        setState(() {
          _currentUserData = userData;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
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
        title: Row(
          children: [
            const Icon(Icons.lock_outline, size: 16),
            const SizedBox(width: 4),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Text(
                  authProvider.userName?.toLowerCase().replaceAll(' ', '') ?? 'perfil',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => context.go('/select-media'),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
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
                        leading: const Icon(Icons.settings),
                        title: const Text('Configurações'),
                        onTap: () {
                          context.pop();
                          context.go('/settings');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Seu histórico'),
                        onTap: () {
                          context.pop();
                          context.go('/history');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: const Text('Posts salvos'),
                        onTap: () {
                          context.pop();
                          context.go('/saved-posts');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Ajuda'),
                        onTap: () {
                          context.pop();
                          context.go('/help');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sair'),
                        onTap: () {
                          context.pop();
                          // Confirmar logout
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sair'),
                              content: const Text('Deseja realmente sair da sua conta?'),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                    context.go('/login');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Sair'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, PostProvider>(
        builder: (context, authProvider, postProvider, child) {
          if (!authProvider.isAuthenticated || authProvider.userId == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (_isLoadingUser) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Usar dados da API se disponíveis, senão usar dados básicos do AuthProvider
          final currentUser = _currentUserData ?? User(
            id: authProvider.userId!,
            name: authProvider.userName ?? 'Usuário',
            email: authProvider.userEmail ?? '',
            avatar: '', // Avatar vem junto com os dados do usuário
            bio: 'Artista apaixonado por criar e compartilhar arte digital 🎨',
            followers: 0,
            following: 0,
            posts: 0,
            categories: [],
          );
          
          return CustomScrollView(
            slivers: [
              // Header do perfil
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar e estatísticas
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: currentUser.avatar.isNotEmpty
                                ? ClipOval(
                                    child: CachedImage(
                                      imageUrl: currentUser.avatar,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn('${_getUserPostsCount(postProvider.posts, currentUser.id)}', 'Publicações'),
                                GestureDetector(
                                  onTap: () => context.go('/followers'),
                                  child: _buildStatColumn('0', 'Seguidores'),
                                ),
                                _buildStatColumn('0', 'Seguindo'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Nome e bio
                      Text(
                        currentUser.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.bio,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botões de ação
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.go('/edit-profile');
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.textSecondaryColor.withValues(alpha: 0.3)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Editar perfil',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final authProvider = context.read<AuthProvider>();
                                if (authProvider.userId != null) {
                                  Share.share(
                                    'Confira meu perfil no Inspirart!\nhttps://inspirart.com/user/${authProvider.userId}',
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.textSecondaryColor.withValues(alpha: 0.3)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Compartilhar perfil',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  child: Container(
                    color: AppTheme.surfaceColor,
                    child: Row(
                      children: [
                        _buildTabIcon(Icons.grid_on, 0),
                        _buildTabIcon(Icons.assignment_ind_outlined, 1),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Conteúdo das tabs
              SliverToBoxAdapter(
                child: _buildTabContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTabIcon(IconData icon, int index) {
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.textColor : Colors.transparent,
                width: 1,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppTheme.textColor : AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPostsGrid();
      case 1:
        return _buildTaggedPosts();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPostsGrid() {
    return Consumer2<AuthProvider, PostProvider>(
      builder: (context, authProvider, postProvider, child) {
        if (!authProvider.isAuthenticated || authProvider.userId == null) {
          return const SizedBox.shrink();
        }
        
        // Filtrar postagens do usuário atual
        final userPosts = postProvider.posts
            .where((post) => post.userId == authProvider.userId)
            .toList();
        
        if (userPosts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 80,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma publicação ainda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compartilhe sua primeira obra de arte!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: userPosts.length,
          itemBuilder: (context, index) {
            final post = userPosts[index];
            return GestureDetector(
              onTap: () => context.go('/post/${post.id}'),
              onLongPress: () => _showPostOptions(context, post, postProvider),
              child: Stack(
                children: [
                  CachedImage(
                    imageUrl: post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Overlay com opções
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _showPostOptions(context, post, postProvider),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaggedPosts() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_ind_outlined,
              size: 80,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Fotos em que você foi marcado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quando alguém marcar você em uma foto, ela aparecerá aqui.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  int _getUserPostsCount(List<Post> posts, String userId) {
    return posts.where((post) => post.userId == userId).length;
  }

  void _showPostOptions(BuildContext context, Post post, PostProvider postProvider) {
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
            // Handle do modal
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Opções
            ListTile(
              leading: const Icon(Icons.visibility, color: AppTheme.primaryColor),
              title: const Text('Ver post'),
              onTap: () {
                context.pop();
                context.go('/post/${post.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppTheme.primaryColor),
              title: const Text('Compartilhar'),
              onTap: () {
                context.pop();
                Share.share('Confira esta arte incrível no Inspirart! ${post.imageUrl}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppTheme.primaryColor),
              title: const Text('Copiar link'),
              onTap: () async {
                context.pop();
                await Clipboard.setData(ClipboardData(text: 'https://inspirart.app/post/${post.id}'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copiado para a área de transferência'))
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir post', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.pop();
                _showDeleteConfirmation(context, post, postProvider);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Post post, PostProvider postProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir post'),
        content: const Text('Tem certeza que deseja excluir este post? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await _deletePost(post, postProvider);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(Post post, PostProvider postProvider) async {
    try {
      // Chamar API para excluir post
      final response = await postProvider.deletePost(int.parse(post.id));
      
      if (response.statusCode == 200) {
        // Remover do estado local apenas se a API confirmar
        postProvider.removePost(post.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post excluído com sucesso'))
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir post: ${response.statusCode}'))
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir post: $e'))
        );
      }
    }
  }

}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
} 