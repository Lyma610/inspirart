import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/platform_helper.dart';
import 'dart:typed_data';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  final List<XFile>? images;

  const CreatePostScreen({super.key, this.images});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  int _currentImageIndex = 0;
  final List<String> _selectedCategories = [];
  bool _isLoading = false;

  List<Category> _availableCategories = [];
  List<Genre> _availableGenres = [];
  Category? _selectedCategoryObj;
  Genre? _selectedGenreObj;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _loadCategories() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    // Aguardar carregamento se ainda não foram carregados
    if (postProvider.categories.isEmpty) {
      await postProvider.loadCategories();
    }
    if (postProvider.genres.isEmpty) {
      await postProvider.loadGenres();
    }
    
    setState(() {
      _availableCategories = postProvider.categories;
      _availableGenres = postProvider.genres;
    });
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
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
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
                          child: FutureBuilder<Uint8List>(
                            future: widget.images![_currentImageIndex].readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              }
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
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
            
            // Seleção de categoria
            const Text(
              'Categoria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            DropdownButtonFormField<Category>(
              value: _selectedCategoryObj,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Selecione uma categoria',
              ),
              items: _availableCategories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.nome),
                );
              }).toList(),
              onChanged: (Category? value) {
                setState(() {
                  _selectedCategoryObj = value;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Seleção de gênero
            const Text(
              'Gênero',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            DropdownButtonFormField<Genre>(
              value: _selectedGenreObj,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Selecione um gênero (opcional)',
              ),
              items: _availableGenres.map((genre) {
                return DropdownMenuItem<Genre>(
                  value: genre,
                  child: Text(genre.nome),
                );
              }).toList(),
              onChanged: (Genre? value) {
                setState(() {
                  _selectedGenreObj = value;
                });
              },
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
    final hasImage = widget.images != null && widget.images!.isNotEmpty;
    final hasCaption = _captionController.text.trim().isNotEmpty;
    final hasCategory = _selectedCategoryObj != null;
    
    print('Can post check: image=$hasImage, caption=$hasCaption, category=$hasCategory, loading=$_isLoading');
    
    return hasImage && hasCaption && hasCategory && !_isLoading;
  }

  void _createPost() async {
    print('Create post called');
    
    if (!_canPost()) {
      print('Cannot post - validation failed');
      return;
    }

    setState(() => _isLoading = true);
    print('Loading started');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      print('Creating post with: category=${_selectedCategoryObj!.id}');
      
      final response = await ApiService.createPost(
        titulo: 'Post ${DateTime.now().millisecondsSinceEpoch}',
        descricao: _captionController.text.trim(),
        categoriaId: _selectedCategoryObj!.id,
        usuarioId: int.parse(authProvider.userId ?? '1'),
        generoId: _selectedGenreObj?.id,
        imageFile: widget.images![_currentImageIndex],
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post criado com sucesso!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Recarregar posts
        await postProvider.loadPosts();
        
        context.go('/home');
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar post: ${response.statusCode}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      print('Error creating post: $e');
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
        print('Loading finished');
      }
    }
  }
} 