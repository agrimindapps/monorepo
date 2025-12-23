import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Configuração de processamento de imagem
class ImageProcessingConfig {
  /// Largura máxima em pixels
  final int maxWidth;

  /// Altura máxima em pixels
  final int maxHeight;

  /// Qualidade JPEG (0-100)
  final int quality;

  /// Tamanho máximo em bytes
  final int maxSizeBytes;

  const ImageProcessingConfig({
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
    required this.maxSizeBytes,
  });

  /// Configuração padrão: 600KB, 1200x1200, quality 75
  static const standard = ImageProcessingConfig(
    maxWidth: 1200,
    maxHeight: 1200,
    quality: 75,
    maxSizeBytes: 600 * 1024, // 600KB
  );

  /// Configuração para recibos/comprovantes (maior resolução para legibilidade)
  static const receipt = ImageProcessingConfig(
    maxWidth: 1600,
    maxHeight: 2000,
    quality: 80,
    maxSizeBytes: 600 * 1024, // 600KB
  );

  /// Configuração para fotos de perfil
  static const profile = ImageProcessingConfig(
    maxWidth: 500,
    maxHeight: 500,
    quality: 80,
    maxSizeBytes: 200 * 1024, // 200KB
  );

  /// Configuração para thumbnails
  static const thumbnail = ImageProcessingConfig(
    maxWidth: 150,
    maxHeight: 150,
    quality: 60,
    maxSizeBytes: 30 * 1024, // 30KB
  );
}

/// Resultado do processamento de imagem
class ProcessedImage {
  /// Bytes da imagem processada
  final Uint8List bytes;

  /// String Base64 com prefixo data URI
  final String base64DataUri;

  /// String Base64 pura (sem prefixo)
  final String base64;

  /// Largura final em pixels
  final int width;

  /// Altura final em pixels
  final int height;

  /// Tamanho em bytes
  final int sizeBytes;

  /// MIME type
  final String mimeType;

  /// Tamanho original antes do processamento
  final int originalSizeBytes;

  /// Taxa de compressão (0.0 - 1.0)
  double get compressionRatio =>
      originalSizeBytes > 0 ? sizeBytes / originalSizeBytes : 1.0;

  /// Economia em bytes
  int get savedBytes => originalSizeBytes - sizeBytes;

  /// Economia em porcentagem
  double get savedPercent =>
      originalSizeBytes > 0 ? (savedBytes / originalSizeBytes) * 100 : 0.0;

  const ProcessedImage({
    required this.bytes,
    required this.base64DataUri,
    required this.base64,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.mimeType,
    required this.originalSizeBytes,
  });
}

/// Serviço de processamento de imagens para o monorepo
///
/// Responsável por:
/// - Redimensionar imagens mantendo aspect ratio
/// - Comprimir para caber no limite de tamanho
/// - Converter para Base64
/// - Garantir compatibilidade cross-platform
class ImageProcessingService {
  /// Instância singleton
  static final ImageProcessingService instance = ImageProcessingService._();

  ImageProcessingService._();

  /// Processa uma imagem a partir de bytes
  ///
  /// [imageBytes] - Bytes da imagem original
  /// [config] - Configuração de processamento (default: standard)
  ///
  /// Retorna [ProcessedImage] com imagem otimizada
  Future<ProcessedImage> processImage(
    Uint8List imageBytes, {
    ImageProcessingConfig config = ImageProcessingConfig.standard,
  }) async {
    // Usar compute para não bloquear a UI
    return compute(_processImageIsolate, _ProcessImageParams(
      imageBytes: imageBytes,
      config: config,
    ));
  }

  /// Processa imagem a partir de Base64
  Future<ProcessedImage> processBase64Image(
    String base64String, {
    ImageProcessingConfig config = ImageProcessingConfig.standard,
  }) async {
    // Remover prefixo data URI se existir
    String cleanBase64 = base64String;
    if (base64String.startsWith('data:')) {
      cleanBase64 = base64String.split(',').last;
    }

    final bytes = base64Decode(cleanBase64);
    return processImage(bytes, config: config);
  }

  /// Valida se uma imagem está dentro dos limites
  bool isValidSize(Uint8List imageBytes, {int? maxBytes}) {
    final limit = maxBytes ?? ImageProcessingConfig.standard.maxSizeBytes;
    return imageBytes.length <= limit;
  }

  /// Calcula o tamanho estimado de Base64 para bytes
  int estimateBase64Size(int bytesSize) {
    // Base64 aumenta ~33% o tamanho
    return (bytesSize * 4 / 3).ceil();
  }

  /// Verifica se uma string é Base64 válido de imagem
  bool isValidBase64Image(String base64String) {
    try {
      String cleanBase64 = base64String;
      if (base64String.startsWith('data:')) {
        if (!base64String.startsWith('data:image/')) {
          return false;
        }
        cleanBase64 = base64String.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      if (bytes.isEmpty) return false;

      // Verificar magic bytes de formatos comuns
      if (bytes.length < 4) return false;

      // JPEG: FF D8 FF
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return true;
      }

      // PNG: 89 50 4E 47
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return true;
      }

      // WebP: 52 49 46 46 ... 57 45 42 50
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46) {
        return true;
      }

      // GIF: 47 49 46 38
      if (bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Parâmetros para processamento em isolate
class _ProcessImageParams {
  final Uint8List imageBytes;
  final ImageProcessingConfig config;

  const _ProcessImageParams({
    required this.imageBytes,
    required this.config,
  });
}

/// Função de processamento que roda em isolate separado
ProcessedImage _processImageIsolate(_ProcessImageParams params) {
  final originalSize = params.imageBytes.length;
  final config = params.config;

  // Decodificar imagem
  final image = img.decodeImage(params.imageBytes);
  if (image == null) {
    throw Exception('Não foi possível decodificar a imagem');
  }

  // Redimensionar se necessário
  img.Image resizedImage = image;
  if (image.width > config.maxWidth || image.height > config.maxHeight) {
    resizedImage = _resizeImage(image, config.maxWidth, config.maxHeight);
  }

  // Comprimir com qualidade inicial
  int quality = config.quality;
  Uint8List compressedBytes;

  // Loop para garantir que fique abaixo do limite
  do {
    compressedBytes = Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: quality),
    );

    // Se ainda estiver acima do limite, reduzir qualidade
    if (compressedBytes.length > config.maxSizeBytes && quality > 30) {
      quality -= 10;
    } else {
      break;
    }
  } while (quality > 30);

  // Se ainda estiver acima do limite após reduzir qualidade, redimensionar mais
  if (compressedBytes.length > config.maxSizeBytes) {
    const scaleFactor = 0.8;
    final newWidth = (resizedImage.width * scaleFactor).round();
    final newHeight = (resizedImage.height * scaleFactor).round();

    resizedImage = img.copyResize(
      resizedImage,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );

    compressedBytes = Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: quality),
    );
  }

  // Gerar Base64
  final base64String = base64Encode(compressedBytes);
  final base64DataUri = 'data:image/jpeg;base64,$base64String';

  return ProcessedImage(
    bytes: compressedBytes,
    base64DataUri: base64DataUri,
    base64: base64String,
    width: resizedImage.width,
    height: resizedImage.height,
    sizeBytes: compressedBytes.length,
    mimeType: 'image/jpeg',
    originalSizeBytes: originalSize,
  );
}

/// Redimensiona imagem mantendo aspect ratio
img.Image _resizeImage(img.Image image, int maxWidth, int maxHeight) {
  int newWidth = image.width;
  int newHeight = image.height;

  // Calcular novo tamanho mantendo proporção
  if (newWidth > maxWidth || newHeight > maxHeight) {
    final aspectRatio = newWidth / newHeight;

    if (aspectRatio > 1) {
      // Imagem mais larga que alta
      newWidth = maxWidth;
      newHeight = (maxWidth / aspectRatio).round();
    } else {
      // Imagem mais alta que larga
      newHeight = maxHeight;
      newWidth = (maxHeight * aspectRatio).round();
    }
  }

  return img.copyResize(
    image,
    width: newWidth,
    height: newHeight,
    interpolation: img.Interpolation.linear,
  );
}
