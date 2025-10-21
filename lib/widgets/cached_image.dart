import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import 'base64_image.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Verificar se a URL é válida
    if (imageUrl.isEmpty) {
      return Container(
        width: width ?? 100,
        height: height ?? 100,
        color: AppTheme.surfaceColor,
        child: Icon(
          Icons.image_not_supported,
          color: AppTheme.textSecondaryColor,
          size: 32,
        ),
      );
    }
    
    // Verificar se é uma imagem base64
    if (imageUrl.startsWith('data:image')) {
      return Base64Image(
        base64String: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
      );
    }
    
    // Para URLs normais, usar CachedNetworkImage
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width ?? 100,
          height: height ?? 100,
          color: AppTheme.surfaceColor,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('Erro ao carregar imagem: $url - $error');
          return Container(
            width: width ?? 100,
            height: height ?? 100,
            color: AppTheme.surfaceColor,
            child: Icon(
              Icons.image_not_supported,
              color: AppTheme.textSecondaryColor,
              size: 32,
            ),
          );
        },
        // Configurações adicionais para melhor performance
        memCacheWidth: (width?.isFinite == true && width! > 0) ? width!.toInt() : null,
        memCacheHeight: (height?.isFinite == true && height! > 0) ? height!.toInt() : null,
        maxWidthDiskCache: 1024,
        maxHeightDiskCache: 1024,
      ),
    );
  }
}