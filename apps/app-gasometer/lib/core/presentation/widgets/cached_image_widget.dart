import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/ui_constants.dart';

/// Widget reutilizável para carregamento otimizado de imagens
/// com cache, shimmer loading e error handling
class CachedImageWidget extends StatelessWidget {
  /// URL da imagem de rede
  final String? networkUrl;
  
  /// Caminho da imagem local
  final String? localPath;
  
  /// Arquivo de imagem local
  final File? imageFile;
  
  /// Caminho do asset
  final String? assetPath;
  
  /// Altura da imagem
  final double? height;
  
  /// Largura da imagem
  final double? width;
  
  /// Como ajustar a imagem
  final BoxFit fit;
  
  /// Border radius personalizado
  final BorderRadiusGeometry? borderRadius;
  
  /// Widget de placeholder personalizado
  final Widget? placeholder;
  
  /// Widget de erro personalizado
  final Widget? errorWidget;
  
  /// Ícone para placeholder padrão
  final IconData? placeholderIcon;
  
  /// Cor base do shimmer
  final Color? shimmerBaseColor;
  
  /// Cor de highlight do shimmer
  final Color? shimmerHighlightColor;
  
  /// Se deve excluir da semântica
  final bool excludeFromSemantics;
  
  /// Se é uma visualização em tela cheia
  final bool isFullScreen;

  const CachedImageWidget({
    super.key,
    this.networkUrl,
    this.localPath,
    this.imageFile,
    this.assetPath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderIcon,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.excludeFromSemantics = false,
    this.isFullScreen = false,
  }) : assert(
         (networkUrl != null) || 
         (localPath != null) || 
         (imageFile != null) || 
         (assetPath != null),
         'Pelo menos uma fonte de imagem deve ser fornecida'
       );

  /// Factory para imagens de rede
  factory CachedImageWidget.network(
    String url, {
    Key? key,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    BorderRadiusGeometry? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    IconData? placeholderIcon,
    bool excludeFromSemantics = false,
  }) {
    return CachedImageWidget(
      key: key,
      networkUrl: url,
      height: height,
      width: width,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      placeholderIcon: placeholderIcon,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// Factory para arquivos locais
  factory CachedImageWidget.file(
    File file, {
    Key? key,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    BorderRadiusGeometry? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    IconData? placeholderIcon,
    bool isFullScreen = false,
    bool excludeFromSemantics = false,
  }) {
    return CachedImageWidget(
      key: key,
      imageFile: file,
      height: height,
      width: width,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      placeholderIcon: placeholderIcon,
      isFullScreen: isFullScreen,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// Factory para assets
  factory CachedImageWidget.asset(
    String path, {
    Key? key,
    double? height,
    double? width,
    BoxFit fit = BoxFit.contain,
    BorderRadiusGeometry? borderRadius,
    bool excludeFromSemantics = true,
  }) {
    return CachedImageWidget(
      key: key,
      assetPath: path,
      height: height,
      width: width,
      fit: fit,
      borderRadius: borderRadius,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // Determinar qual tipo de imagem carregar
    if (networkUrl != null) {
      imageWidget = _buildNetworkImage(context);
    } else if (imageFile != null) {
      imageWidget = _buildFileImage(context);
    } else if (localPath != null) {
      imageWidget = _buildFileImage(context, File(localPath!));
    } else if (assetPath != null) {
      imageWidget = _buildAssetImage(context);
    } else {
      imageWidget = _buildErrorWidget(context);
    }

    // Aplicar border radius se especificado
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Constrói imagem de rede com CachedNetworkImage
  Widget _buildNetworkImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: networkUrl!,
      height: height,
      width: width,
      fit: fit,
      memCacheHeight: height?.toInt(),
      memCacheWidth: width?.toInt(),
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
    );
  }

  /// Constrói imagem de arquivo local
  Widget _buildFileImage(BuildContext context, [File? file]) {
    final targetFile = file ?? imageFile!;
    final screenSize = MediaQuery.of(context).size;
    
    // Calcular cache dimensions baseado no contexto
    final cacheHeight = isFullScreen 
        ? (screenSize.height * 0.8).toInt() 
        : height?.toInt() ?? AppSizes.imagePreviewHeight.toInt();
    final cacheWidth = isFullScreen 
        ? (screenSize.width * 0.9).toInt() 
        : width?.toInt() ?? screenSize.width.toInt();

    return Image.file(
      targetFile,
      height: height,
      width: width,
      fit: fit,
      cacheHeight: cacheHeight,
      cacheWidth: cacheWidth,
      excludeFromSemantics: excludeFromSemantics,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildPlaceholder(context);
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(context),
    );
  }

  /// Constrói imagem de asset
  Widget _buildAssetImage(BuildContext context) {
    return Image.asset(
      assetPath!,
      height: height,
      width: width,
      fit: fit,
      cacheHeight: height?.toInt(),
      cacheWidth: width?.toInt(),
      excludeFromSemantics: excludeFromSemantics,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(context),
    );
  }

  /// Constrói placeholder com shimmer loading
  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ?? theme.colorScheme.surfaceContainerHighest,
      highlightColor: shimmerHighlightColor ?? theme.colorScheme.surface,
      child: Container(
        height: height,
        width: width,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              placeholderIcon ?? Icons.image_outlined,
              size: isFullScreen ? AppSizes.iconXXL : AppSizes.iconL,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            if (!isFullScreen) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                'Carregando...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Constrói widget de erro
  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    final theme = Theme.of(context);
    return Container(
      height: height,
      width: width,
      color: theme.colorScheme.errorContainer.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isFullScreen ? AppSizes.iconXL : AppSizes.iconL,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Erro ao carregar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}