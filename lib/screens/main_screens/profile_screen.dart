import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.lock_outline, size: 16),
            const SizedBox(width: 4),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Text(
                  userProvider.currentUser?.name.toLowerCase().replaceAll(' ', '') ?? '',
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
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final currentUser = userProvider.currentUser;
          
          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
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
                            backgroundImage: NetworkImage(currentUser.avatar),
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn('${currentUser.posts}', 'Publicações'),
                                GestureDetector(
                                  onTap: () => context.go('/followers'),
                                  child: _buildStatColumn('${currentUser.followers}', 'Seguidores'),
                                ),
                                _buildStatColumn('${currentUser.following}', 'Seguindo'),
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
                                final user = context.read<UserProvider>().currentUser;
                                if (user != null) {
                                  Share.share(
                                    'Confira meu perfil no Inspirart!\nhttps://inspirart.com/user/${user.id}',
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context.go('/post'),
          child: Image.network(
            'https://via.placeholder.com/200x200/${_getRandomColor()}/FFFFFF?text=Post+${index + 1}',
            fit: BoxFit.cover,
          ),
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



  String _getRandomColor() {
    final colors = ['6B46C1', '9F7AEA', 'ED8936', '38A169', 'E53E3E', '3182CE'];
    return colors[DateTime.now().millisecond % colors.length];
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