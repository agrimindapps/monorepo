// Dart imports:
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart';

class ImageValidationService {
  // Configurações de validação
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxMiniaturaFileSizeBytes = 2 * 1024 * 1024; // 2MB

  static const List<String> allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp'
  ];
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp'
  ];

  /// Valida um arquivo de imagem
  static Future<ImageValidationResult> validateImage(
    File file, {
    bool isMiniatura = false,
  }) async {
    try {
      // 1. Verificar se o arquivo existe
      if (!await file.exists()) {
        return ImageValidationResult.error('Arquivo não encontrado');
      }

      // 2. Validar extensão do arquivo
      final fileName = file.path.toLowerCase();
      bool hasValidExtension = false;
      for (final ext in allowedExtensions) {
        if (fileName.endsWith(ext)) {
          hasValidExtension = true;
          break;
        }
      }

      if (!hasValidExtension) {
        return ImageValidationResult.error(
            'Formato não suportado. Use apenas: ${allowedExtensions.join(', ')}');
      }

      // 3. Validar tamanho do arquivo
      final fileSize = await file.length();
      final maxSize =
          isMiniatura ? maxMiniaturaFileSizeBytes : maxFileSizeBytes;
      if (fileSize > maxSize) {
        final maxSizeMB = maxSize / (1024 * 1024);
        return ImageValidationResult.error(
            'Arquivo muito grande. Máximo: ${maxSizeMB.toStringAsFixed(1)}MB');
      }

      // 4. Validar arquivo muito pequeno (provável que não seja imagem)
      if (fileSize < 1024) {
        // 1KB
        return ImageValidationResult.error(
            'Arquivo muito pequeno. Verifique se é uma imagem válida');
      }

      // 5. Verificar cabeçalho de arquivo (magic numbers)
      final bytes = await file.readAsBytes();
      if (!_isValidImageHeader(bytes)) {
        return ImageValidationResult.error(
            'Arquivo corrompido ou não é uma imagem válida');
      }

      return ImageValidationResult.success();
    } catch (e) {
      return ImageValidationResult.error('Erro ao validar imagem: $e');
    }
  }

  /// Valida múltiplas imagens
  static Future<List<ImageValidationResult>> validateMultipleImages(
      List<File> files) async {
    final results = <ImageValidationResult>[];

    // Validar limite de arquivos
    if (files.length > 10) {
      results.add(ImageValidationResult.error('Máximo 10 imagens por vez'));
      return results;
    }

    for (final file in files) {
      final result = await validateImage(file);
      results.add(result);
    }

    return results;
  }

  /// Verifica os magic numbers para validar o tipo de arquivo
  static bool _isValidImageHeader(Uint8List bytes) {
    if (bytes.length < 12) return false;

    // JPEG (FF D8 FF)
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }

    // PNG (89 50 4E 47 0D 0A 1A 0A)
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return true;
    }

    // WebP (RIFF...WEBP)
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }

    return false;
  }

  /// Sanitiza o nome do arquivo
  static String sanitizeFileName(String fileName) {
    // Remove caracteres especiais e espaços
    String sanitized = fileName
        .replaceAll(RegExp(r'[^\w\-_\.]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .toLowerCase();

    // Garante que não comece ou termine com underscore
    sanitized = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');

    // Limita o tamanho do nome
    if (sanitized.length > 50) {
      final lastDotIndex = sanitized.lastIndexOf('.');
      if (lastDotIndex > 0) {
        final extension = sanitized.substring(lastDotIndex);
        final nameWithoutExt = sanitized.substring(0, lastDotIndex);
        sanitized = '${nameWithoutExt.substring(0, 46)}$extension';
      } else {
        sanitized = sanitized.substring(0, 50);
      }
    }

    // Se ficou vazio, gera um nome padrão
    if (sanitized.isEmpty || sanitized == '.jpg' || sanitized == '.png') {
      sanitized = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    return sanitized;
  }

  /// Gera um nome único para o arquivo
  static String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitized = sanitizeFileName(originalFileName);
    final lastDotIndex = sanitized.lastIndexOf('.');

    if (lastDotIndex > 0) {
      final extension = sanitized.substring(lastDotIndex);
      final nameWithoutExt = sanitized.substring(0, lastDotIndex);
      return '${nameWithoutExt}_$timestamp$extension';
    } else {
      return '${sanitized}_$timestamp';
    }
  }

  /// Verifica se o arquivo pode ser uma ameaça de segurança
  static Future<bool> hasSuspiciousContent(File file) async {
    try {
      final bytes = await file.readAsBytes();

      // Verifica por padrões suspeitos no conteúdo
      final content = String.fromCharCodes(bytes.take(1024)); // Primeiros 1KB

      // Padrões suspeitos comuns
      final suspiciousPatterns = [
        '<script',
        'javascript:',
        'data:',
        '<?php',
        '#!/bin/',
        'eval(',
        'exec(',
      ];

      for (final pattern in suspiciousPatterns) {
        if (content.toLowerCase().contains(pattern.toLowerCase())) {
          return true;
        }
      }

      return false;
    } catch (e) {
      // Em caso de erro, considera suspeito por segurança
      return true;
    }
  }
}

/// Classe para o resultado da validação
class ImageValidationResult {
  final bool isValid;
  final String? message;
  final ImageValidationType type;

  const ImageValidationResult._(this.isValid, this.message, this.type);

  factory ImageValidationResult.success() =>
      const ImageValidationResult._(true, null, ImageValidationType.success);

  factory ImageValidationResult.warning(String message) =>
      ImageValidationResult._(true, message, ImageValidationType.warning);

  factory ImageValidationResult.error(String message) =>
      ImageValidationResult._(false, message, ImageValidationType.error);

  bool get hasMessage => message != null && message!.isNotEmpty;
}

enum ImageValidationType { success, warning, error }
