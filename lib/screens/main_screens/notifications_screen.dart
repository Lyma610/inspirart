import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/reacao_provider.dart';
import '../../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedTab = 'Todas';

  @override
  void initState() {
    super.initState();
    // Carregar notificações reais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReacaoProvider>(context, listen: false).loadReacoes();
    });
  }

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
    return Consumer<ReacaoProvider>(
      builder: (context, reacaoProvider, child) {
        final reactions = reacaoProvider.reacoes;
        
        // Filtrar reações baseado na aba selecionada
        List<dynamic> filteredReactions = reactions.where((reaction) {
          final tipoReacao = reaction.tipoReacao;
          switch (_selectedTab) {
            case 'Curtidas':
              return tipoReacao == 'CURTIR';
            case 'Comentários':
              return tipoReacao == 'COMENTAR';
            case 'Seguidores':
              return false; // Não implementado ainda
            case 'Mentions':
              return false; // Não implementado ainda
            default:
              return true; // Todas
          }
        }).toList();
        
        if (filteredReactions.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredReactions.length,
          itemBuilder: (context, index) {
            final reaction = filteredReactions[index];
            return _buildNotificationFromReaction(reaction);
          },
        );
      },
    );
  }

  Widget _buildNotificationFromReaction(dynamic reaction) {
    final tipoReacao = reaction.tipoReacao ?? '';
    final comentario = reaction.comentario ?? '';
    final dataReacao = reaction.dataReacao ?? '';
    
    // Criar objetos mock para usuario e postagem se não existirem
    final usuario = {
      'nome': 'Usuário',
      'foto': '',
    };
    final postagem = {
      'id': '1',
      'conteudo': null,
    };
    
    String action = '';
    String target = '';
    
    switch (tipoReacao) {
      case 'CURTIR':
        action = 'curtiu sua publicação';
        break;
      case 'COMENTAR':
        action = 'comentou em sua publicação';
        target = '"$comentario"';
        break;
      case 'SALVAR':
        action = 'salvou sua publicação';
        break;
      default:
        action = 'interagiu com sua publicação';
    }
    
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
          CircleAvatar(
            radius: 24,
            backgroundImage: usuario['foto'] != null && (usuario['foto'] as String).isNotEmpty
                ? NetworkImage(usuario['foto'] as String)
                : null,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: usuario['foto'] == null || (usuario['foto'] as String).isEmpty
                ? const Icon(Icons.person, size: 24)
                : null,
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
                      TextSpan(
                        text: usuario['nome'] ?? 'Usuário',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      TextSpan(text: ' $action'),
                      if (target.isNotEmpty) ...[
                        TextSpan(text: ' $target'),
                      ],
                    ],
                  ),
                ),
                
                // Tempo
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(dataReacao),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Imagem da postagem se disponível
          if (postagem['conteudo'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://tccbackend-completo.onrender.com/postagem/image/${postagem['id']}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.image, size: 24),
                  );
                },
              ),
            ),
          ],
        ],
      ),
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

  String _formatTimeAgo(String dateString) {
    if (dateString.isEmpty) return 'Agora';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return 'Agora';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m atrás';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h atrás';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d atrás';
      } else {
        return '${(difference.inDays / 7).floor()}s atrás';
      }
    } catch (e) {
      return 'Agora';
    }
  }
} 