import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _selectedImage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name);
    _bioController = TextEditingController(text: user?.bio);

    // Monitorar mudanças
    _nameController.addListener(_checkChanges);
    _bioController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final user = context.read<UserProvider>().currentUser;
    final hasChanges = _nameController.text != user?.name ||
        _bioController.text != user?.bio ||
        _selectedImage != null;
        
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _saveChanges() {
    final userProvider = context.read<UserProvider>();
    
    userProvider.updateProfile(
      name: _nameController.text,
      bio: _bioController.text,
      avatar: _selectedImage ?? userProvider.currentUser?.avatar,
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (_hasChanges) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Descartar alterações?'),
                  content: const Text('Se sair agora, perderá todas as alterações feitas.'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Continuar editando'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        context.pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Descartar'),
                    ),
                  ],
                ),
              );
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveChanges : null,
            child: Text(
              'Concluir',
              style: TextStyle(
                color: _hasChanges ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                return GestureDetector(
                  onTap: () {
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
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Escolher da galeria'),
                              onTap: () {
                                // TODO: Implementar seleção de imagem
                                context.pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Tirar foto'),
                              onTap: () {
                                // TODO: Implementar câmera
                                context.pop();
                              },
                            ),
                            if (_selectedImage != null || user?.avatar != null)
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text('Remover foto atual'),
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                  _checkChanges();
                                  context.pop();
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? NetworkImage(_selectedImage!)
                            : NetworkImage(user?.avatar ?? ''),
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: user?.avatar == null && _selectedImage == null
                            ? const Icon(Icons.person, size: 50, color: AppTheme.primaryColor)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.surfaceColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Digite seu nome',
              ),
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 24),
            
            // Bio
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Conte um pouco sobre você',
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}