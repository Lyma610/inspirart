import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text('Ajuda'),
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
          // Pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar ajuda',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                  ),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
            ),
          ),

          // Seções
          _buildSection(
            'Primeiros passos',
            [
              _buildHelpItem(
                'Como criar uma conta',
                'Aprenda a criar e configurar sua conta no Inspirart',
                Icons.person_add,
              ),
              _buildHelpItem(
                'Como fazer sua primeira publicação',
                'Guia completo para compartilhar sua arte',
                Icons.add_photo_alternate,
              ),
              _buildHelpItem(
                'Como encontrar artistas',
                'Dicas para descobrir novos artistas e conteúdos',
                Icons.search,
              ),
            ],
          ),

          _buildSection(
            'Recursos populares',
            [
              _buildHelpItem(
                'Como criar sequências',
                'Aprenda a criar histórias visuais com múltiplas imagens',
                Icons.collections,
              ),
              _buildHelpItem(
                'Como usar categorias',
                'Organizando e descobrindo arte por categorias',
                Icons.category,
              ),
              _buildHelpItem(
                'Como gerenciar seguidores',
                'Dicas para interagir com sua comunidade',
                Icons.people,
              ),
            ],
          ),

          _buildSection(
            'Configurações e privacidade',
            [
              _buildHelpItem(
                'Configurações de privacidade',
                'Como proteger sua conta e conteúdo',
                Icons.lock,
              ),
              _buildHelpItem(
                'Notificações',
                'Gerenciando suas notificações',
                Icons.notifications,
              ),
              _buildHelpItem(
                'Bloqueio e denúncias',
                'Como lidar com conteúdo indesejado',
                Icons.block,
              ),
            ],
          ),

          // Contato
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Não encontrou o que procurava?',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _showContactForm();
                  },
                  icon: const Icon(Icons.mail),
                  label: const Text('Entrar em contato'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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

  void _showContactForm() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrar em contato'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Assunto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mensagem enviada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildHelpItem(String title, String description, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: AppTheme.textSecondaryColor,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Navegar para página de ajuda específica
      },
    );
  }
}