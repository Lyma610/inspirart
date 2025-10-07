import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class DrawerMenuScreen extends StatelessWidget {
  const DrawerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final currentUser = userProvider.currentUser;
          
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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          currentUser?.avatar ?? 'https://via.placeholder.com/80',
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nome do usuário
                      Text(
                        currentUser?.name ?? 'Usuário',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Email do usuário
                      Text(
                        currentUser?.email ?? 'usuario@email.com',
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
                          Navigator.pop(context);
                          context.go('/profile');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.bookmark_outline,
                        title: 'Salvos',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/saved');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Configurações',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/settings');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Ajuda',
                        onTap: () {
                          Navigator.pop(context);
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
                          Navigator.pop(context);
                          context.go('/home?category=Fotografia');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.brush_outlined,
                        title: 'Ilustração',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/home?category=Ilustração');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.design_services_outlined,
                        title: 'Design',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/home?category=Design');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.computer_outlined,
                        title: 'Arte Digital',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/home?category=Arte Digital');
                        },
                      ),
                      
                      const Divider(height: 32),
                      
                      // Botão de sair
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Sair',
                        onTap: () async {
                          Navigator.pop(context);
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