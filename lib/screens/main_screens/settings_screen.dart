import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text('Configurações'),
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
          // Seção de Conta
          _buildSection(
            'Conta',
            [
              _buildListTile(
                icon: Icons.person,
                title: 'Informações da conta',
                onTap: () => context.go('/edit-profile'),
              ),
              _buildListTile(
                icon: Icons.notifications,
                title: 'Notificações',
                onTap: () => context.go('/notification-settings'),
              ),
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Privacidade',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configurações de privacidade em desenvolvimento'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Seção de Preferências
          _buildSection(
            'Preferências',
            [
              _buildListTile(
                icon: Icons.palette,
                title: 'Tema',
                trailing: DropdownButton<String>(
                  value: 'Sistema',
                  underline: const SizedBox(),
                  items: ['Sistema', 'Claro', 'Escuro'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tema alterado para: $newValue'),
                      ),
                    );
                  },
                ),
              ),
              _buildListTile(
                icon: Icons.language,
                title: 'Idioma',
                trailing: const Text('Português'),
              ),
            ],
          ),
          
          // Seção de Suporte
          _buildSection(
            'Suporte',
            [
              _buildListTile(
                icon: Icons.help,
                title: 'Ajuda',
                onTap: () => context.go('/help'),
              ),
              _buildListTile(
                icon: Icons.bug_report,
                title: 'Reportar um problema',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Use o formulário de contato na tela de Ajuda'),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Política de Privacidade',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Política de privacidade em desenvolvimento'),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.description,
                title: 'Termos de Uso',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Termos de uso em desenvolvimento'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Versão do app
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              'Versão 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}