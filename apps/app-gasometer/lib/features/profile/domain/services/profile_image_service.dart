import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../../../core/error/failures.dart';
import '../../../../core/services/analytics/gasometer_analytics_service.dart';

/// Alias para Result até encontrarmos o import correto
class Result<T> {
  const Result._(this._data, this._failure);

  factory Result.success(T data) => Result._(data, null);
  factory Result.failure(Failure failure) => Result._(null, failure);
  final T? _data;
  final Failure? _failure;

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  T get data => _data!;
  Failure get failure => _failure!;

  void fold(void Function(Failure) onFailure, void Function(T) onSuccess) {
    if (isFailure) {
      onFailure(_failure!);
    } else {
      onSuccess(_data as T);
    }
  }
}

/// Serviço específico do Gasometer para manipulação de imagens de perfil
/// Focado em operações locais com base64 encoding

class GasometerProfileImageService {
  GasometerProfileImageService(this._analytics);
  final GasometerAnalyticsService _analytics;

  /// Processa imagem e converte para base64
  Future<Result<String>> processImageToBase64(File imageFile) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🖼️ GasometerProfileImageService: Processing image to base64',
        );
      }
      if (!await imageFile.exists()) {
        return Result.failure(
          const ValidationFailure('Arquivo de imagem não encontrado'),
        );
      }
      final fileSizeInBytes = await imageFile.length();
      const maxSizeInBytes = 5 * 1024 * 1024; // 5MB

      if (fileSizeInBytes > maxSizeInBytes) {
        return Result.failure(
          const ValidationFailure('Imagem muito grande. Máximo permitido: 5MB'),
        );
      }
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return Result.failure(
          const ValidationFailure('Formato de imagem não suportado'),
        );
      }
      img.Image resizedImage = image;
      if (image.width > 512 || image.height > 512) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 512 : null,
          height: image.height > image.width ? 512 : null,
          interpolation: img.Interpolation.cubic,
        );

        if (kDebugMode) {
          debugPrint(
            '🖼️ Image resized from ${image.width}x${image.height} to ${resizedImage.width}x${resizedImage.height}',
          );
        }
      }
      final jpegBytes = img.encodeJpg(resizedImage, quality: 85);
      final base64String = base64Encode(jpegBytes);
      await _analytics.logUserAction(
        'profile_image_processed',
        parameters: {
          'original_size_kb': (fileSizeInBytes / 1024).round(),
          'processed_size_kb': (jpegBytes.length / 1024).round(),
          'original_dimensions': '${image.width}x${image.height}',
          'processed_dimensions':
              '${resizedImage.width}x${resizedImage.height}',
        },
      );

      if (kDebugMode) {
        debugPrint(
          '🖼️ Image processed successfully: ${jpegBytes.length} bytes',
        );
      }

      return Result.success(base64String);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ GasometerProfileImageService: Error processing image: $e',
        );
      }

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'profile_image_processing_error',
      );

      return Result.failure(
        ServerFailure('Erro ao processar imagem: ${e.toString()}'),
      );
    }
  }

  /// Valida imagem antes do processamento
  /// Em web, pula validação de existência e tamanho síncronos (não suportados)
  Result<void> validateImageFile(File imageFile) {
    try {
      // Em web, dart:io não é suportado, então apenas validamos a extensão
      if (!kIsWeb) {
        if (!imageFile.existsSync()) {
          return Result.failure(
            const ValidationFailure('Arquivo não encontrado'),
          );
        }
      }

      final extension = imageFile.path.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

      final bool hasValidExtension = validExtensions.any(extension.endsWith);
      if (!hasValidExtension) {
        return Result.failure(
          const ValidationFailure(
            'Formato não suportado. Use JPG, PNG ou WebP',
          ),
        );
      }

      // Em web, não podemos validar tamanho sincronamente
      if (!kIsWeb) {
        try {
          final fileSizeInBytes = imageFile.lengthSync();
          const maxSizeInBytes = 5 * 1024 * 1024; // 5MB

          if (fileSizeInBytes > maxSizeInBytes) {
            return Result.failure(
              const ValidationFailure('Arquivo muito grande. Máximo: 5MB'),
            );
          }

          if (fileSizeInBytes == 0) {
            return Result.failure(const ValidationFailure('Arquivo está vazio'));
          }
        } catch (e) {
          return Result.failure(
            ValidationFailure('Erro ao validar tamanho: ${e.toString()}'),
          );
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ValidationFailure('Erro ao validar arquivo: ${e.toString()}'),
      );
    }
  }

  /// Converte base64 de volta para bytes (para visualização)
  Uint8List? decodeBase64ToBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error decoding base64: $e');
      }
      return null;
    }
  }

  /// Obtém informações da imagem em base64
  Map<String, dynamic>? getImageInfo(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
        'size_kb': (bytes.length / 1024).round(),
        'format': 'JPEG',
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting image info: $e');
      }
      return null;
    }
  }

  /// Cria uma thumbnail da imagem
  Future<Result<String>> createThumbnail(
    String base64String, {
    int size = 64,
  }) async {
    try {
      final bytes = base64Decode(base64String);
      final image = img.decodeImage(bytes);

      if (image == null) {
        return Result.failure(
          const ValidationFailure('Não foi possível decodificar a imagem'),
        );
      }
      final thumbnail = img.copyResizeCropSquare(image, size: size);
      final jpegBytes = img.encodeJpg(thumbnail, quality: 75);
      final thumbnailBase64 = base64Encode(jpegBytes);

      return Result.success(thumbnailBase64);
    } catch (e) {
      return Result.failure(
        ServerFailure('Erro ao criar thumbnail: ${e.toString()}'),
      );
    }
  }
}

/// Classe para representar resultado de processamento
class ImageProcessingResult {
  ImageProcessingResult({
    required this.base64String,
    required this.originalSizeKB,
    required this.processedSizeKB,
    required this.originalDimensions,
    required this.processedDimensions,
  });
  final String base64String;
  final int originalSizeKB;
  final int processedSizeKB;
  final String originalDimensions;
  final String processedDimensions;

  Map<String, dynamic> toMap() {
    return {
      'base64String': base64String,
      'originalSizeKB': originalSizeKB,
      'processedSizeKB': processedSizeKB,
      'originalDimensions': originalDimensions,
      'processedDimensions': processedDimensions,
    };
  }
}
