import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_theme.dart';
import '../post/create_post_screen.dart';
import 'dart:typed_data';
import 'dart:io';

class SelectMediaScreen extends StatefulWidget {
  const SelectMediaScreen({super.key});

  @override
  State<SelectMediaScreen> createState() => _SelectMediaScreenState();
}

class _SelectMediaScreenState extends State<SelectMediaScreen> {
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final List<String> _galleryImages = [
    'https://via.placeholder.com/200x200/6B46C1/FFFFFF?text=Arte+1',
    'https://via.placeholder.com/200x200/9F7AEA/FFFFFF?text=Arte+2',
    'https://via.placeholder.com/200x200/ED8936/FFFFFF?text=Arte+3',
    'https://via.placeholder.com/200x200/38A169/FFFFFF?text=Arte+4',
    'https://via.placeholder.com/200x200/E53E3E/FFFFFF?text=Arte+5',
    'https://via.placeholder.com/200x200/3182CE/FFFFFF?text=Arte+6',
    'https://via.placeholder.com/200x200/805AD5/FFFFFF?text=Arte+7',
    'https://via.placeholder.com/200x200/D69E2E/FFFFFF?text=Arte+8',
    'https://via.placeholder.com/200x200/319795/FFFFFF?text=Arte+9',
    'https://via.placeholder.com/200x200/DD6B20/FFFFFF?text=Arte+10',
    'https://via.placeholder.com/200x200/2F855A/FFFFFF?text=Arte+11',
    'https://via.placeholder.com/200x200/2C5282/FFFFFF?text=Arte+12',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Publicar +'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton(
            onPressed: _selectedImages.isNotEmpty ? _proceedToCreate : null,
            child: Text(
              'Criar',
              style: TextStyle(
                color: _selectedImages.isNotEmpty ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Galeria de Fotos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Selecione as imagens que deseja publicar',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedImages.length} selecionada${_selectedImages.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Grade de imagens
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                final imageUrl = _galleryImages[index];
                final isSelected = false; // Placeholder images não são selecionáveis
                
                return GestureDetector(
                  onTap: () => _pickImage(),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Overlay para adicionar
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Lista de imagens selecionadas
          if (_selectedImages.isNotEmpty)
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<Uint8List>(
                            future: _selectedImages[index].readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          // Botões de ação
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedImages.isNotEmpty ? _proceedToCreate : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continuar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          if (_selectedImages.length < 10) {
            _selectedImages.add(image);
          }
        }
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        if (_selectedImages.length < 10) {
          _selectedImages.add(image);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _proceedToCreate() {
    if (_selectedImages.isNotEmpty) {
      // Navegar para tela de criação com as imagens
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreatePostScreen(images: _selectedImages),
        ),
      );
    }
  }
} 