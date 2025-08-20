// Dart imports:
import 'dart:io';
import 'dart:typed_data';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class FileValidationService {
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _maxTotalSize = 50 * 1024 * 1024; // 50MB
  static const int _maxImageWidth = 4096;
  static const int _maxImageHeight = 4096;

  // Magic numbers for file type validation
  static const Map<String, List<int>> _magicNumbers = {
    'jpg': [0xFF, 0xD8, 0xFF],
    'jpeg': [0xFF, 0xD8, 0xFF],
    'png': [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    'webp': [0x52, 0x49, 0x46, 0x46], // RIFF header
  };

  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> _allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  /// Validates a single file for security and type requirements
  static Future<FileValidationResult> validateFile(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return FileValidationResult.error('Arquivo não encontrado');
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > _maxFileSize) {
        return FileValidationResult.error(
          'Arquivo muito grande. Tamanho máximo: ${_formatFileSize(_maxFileSize)}',
        );
      }

      if (fileSize == 0) {
        return FileValidationResult.error('Arquivo vazio');
      }

      // Validate file extension
      final extension = path.extension(file.path).toLowerCase().substring(1);
      if (!_allowedExtensions.contains(extension)) {
        return FileValidationResult.error(
          'Tipo de arquivo não permitido. Permitidos: ${_allowedExtensions.join(', ')}',
        );
      }

      // Validate file content by magic numbers
      final bytes = await file.readAsBytes();
      if (!_validateMagicNumbers(bytes, extension)) {
        return FileValidationResult.error(
          'Arquivo corrompido ou tipo inválido',
        );
      }

      // Sanitize filename
      final sanitizedName = _sanitizeFilename(path.basename(file.path));

      // Additional security checks
      if (_containsSuspiciousContent(bytes)) {
        return FileValidationResult.error(
          'Conteúdo suspeito detectado no arquivo',
        );
      }

      return FileValidationResult.success(
        sanitizedName: sanitizedName,
        fileSize: fileSize,
        validatedExtension: extension,
      );
    } catch (e) {
      return FileValidationResult.error('Erro ao validar arquivo: $e');
    }
  }

  /// Validates multiple files and total size
  static Future<MultiFileValidationResult> validateFiles(
      List<File> files) async {
    if (files.isEmpty) {
      return MultiFileValidationResult.error('Nenhum arquivo selecionado');
    }

    if (files.length > 10) {
      return MultiFileValidationResult.error(
        'Muitos arquivos selecionados. Máximo: 10',
      );
    }

    final results = <FileValidationResult>[];
    int totalSize = 0;

    for (final file in files) {
      final result = await validateFile(file);
      results.add(result);

      if (result.isValid) {
        totalSize += result.fileSize!;
      }
    }

    // Check total size
    if (totalSize > _maxTotalSize) {
      return MultiFileValidationResult.error(
        'Tamanho total muito grande. Máximo: ${_formatFileSize(_maxTotalSize)}',
      );
    }

    final validResults = results.where((r) => r.isValid).toList();
    final invalidResults = results.where((r) => !r.isValid).toList();

    if (validResults.isEmpty) {
      return MultiFileValidationResult.error(
        'Nenhum arquivo válido encontrado',
      );
    }

    return MultiFileValidationResult.success(
      validFiles: validResults,
      invalidFiles: invalidResults,
      totalSize: totalSize,
    );
  }

  /// Validates magic numbers for file type verification
  static bool _validateMagicNumbers(Uint8List bytes, String extension) {
    final magic = _magicNumbers[extension];
    if (magic == null || bytes.length < magic.length) {
      return false;
    }

    for (int i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) {
        return false;
      }
    }

    // Additional validation for WebP
    if (extension == 'webp') {
      if (bytes.length < 12) return false;
      // Check for WEBP signature at offset 8
      final webpSignature = [0x57, 0x45, 0x42, 0x50]; // "WEBP"
      for (int i = 0; i < 4; i++) {
        if (bytes[8 + i] != webpSignature[i]) {
          return false;
        }
      }
    }

    return true;
  }

  /// Sanitizes filename to prevent directory traversal and other attacks
  static String _sanitizeFilename(String filename) {
    // Remove path separators and null bytes
    String sanitized =
        filename.replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1F]'), '');

    // Remove leading/trailing dots and spaces
    sanitized = sanitized.replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '');

    // Limit length
    if (sanitized.length > 100) {
      final ext = path.extension(sanitized);
      sanitized = sanitized.substring(0, 100 - ext.length) + ext;
    }

    // Ensure filename is not empty
    if (sanitized.isEmpty) {
      sanitized = 'arquivo_${DateTime.now().millisecondsSinceEpoch}';
    }

    return sanitized;
  }

  /// Checks for suspicious content patterns
  static bool _containsSuspiciousContent(Uint8List bytes) {
    final content = String.fromCharCodes(bytes);

    // Check for suspicious patterns
    final suspiciousPatterns = [
      '<script',
      'javascript:',
      'vbscript:',
      'onload=',
      'onerror=',
      'eval(',
      'document.cookie',
      'window.location',
    ];

    for (final pattern in suspiciousPatterns) {
      if (content.toLowerCase().contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  /// Generates secure filename with hash
  static String generateSecureFilename(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalName);
    final hash =
        sha256.convert(originalName.codeUnits).toString().substring(0, 8);

    return '${timestamp}_$hash$extension';
  }

  /// Formats file size for display
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Result of file validation
class FileValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sanitizedName;
  final int? fileSize;
  final String? validatedExtension;

  const FileValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.sanitizedName,
    this.fileSize,
    this.validatedExtension,
  });

  factory FileValidationResult.success({
    required String sanitizedName,
    required int fileSize,
    required String validatedExtension,
  }) {
    return FileValidationResult._(
      isValid: true,
      sanitizedName: sanitizedName,
      fileSize: fileSize,
      validatedExtension: validatedExtension,
    );
  }

  factory FileValidationResult.error(String message) {
    return FileValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}

/// Result of multiple file validation
class MultiFileValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<FileValidationResult>? validFiles;
  final List<FileValidationResult>? invalidFiles;
  final int? totalSize;

  const MultiFileValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.validFiles,
    this.invalidFiles,
    this.totalSize,
  });

  factory MultiFileValidationResult.success({
    required List<FileValidationResult> validFiles,
    required List<FileValidationResult> invalidFiles,
    required int totalSize,
  }) {
    return MultiFileValidationResult._(
      isValid: true,
      validFiles: validFiles,
      invalidFiles: invalidFiles,
      totalSize: totalSize,
    );
  }

  factory MultiFileValidationResult.error(String message) {
    return MultiFileValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}
