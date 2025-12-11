import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/image_providers.dart';

part 'cached_plant_image.g.dart';

/// Provider para carregar imagem com cache
@riverpod
Future<Uint8List?> cachedImage(Ref ref, String imageUrl) async {
  final enhancedImageService = ref.watch(enhancedImageServiceProvider);

  final result = await enhancedImageService.loadImage(imageUrl);

  return result.fold((error) => null, (bytes) => bytes);
}

/// Widget para exibir imagem de planta com cache efetivo
///
/// Características:
/// - Suporte automático para imagens Base64 e URLs remotas
/// - Cache em memória e disco (via EnhancedImageService)
/// - Loading state automático (CircularProgressIndicator)
/// - Error state automático (broken_image icon)
/// - BorderRadius opcional
///
/// Exemplo de uso:
/// ```dart
/// CachedPlantImage(
///   imageUrl: plant.imageUrls.first,
///   width: 120,
///   height: 120,
///   borderRadius: BorderRadius.circular(8),
///   fit: BoxFit.cover,
/// )
/// ```
class CachedPlantImage extends ConsumerWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CachedPlantImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se for Base64, exibir diretamente
    if (imageUrl.startsWith('data:image/')) {
      return _buildBase64Image();
    }

    // Caso contrário, usar cache
    final cachedImageAsync = ref.watch(cachedImageProvider(imageUrl));

    return cachedImageAsync.when(
      data: (imageBytes) {
        if (imageBytes == null) {
          return _buildPlaceholder(context);
        }
        return _buildImage(
          Image.memory(imageBytes, fit: fit, width: width, height: height),
        );
      },
      loading: () => _buildPlaceholder(context),
      error: (_, __) => _buildErrorWidget(context),
    );
  }

  Widget _buildBase64Image() {
    // Extrair bytes do Base64
    final base64Data = imageUrl.split(',').last;
    final bytes = base64Decode(base64Data);

    return _buildImage(
      Image.memory(bytes, fit: fit, width: width, height: height),
    );
  }

  Widget _buildImage(Widget image) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}
