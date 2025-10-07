import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class SelectMediaScreen extends StatefulWidget {
  const SelectMediaScreen({super.key});

  @override
  State<SelectMediaScreen> createState() => _SelectMediaScreenState();
}

class _SelectMediaScreenState extends State<SelectMediaScreen> {
  final List<String> _selectedImages = [];
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
                final isSelected = _selectedImages.contains(imageUrl);
                
                return GestureDetector(
                  onTap: () => _toggleImageSelection(imageUrl),
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
                      
                      // Overlay de seleção
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      
                      // Ícone de seleção
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
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
                    onPressed: () {
                      // TODO: Implementar câmera
                    },
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

  void _toggleImageSelection(String imageUrl) {
    setState(() {
      if (_selectedImages.contains(imageUrl)) {
        _selectedImages.remove(imageUrl);
      } else {
        if (_selectedImages.length < 10) { // Limite de 10 imagens
          _selectedImages.add(imageUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Máximo de 10 imagens permitido'),
            ),
          );
        }
      }
    });
  }

  void _proceedToCreate() {
    if (_selectedImages.isNotEmpty) {
      // Codificar URLs das imagens para passar como parâmetros
      final imagesParam = _selectedImages.join('|');
      context.go('/create-post?images=$imagesParam');
    }
  }
} 