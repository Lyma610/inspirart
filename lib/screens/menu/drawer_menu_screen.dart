import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/cached_image.dart';

class DrawerMenuScreen extends StatefulWidget {
  const DrawerMenuScreen({super.key});

  @override
  State<DrawerMenuScreen> createState() => _DrawerMenuScreenState();
}

class _DrawerMenuScreenState extends State<DrawerMenuScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar dados do usuário atual quando o drawer for aberto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, child) {
          // Usar dados reais do AuthProvider se disponível, senão usar UserProvider
          final currentUser = userProvider.currentUser;
          final userName = authProvider.userName ?? currentUser?.name ?? 'Usuário';
          final userEmail = authProvider.userEmail ?? currentUser?.email ?? 'usuario@email.com';
          // Usar avatar do usuário atual (vem junto com os dados)
          final userAvatar = currentUser?.avatar;
          
          return Container(
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                // Header do drawer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar do usuário
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: ClipOval(
                          child: userAvatar != null && userAvatar.isNotEmpty
                              ? CachedImage(
                                  imageUrl: userAvatar,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nome do usuário
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Email do usuário
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de opções do menu
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Perfil',
                        onTap: () {
                          context.pop();
                          context.go('/profile');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.bookmark_outline,
                        title: 'Salvos',
                        onTap: () {
                          context.pop();
                          context.go('/saved-posts');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Configurações',
                        onTap: () {
                          context.pop();
                          context.go('/settings');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Ajuda',
                        onTap: () {
                          context.pop();
                          context.go('/help');
                        },
                      ),
                      
                      const Divider(height: 32),
                      
                      // Seção de categorias
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'CATEGORIAS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondaryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      
                      _buildMenuItem(
                        icon: Icons.camera_alt_outlined,
                        title: 'Fotografia',
                        onTap: () {
                          context.pop();
                          context.go('/home');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.brush_outlined,
                        title: 'Ilustração',
                        onTap: () {
                          context.pop();
                          context.go('/home');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.design_services_outlined,
                        title: 'Design',
                        onTap: () {
                          context.pop();
                          context.go('/home');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.computer_outlined,
                        title: 'Arte Digital',
                        onTap: () {
                          context.pop();
                          context.go('/home');
                        },
                      ),
                      
                      const Divider(height: 32),
                      
                      // Botão de sair
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Sair',
                        onTap: () async {
                          context.pop();
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
                
                // Footer do drawer
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Versão 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          Text(
                            '© 2024 Inspirart',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.textColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : AppTheme.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
} 