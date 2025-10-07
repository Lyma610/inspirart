import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedTab = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/notification-settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs de categorias
          Container(
            color: AppTheme.surfaceColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab('Todas'),
                  _buildTab('Curtidas'),
                  _buildTab('Comentários'),
                  _buildTab('Seguidores'),
                  _buildTab('Mentions'),
                ],
              ),
            ),
          ),
          
          // Lista de notificações
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = _getNotificationsForTab(_selectedTab);
    
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Avatar do usuário
          GestureDetector(
            onTap: () => context.go('/user/${notification['userId']}'),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(notification['userAvatar']),
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 12),
          
          // Conteúdo da notificação
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texto da notificação
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.go('/user/${notification['userId']}'),
                          child: Text(
                            notification['userName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(text: ' ${notification['action']}'),
                      if (notification['target'] != null) ...[
                        TextSpan(text: ' ${notification['target']}'),
                      ],
                    ],
                  ),
                ),
                
                // Tempo
                const SizedBox(height: 4),
                Text(
                  notification['timeAgo'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Botão de ação ou imagem
          if (notification['type'] == 'follow') ...[
            _buildFollowButton(notification['userId']),
          ] else if (notification['imageUrl'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                notification['imageUrl']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowButton(String userId) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isFollowing = userProvider.following.any((user) => user.id == userId);
        
        return ElevatedButton(
          onPressed: () {
            userProvider.toggleFollow(userId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? AppTheme.surfaceColor : AppTheme.primaryColor,
            foregroundColor: isFollowing ? AppTheme.primaryColor : Colors.white,
            side: isFollowing ? BorderSide(color: AppTheme.primaryColor) : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isFollowing ? 'Seguindo' : 'Seguir',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_selectedTab) {
      case 'Curtidas':
        message = 'Nenhuma curtida ainda';
        icon = Icons.favorite_border;
        break;
      case 'Comentários':
        message = 'Nenhum comentário ainda';
        icon = Icons.comment;
        break;
      case 'Seguidores':
        message = 'Nenhum novo seguidor';
        icon = Icons.person_add;
        break;
      case 'Mentions':
        message = 'Nenhuma menção ainda';
        icon = Icons.alternate_email;
        break;
      default:
        message = 'Nenhuma notificação';
        icon = Icons.notifications_none;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue interagindo para receber notificações',
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

  List<Map<String, dynamic>> _getNotificationsForTab(String tab) {
    final allNotifications = [
      {
        'id': '1',
        'type': 'like',
        'userId': 'user1',
        'userName': 'ArtistaGrafite',
        'userAvatar': 'https://via.placeholder.com/50',
        'action': 'curtiu sua publicação',
        'imageUrl': 'https://via.placeholder.com/100x100/6B46C1/FFFFFF?text=Post',
        'timeAgo': '2 min atrás',
      },
      {
        'id': '2',
        'type': 'comment',
        'userId': 'user2',
        'userName': 'FotógrafoPro',
        'userAvatar': 'https://via.placeholder.com/50',
        'action': 'comentou em sua publicação',
        'target': '"Que arte incrível! 👏"',
        'imageUrl': 'https://via.placeholder.com/100x100/ED8936/FFFFFF?text=Post',
        'timeAgo': '15 min atrás',
      },
      {
        'id': '3',
        'type': 'follow',
        'userId': 'user3',
        'userName': 'DesignerCriativo',
        'userAvatar': 'https://via.placeholder.com/50',
        'action': 'começou a seguir você',
        'timeAgo': '1 hora atrás',
      },
      {
        'id': '4',
        'type': 'like',
        'userId': 'user4',
        'userName': 'IlustradorArte',
        'userAvatar': 'https://via.placeholder.com/50',
        'action': 'curtiu sua publicação',
        'imageUrl': 'https://via.placeholder.com/100x100/9F7AEA/FFFFFF?text=Post',
        'timeAgo': '2 horas atrás',
      },
      {
        'id': '5',
        'type': 'mention',
        'userId': 'user5',
        'userName': 'ArteUrbana',
        'userAvatar': 'https://via.placeholder.com/50',
        'action': 'mencionou você em um comentário',
        'target': '"@SeuUsuario, veja essa inspiração!"',
        'timeAgo': '3 horas atrás',
      },
    ];
    
    switch (tab) {
      case 'Curtidas':
        return allNotifications.where((n) => n['type'] == 'like').toList();
      case 'Comentários':
        return allNotifications.where((n) => n['type'] == 'comment').toList();
      case 'Seguidores':
        return allNotifications.where((n) => n['type'] == 'follow').toList();
      case 'Mentions':
        return allNotifications.where((n) => n['type'] == 'mention').toList();
      default:
        return allNotifications;
    }
  }
} 