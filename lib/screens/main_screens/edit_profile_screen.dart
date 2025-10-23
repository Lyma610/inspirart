import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/cached_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedImage;
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _hasChanges = false;
  bool _isLoading = false;
  User? _currentUserData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userId != null) {
      final userProvider = context.read<UserProvider>();
      final userData = await userProvider.getUserById(int.parse(authProvider.userId!));
      
      if (mounted && userData != null) {
        setState(() {
          _currentUserData = userData;
        });
        
        // Inicializar controladores
        _nameController = TextEditingController(text: userData.name);
        _bioController = TextEditingController(text: userData.bio);
        _emailController = TextEditingController(text: userData.email);
        _passwordController = TextEditingController();
        
        // Monitorar mudanças
        _nameController.addListener(_checkChanges);
        _bioController.addListener(_checkChanges);
        _emailController.addListener(_checkChanges);
        _passwordController.addListener(_checkChanges);
        
        // Verificar mudanças iniciais
        _checkChanges();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    if (_currentUserData == null) {
      print('_checkChanges: _currentUserData é null');
      return;
    }
    
    final nameChanged = _nameController.text.trim() != (_currentUserData?.name ?? '');
    final bioChanged = _bioController.text.trim() != (_currentUserData?.bio ?? '');
    final emailChanged = _emailController.text.trim() != (_currentUserData?.email ?? '');
    final passwordChanged = _passwordController.text.trim().isNotEmpty;
    final imageChanged = _selectedImageFile != null;
    
    final hasChanges = nameChanged || bioChanged || emailChanged || passwordChanged || imageChanged;
    
    print('_checkChanges: nameChanged=$nameChanged, bioChanged=$bioChanged, emailChanged=$emailChanged, passwordChanged=$passwordChanged, imageChanged=$imageChanged, hasChanges=$hasChanges');
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
      print('_checkChanges: _hasChanges atualizado para $hasChanges');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    print('Iniciando seleção de imagem - Source: $source');
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      print('Imagem selecionada: ${image?.path}');
      
      if (image != null && mounted) {
        // Para Flutter Web, precisamos ler os bytes da imagem
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageFile = image;
          _selectedImage = image.path;
          _selectedImageBytes = bytes;
        });
        print('Imagem definida - Path: $_selectedImage, Bytes: ${bytes.length}');
        _checkChanges();
      } else {
        print('Nenhuma imagem selecionada ou widget não montado');
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_hasChanges || _isLoading) return;

    // Validação adicional
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome é obrigatório'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      
      // Testar conectividade primeiro
      print('Testando conectividade com o backend...');
      final isConnected = await ApiService.testConnection();
      if (!isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro de conexão. Verifique se o backend está rodando.'),
              backgroundColor: AppTheme.errorColor,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // Testar se usuário tem foto
      if (authProvider.userId != null) {
        print('Testando se usuário tem foto...');
        final hasPhoto = await ApiService.testUserHasPhoto(int.parse(authProvider.userId!));
        print('Usuário tem foto: $hasPhoto');
      }
      
      if (authProvider.userId != null) {
        print('Tentando editar perfil do usuário: ${authProvider.userId}');
        final success = await userProvider.editProfile(
          id: int.parse(authProvider.userId!),
          nome: _nameController.text.trim(),
          nivelAcesso: 'USUARIO', // Pode ser ajustado conforme necessário
          bio: _bioController.text.trim(),
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          senha: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : null,
          imageFile: _selectedImageFile,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          // Atualizar dados do usuário no AuthProvider se necessário
          if (authProvider.userName != _nameController.text.trim()) {
            // Aqui você pode atualizar o nome do usuário no AuthProvider se necessário
          }
          context.pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao atualizar perfil. Verifique sua conexão e tente novamente.'),
              backgroundColor: AppTheme.errorColor,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao salvar perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                        context.pop(); // Fechar dialog
                        context.go('/home'); // Ir para a tela de home
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
              context.go('/home'); // Ir para a tela de home
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges && !_isLoading ? () {
              print('Botão Concluir pressionado - _hasChanges: $_hasChanges, _isLoading: $_isLoading');
              _saveProfile();
            } : null,
            child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              : Text(
                  'Concluir',
                  style: TextStyle(
                    color: _hasChanges && !_isLoading 
                        ? AppTheme.primaryColor 
                        : AppTheme.textSecondaryColor,
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
            _currentUserData != null ? GestureDetector(
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
                                context.pop();
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Tirar foto'),
                              onTap: () {
                                context.pop();
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            if (_selectedImageBytes != null || _currentUserData?.avatar.isNotEmpty == true)
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text('Remover foto atual'),
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _selectedImageFile = null;
                                    _selectedImageBytes = null;
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
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: _selectedImageBytes != null
                            ? ClipOval(
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: AppTheme.surfaceColor,
                                      child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
                                    );
                                  },
                                ),
                              )
                            : _currentUserData!.avatar.isNotEmpty
                                ? ClipOval(
                                    child: CachedImage(
                                      imageUrl: _currentUserData!.avatar,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
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
                ) : const Center(child: CircularProgressIndicator()),
            
            const SizedBox(height: 32),
            
            // Nome
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                hintText: 'Digite seu nome',
                suffixIcon: _nameController.text.trim() != (_currentUserData?.name ?? '') 
                    ? const Icon(Icons.edit, color: AppTheme.primaryColor, size: 16)
                    : null,
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                _checkChanges();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Bio
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Conte um pouco sobre você',
                suffixIcon: _bioController.text.trim() != (_currentUserData?.bio ?? '') 
                    ? const Icon(Icons.edit, color: AppTheme.primaryColor, size: 16)
                    : null,
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                _checkChanges();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'seu@email.com',
                suffixIcon: _emailController.text.trim() != (_currentUserData?.email ?? '') 
                    ? const Icon(Icons.edit, color: AppTheme.primaryColor, size: 16)
                    : null,
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                _checkChanges();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Senha
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Nova Senha',
                hintText: 'Deixe em branco para manter a senha atual',
                suffixIcon: _passwordController.text.trim().isNotEmpty 
                    ? const Icon(Icons.edit, color: AppTheme.primaryColor, size: 16)
                    : null,
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                _checkChanges();
              },
            ),
          ],
        ),
      ),
    );
  }
}