import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Estratégia de compressão
enum CompressionStrategy {
  /// Sem compressão
  none,

  /// GZip compression (padrão Dart)
  gzip,

  /// Base64 encoding (não é compressão real, mas reduz problemas com caracteres especiais)
  base64Only,
}

/// Resultado de compressão
class CompressionResult {
  final String compressed;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final CompressionStrategy strategy;

  const CompressionResult({
    required this.compressed,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.strategy,
  });

  /// Economia de espaço em bytes
  int get savedBytes => originalSize - compressedSize;

  /// Economia de espaço em percentual
  double get savedPercent => (1 - compressionRatio) * 100;

  @override
  String toString() =>
      'CompressionResult(${originalSize}b → ${compressedSize}b, '
      '${savedPercent.toStringAsFixed(1)}% saved, strategy: $strategy)';
}

/// Serviço de compressão para dados da sync queue
///
/// Comprime dados JSON antes de salvar na queue, economizando espaço
/// e melhorando performance de I/O.
///
/// **Características:**
/// - GZip compression (nativo do Dart)
/// - Auto-detecta se compressão vale a pena
/// - Metadados para descompressão
/// - Base64 encoding para storage seguro
///
/// **Formato comprimido:**
/// ```
/// __GZIP__<base64_compressed_data>
/// ```
///
/// **Exemplo:**
/// ```dart
/// final compressor = CompressionService();
///
/// // Comprimir
/// final result = compressor.compress({'name': 'Shopping', ...});
/// print('Saved ${result.savedPercent}% space');
///
/// // Descomprimir
/// final original = compressor.decompress(result.compressed);
/// ```
class CompressionService {
  /// Tamanho mínimo para tentar compressão (bytes)
  /// Dados menores que isso não valem a pena comprimir
  final int minSizeForCompression;

  /// Estratégia padrão
  final CompressionStrategy defaultStrategy;

  /// Marcador de dados comprimidos
  static const String _gzipMarker = '__GZIP__';

  CompressionService({
    this.minSizeForCompression = 100, // 100 bytes
    this.defaultStrategy = CompressionStrategy.gzip,
  });

  /// Comprime dados JSON
  ///
  /// [data] - Map ou String para comprimir
  /// [strategy] - Estratégia (padrão: gzip)
  /// [forceCompression] - Força compressão mesmo se pequeno
  CompressionResult compress(
    dynamic data, {
    CompressionStrategy? strategy,
    bool forceCompression = false,
  }) {
    final str = _dataToString(data);
    final originalBytes = utf8.encode(str);
    final originalSize = originalBytes.length;

    final effectiveStrategy = strategy ?? defaultStrategy;

    // Skip compressão se muito pequeno (a menos que forçado)
    if (!forceCompression && originalSize < minSizeForCompression) {
      return CompressionResult(
        compressed: str,
        originalSize: originalSize,
        compressedSize: originalSize,
        compressionRatio: 1.0,
        strategy: CompressionStrategy.none,
      );
    }

    switch (effectiveStrategy) {
      case CompressionStrategy.gzip:
        return _gzipCompress(str, originalBytes, originalSize);

      case CompressionStrategy.base64Only:
        final encoded = base64Encode(originalBytes);
        return CompressionResult(
          compressed: encoded,
          originalSize: originalSize,
          compressedSize: encoded.length,
          compressionRatio: encoded.length / originalSize,
          strategy: CompressionStrategy.base64Only,
        );

      case CompressionStrategy.none:
        return CompressionResult(
          compressed: str,
          originalSize: originalSize,
          compressedSize: originalSize,
          compressionRatio: 1.0,
          strategy: CompressionStrategy.none,
        );
    }
  }

  /// Descomprime dados
  ///
  /// Auto-detecta se dados estão comprimidos pelo marcador.
  String decompress(String data) {
    // Detectar se está comprimido
    if (data.startsWith(_gzipMarker)) {
      return _gzipDecompress(data);
    }

    // Tentar base64 decode (se falhar, retorna original)
    try {
      final decoded = base64Decode(data);
      return utf8.decode(decoded);
    } catch (e) {
      // Não é base64, retorna original
      return data;
    }
  }

  /// Descomprime para Map
  Map<String, dynamic> decompressToMap(String data) {
    final decompressed = decompress(data);
    return jsonDecode(decompressed) as Map<String, dynamic>;
  }

  /// Compressão GZip
  CompressionResult _gzipCompress(
    String str,
    List<int> originalBytes,
    int originalSize,
  ) {
    try {
      // Comprimir com GZip
      final compressed = gzip.encode(originalBytes);

      // Encode em base64 para armazenamento seguro
      final base64Compressed = base64Encode(compressed);

      // Adicionar marcador para identificação
      final marked = '$_gzipMarker$base64Compressed';

      final compressedSize = marked.length;
      final ratio = compressedSize / originalSize;

      // Se compressão não ajudou muito (> 95%), retorna original
      if (ratio > 0.95) {
        debugPrint('CompressionService: GZip not worth it (ratio: $ratio)');
        return CompressionResult(
          compressed: str,
          originalSize: originalSize,
          compressedSize: originalSize,
          compressionRatio: 1.0,
          strategy: CompressionStrategy.none,
        );
      }

      debugPrint(
        'CompressionService: GZip compressed ${originalSize}b → ${compressedSize}b '
        '(${((1 - ratio) * 100).toStringAsFixed(1)}% saved)',
      );

      return CompressionResult(
        compressed: marked,
        originalSize: originalSize,
        compressedSize: compressedSize,
        compressionRatio: ratio,
        strategy: CompressionStrategy.gzip,
      );
    } catch (e) {
      debugPrint('CompressionService: GZip failed - $e');

      // Fallback: sem compressão
      return CompressionResult(
        compressed: str,
        originalSize: originalSize,
        compressedSize: originalSize,
        compressionRatio: 1.0,
        strategy: CompressionStrategy.none,
      );
    }
  }

  /// Descompressão GZip
  String _gzipDecompress(String data) {
    try {
      // Remover marcador
      final base64Data = data.substring(_gzipMarker.length);

      // Decode base64
      final compressed = base64Decode(base64Data);

      // Descomprimir GZip
      final decompressed = gzip.decode(compressed);

      // Converter para string
      return utf8.decode(decompressed);
    } catch (e) {
      debugPrint('CompressionService: GZip decompression failed - $e');
      // Fallback: retorna original (sem marcador)
      return data.substring(_gzipMarker.length);
    }
  }

  /// Converte data para string JSON
  String _dataToString(dynamic data) {
    if (data is String) {
      return data;
    }
    return jsonEncode(data);
  }
}

/// Extensão para facilitar uso
extension MapCompressionExtension on Map<String, dynamic> {
  /// Comprime este map
  String compress({CompressionService? service}) {
    final s = service ?? CompressionService();
    final result = s.compress(this);
    return result.compressed;
  }
}

extension StringDecompressionExtension on String {
  /// Descomprime esta string para Map
  Map<String, dynamic> decompressToMap({CompressionService? service}) {
    final s = service ?? CompressionService();
    return s.decompressToMap(this);
  }

  /// Descomprime esta string
  String decompress({CompressionService? service}) {
    final s = service ?? CompressionService();
    return s.decompress(this);
  }
}
