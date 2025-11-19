import 'dart:convert';

import 'package:archive/archive.dart';

/// Serviço de compressão para storage
///
/// Responsabilidades:
/// - Compress/decompress strings grandes
/// - Threshold detection (> 1KB)
/// - Reduce storage footprint
///
/// NOTA: Esta é a implementação da lógica que estava vazia no EnhancedStorageService
class StorageCompressionService {
  static const int defaultThreshold = 1024; // 1KB

  final int compressionThreshold;

  StorageCompressionService({this.compressionThreshold = defaultThreshold});

  /// Comprime uma string se ela exceder o threshold
  ///
  /// Retorna a string comprimida em base64 ou a string original se menor que threshold
  String compress(String value) {
    if (value.isEmpty || value.length < compressionThreshold) {
      return value;
    }

    try {
      // Encode string to bytes
      final bytes = utf8.encode(value);

      // Compress using GZip
      final compressed = const GZipEncoder().encode(bytes);

      if (compressed.isEmpty) {
        return value;
      }

      // Encode to base64 com prefixo para identificar
      return 'GZIP:${base64.encode(compressed)}';
    } catch (e) {
      // Se falhar, retorna o valor original
      return value;
    }
  }

  /// Descomprime uma string comprimida
  ///
  /// Retorna a string descomprimida ou a string original se não estiver comprimida
  String decompress(String value) {
    if (value.isEmpty || !isCompressed(value)) {
      return value;
    }

    try {
      // Remove prefixo GZIP:
      final base64Data = value.substring(5);

      // Decode from base64
      final compressed = base64.decode(base64Data);

      // Decompress using GZip
      final decompressed = const GZipDecoder().decodeBytes(compressed);

      // Decode to string
      return utf8.decode(decompressed);
    } catch (e) {
      // Se falhar, retorna o valor original
      return value;
    }
  }

  /// Verifica se uma string está comprimida
  bool isCompressed(String value) {
    return value.startsWith('GZIP:');
  }

  /// Verifica se deve comprimir baseado no tamanho
  bool shouldCompress(String value) {
    return value.length >= compressionThreshold;
  }

  /// Calcula taxa de compressão
  double getCompressionRatio(String original, String compressed) {
    if (original.isEmpty) return 0.0;
    return compressed.length / original.length;
  }

  /// Obtém estatísticas de compressão
  CompressionStats getStats(String original, String compressed) {
    final originalSize = original.length;
    final compressedSize = compressed.length;
    final savedBytes = originalSize - compressedSize;
    final ratio = getCompressionRatio(original, compressed);

    return CompressionStats(
      originalSize: originalSize,
      compressedSize: compressedSize,
      savedBytes: savedBytes,
      ratio: ratio,
      savingsPercent: (1 - ratio) * 100,
    );
  }
}

/// Estatísticas de compressão
class CompressionStats {
  final int originalSize;
  final int compressedSize;
  final int savedBytes;
  final double ratio;
  final double savingsPercent;

  CompressionStats({
    required this.originalSize,
    required this.compressedSize,
    required this.savedBytes,
    required this.ratio,
    required this.savingsPercent,
  });

  @override
  String toString() {
    return 'CompressionStats('
        'original: ${_formatBytes(originalSize)}, '
        'compressed: ${_formatBytes(compressedSize)}, '
        'saved: ${_formatBytes(savedBytes)}, '
        'ratio: ${ratio.toStringAsFixed(2)}, '
        'savings: ${savingsPercent.toStringAsFixed(1)}%)';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Configuração de compressão
class CompressionConfig {
  final int threshold;
  final bool enabled;

  const CompressionConfig({
    this.threshold = StorageCompressionService.defaultThreshold,
    this.enabled = true,
  });
}
