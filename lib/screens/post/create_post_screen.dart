import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  final List<String>? images;

  const CreatePostScreen({super.key, this.images});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  int _currentImageIndex = 0;
  final List<String> _selectedCategories = [];
  bool _isLoading = false;

  final List<String> _availableCategories = [
    'Fotografia',
    'Ilustração',
    'Design',
    'Arte Digital',
    'Grafite',
    'Arte Urbana',
    'Pintura',
    'Escultura',
    'Arquitetura',
    'Moda',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Postar'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton(
            onPressed: _canPost() ? _createPost : null,
            child: Text(
              'Publicar',
              style: TextStyle(
                color: _canPost() ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Área de imagem
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: widget.images != null && widget.images!.isNotEmpty
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.images![_currentImageIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        if (widget.images!.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.images!.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _currentImageIndex
                                        ? AppTheme.primaryColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 64,
                          color: AppTheme.primaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecione uma imagem',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/select-media'),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Escolher Imagem'),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Campo de legenda
            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Legenda',
                hintText: 'Escreva uma legenda para sua arte...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Seleção de categorias
            const Text(
              'Categorias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedCategories.length < 3) {
                          _selectedCategories.add(category);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Máximo de 3 categorias permitido'),
                            ),
                          );
                        }
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Botões de navegação
            if (widget.images != null && widget.images!.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentImageIndex > 0
                        ? () => setState(() => _currentImageIndex--)
                        : null,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentImageIndex + 1} de ${widget.images!.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _currentImageIndex < widget.images!.length - 1
                        ? () => setState(() => _currentImageIndex++)
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Informações adicionais
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dicas para um bom post:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTip('• Use imagens de alta qualidade'),
                  _buildTip('• Escreva descrições detalhadas'),
                  _buildTip('• Escolha categorias relevantes'),
                  _buildTip('• Use hashtags para maior visibilidade'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        tip,
        style: TextStyle(
          color: AppTheme.textSecondaryColor,
          fontSize: 14,
        ),
      ),
    );
  }

  bool _canPost() {
    return widget.images != null &&
           widget.images!.isNotEmpty &&
           _captionController.text.trim().isNotEmpty &&
           _selectedCategories.isNotEmpty &&
           !_isLoading;
  }

  void _createPost() async {
    if (_canPost()) {
      setState(() => _isLoading = true);

      try {
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentUser = userProvider.currentUser!;
        
        final post = Post(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: currentUser.id,
          userName: currentUser.name,
          userAvatar: currentUser.avatar,
          imageUrl: widget.images![_currentImageIndex],
          caption: _captionController.text.trim(),
          categories: _selectedCategories,
          likes: 0,
          comments: 0,
          shares: 0,
          createdAt: DateTime.now(),
        );

        // Adicionar post ao provider
        postProvider.addPost(post);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post criado com sucesso!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar post: ${e.toString()}'),
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
  }
} 