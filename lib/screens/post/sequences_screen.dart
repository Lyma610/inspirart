import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class SequencesScreen extends StatefulWidget {
  const SequencesScreen({super.key});

  @override
  State<SequencesScreen> createState() => _SequencesScreenState();
}

class _SequencesScreenState extends State<SequencesScreen> {
  bool _isLiked = false;
  int _likesCount = 124;
  int _currentImageIndex = 0;
  final List<String> _sequenceImages = [
    'https://via.placeholder.com/400x500/6B46C1/FFFFFF?text=Sequência+1',
    'https://via.placeholder.com/400x500/9F7AEA/FFFFFF?text=Sequência+2',
    'https://via.placeholder.com/400x500/ED8936/FFFFFF?text=Sequência+3',
    'https://via.placeholder.com/400x500/38A169/FFFFFF?text=Sequência+4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sequências'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
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
                        leading: const Icon(Icons.edit),
                        title: const Text('Editar título e descrição'),
                        onTap: () {
                          context.pop();
                          // Abrir modal de edição
                          _showEditDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.reorder),
                        title: const Text('Reordenar imagens'),
                        onTap: () {
                          context.pop();
                          // Abrir modal de reordenação
                          _showReorderDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text('Adicionar imagens'),
                        onTap: () {
                          context.pop();
                          // Navegar para seleção de mídia
                          context.go('/select-media?mode=add');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Excluir sequência'),
                        onTap: () {
                          context.pop();
                          // Confirmar exclusão
                          _showDeleteConfirmation();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Imagem principal
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Imagem principal
                    PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: _sequenceImages.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _sequenceImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                    ),
                    
                    // Overlay com informações
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sequência de ${_sequenceImages.length} imagens',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Controles de navegação
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          onPressed: _currentImageIndex > 0
                              ? () {
                                  setState(() {
                                    _currentImageIndex--;
                                  });
                                }
                              : null,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: _currentImageIndex > 0 ? Colors.white : Colors.white54,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          onPressed: _currentImageIndex < _sequenceImages.length - 1
                              ? () {
                                  setState(() {
                                    _currentImageIndex++;
                                  });
                                }
                              : null,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: _currentImageIndex < _sequenceImages.length - 1 
                                  ? Colors.white 
                                  : Colors.white54,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Indicadores de página
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _sequenceImages.length,
                (index) => Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          
          // Informações da sequência
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Título da Sequência',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Descrição detalhada desta sequência de imagens que conta uma história visual através de diferentes perspectivas e momentos.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Estatísticas
                Row(
                  children: [
                    _buildStatItem(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      _likesCount.toString(),
                      color: _isLiked ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.comment, '18'),
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.share, '5'),
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.bookmark, '12'),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Botões de ação
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            // Aqui iria uma chamada para a API para registrar o like
                            _isLiked = !_isLiked;
                            _likesCount += _isLiked ? 1 : -1;
                          });
                        },
                        icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                        label: const Text('Curtir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLiked ? AppTheme.surfaceColor : AppTheme.primaryColor,
                          foregroundColor: _isLiked ? AppTheme.primaryColor : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              height: MediaQuery.of(context).size.height * 0.8,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Handle para arrastar
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Comentários',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  
                                  // Lista de comentários
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundImage: NetworkImage(
                                                  'https://via.placeholder.com/40',
                                                ),
                                                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Usuário ${index + 1}',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '2h atrás',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme.textSecondaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Este é um comentário de exemplo na sequência de imagens. Pode conter várias linhas de texto.',
                                                      style: TextStyle(
                                                        color: AppTheme.textColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {},
                                                          style: TextButton.styleFrom(
                                                            padding: EdgeInsets.zero,
                                                            minimumSize: const Size(0, 0),
                                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          ),
                                                          child: Text(
                                                            'Responder',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme.textSecondaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16),
                                                        TextButton(
                                                          onPressed: () {},
                                                          style: TextButton.styleFrom(
                                                            padding: EdgeInsets.zero,
                                                            minimumSize: const Size(0, 0),
                                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          ),
                                                          child: Text(
                                                            'Curtir',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme.textSecondaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  // Campo de comentário
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, -5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: 'Adicionar um comentário...',
                                              hintStyle: TextStyle(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () {
                                            // Implementar envio do comentário
                                          },
                                          icon: Icon(
                                            Icons.send,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.comment_outlined),
                        label: const Text('Comentar'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, {Color? color}) {
    final iconColor = color ?? AppTheme.textSecondaryColor;
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: iconColor,
          ),
        ),
      ],
    );
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: 'Título da Sequência');
    final descriptionController = TextEditingController(
      text: 'Descrição detalhada desta sequência de imagens que conta uma história visual através de diferentes perspectivas e momentos.',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar sequência'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título da sequência',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Digite a descrição da sequência',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Atualizar título e descrição
              setState(() {
                // TODO: Atualizar no provider
              });
              context.pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showReorderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle para arrastar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Reordenar imagens',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _sequenceImages.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _sequenceImages.removeAt(oldIndex);
                    _sequenceImages.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    key: ValueKey(_sequenceImages[index]),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(Icons.drag_handle),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _sequenceImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Imagem ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir sequência'),
        content: const Text('Tem certeza que deseja excluir esta sequência de imagens? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Excluir sequência
              context.pop();
              context.go('/home');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
} 