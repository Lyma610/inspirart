import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/app_theme.dart';

class Base64Image extends StatelessWidget {
  final String base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const Base64Image({
    super.key,
    required this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  double _getIconSize() {
    // Verificar se width e height são valores finitos e válidos
    if (width != null && height != null && 
        width!.isFinite && height!.isFinite &&
        width! > 0 && height! > 0) {
      // Usar o menor valor entre width e height para evitar problemas
      final minSize = width! < height! ? width! : height!;
      return minSize * 0.4;
    }
    // Retornar tamanho padrão se valores forem infinitos ou nulos
    return 32.0;
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Verificar se a string não está vazia
      if (base64String.isEmpty) {
        print('Base64Image: String vazia');
        return _buildErrorWidget();
      }

      // Verificar se width e height são válidos
      if (width != null && (!width!.isFinite || width! <= 0)) {
        print('Base64Image: Width inválido: $width');
        return _buildErrorWidget();
      }
      
      if (height != null && (!height!.isFinite || height! <= 0)) {
        print('Base64Image: Height inválido: $height');
        return _buildErrorWidget();
      }

      // Remover o prefixo data:image se existir
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',')[1];
      }

      // Remover espaços em branco
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');

      // Verificar se a string tem tamanho válido
      if (cleanBase64.isEmpty || cleanBase64.length % 4 != 0) {
        print('Base64Image: String base64 inválida - tamanho: ${cleanBase64.length}');
        return _buildErrorWidget();
      }

      // Verificar se a string não é muito grande (limite de 1MB)
      if (cleanBase64.length > 1000000) {
        print('Base64Image: String base64 muito grande: ${cleanBase64.length} caracteres');
        return _buildErrorWidget();
      }

      // Decodificar base64 para bytes
      final bytes = base64Decode(cleanBase64);
      
      // Verificar se os bytes são válidos
      if (bytes.isEmpty) {
        print('Base64Image: Bytes vazios após decodificação');
        return _buildErrorWidget();
      }
      
      // Verificar se os dados são SVG (começam com <svg)
      if (bytes.length >= 4 && 
          bytes[0] == 0x3c && bytes[1] == 0x73 && 
          bytes[2] == 0x76 && bytes[3] == 0x67) {
        print('Base64Image: Dados SVG detectados, não é uma imagem válida');
        return _buildErrorWidget();
      }
      
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.memory(
          bytes,
          width: width?.isFinite == true ? width : null,
          height: height?.isFinite == true ? height : null,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('Base64Image: Erro ao decodificar imagem base64: $error');
            print('Base64Image: StackTrace: $stackTrace');
            return _buildErrorWidget();
          },
        ),
      );
    } catch (e) {
      print('Base64Image: Erro ao processar imagem base64: $e');
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width?.isFinite == true ? width : 100,
      height: height?.isFinite == true ? height : 100,
      color: AppTheme.surfaceColor,
      child: Icon(
        Icons.person,
        color: AppTheme.textSecondaryColor,
        size: _getIconSize(),
      ),
    );
  }
}