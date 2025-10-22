import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pauseAll = false;
  bool _likes = true;
  bool _comments = true;
  bool _followers = true;
  bool _mentions = true;
  bool _messages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text('Notificações'),
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
      ),
      body: ListView(
        children: [
          // Pausar tudo
          SwitchListTile(
            title: const Text('Pausar todas as notificações'),
            subtitle: const Text('Desativa temporariamente todas as notificações'),
            value: _pauseAll,
            onChanged: (value) {
              setState(() {
                _pauseAll = value;
              });
            },
          ),
          
          const Divider(),
          
          // Curtidas
          SwitchListTile(
            title: const Text('Curtidas'),
            subtitle: const Text('Quando alguém curtir suas publicações'),
            value: _likes && !_pauseAll,
            onChanged: _pauseAll ? null : (value) {
              setState(() {
                _likes = value;
              });
            },
          ),
          
          // Comentários
          SwitchListTile(
            title: const Text('Comentários'),
            subtitle: const Text('Quando alguém comentar em suas publicações'),
            value: _comments && !_pauseAll,
            onChanged: _pauseAll ? null : (value) {
              setState(() {
                _comments = value;
              });
            },
          ),
          
          // Seguidores
          SwitchListTile(
            title: const Text('Novos seguidores'),
            subtitle: const Text('Quando alguém começar a seguir você'),
            value: _followers && !_pauseAll,
            onChanged: _pauseAll ? null : (value) {
              setState(() {
                _followers = value;
              });
            },
          ),
          
          // Menções
          SwitchListTile(
            title: const Text('Menções'),
            subtitle: const Text('Quando alguém mencionar você em um comentário'),
            value: _mentions && !_pauseAll,
            onChanged: _pauseAll ? null : (value) {
              setState(() {
                _mentions = value;
              });
            },
          ),
          
          // Mensagens diretas
          SwitchListTile(
            title: const Text('Mensagens diretas'),
            subtitle: const Text('Quando alguém enviar uma mensagem para você'),
            value: _messages && !_pauseAll,
            onChanged: _pauseAll ? null : (value) {
              setState(() {
                _messages = value;
              });
            },
          ),
          
          const Divider(),
          
          // Links para configurações do sistema
          ListTile(
            title: const Text('Configurações do sistema'),
            subtitle: const Text('Configure as notificações no seu dispositivo'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirecionando para configurações do sistema...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}