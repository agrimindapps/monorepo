import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Serviço otimizado para carregamento de imagens com cache e lazy loading
/// Resolve o problema de performance com 1181+ imagens (143MB)
///
/// Funcionalidades:
/// - Cache em memória com LRU eviction
/// - Lazy loading sob demanda
/// - Compressão de imagens na memória
/// - Pre-loading inteligente
/// - Gerenciamento de memória otimizado
class OptimizedImageService {
  static final OptimizedImageService _instance =
      OptimizedImageService._internal();
  factory OptimizedImageService() => _instance;
  OptimizedImageService._internal();
  final Map<String, Uint8List> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Future<Uint8List?>> _loadingFutures = {};
  static const int _maxCacheSize = 50; // Máximo 50 imagens em cache
  static const Duration _cacheExpiration = Duration(minutes: 30);
  static const int _maxMemoryUsageMB = 50; // Máximo 50MB em cache
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalLoaded = 0;
  int _totalSize = 0;

  /// Carrega uma imagem com cache inteligente
  Future<Uint8List?> loadImage(String imagePath) async {
    if (_cache.containsKey(imagePath)) {
      final timestamp = _cacheTimestamps[imagePath];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiration) {
        _cacheHits++;
        developer.log('Cache HIT: $imagePath', name: 'OptimizedImageService');
        return _cache[imagePath];
      } else {
        _removeFromCache(imagePath);
      }
    }
    if (_loadingFutures.containsKey(imagePath)) {
      developer.log(
        'Loading in progress: $imagePath',
        name: 'OptimizedImageService',
      );
      return await _loadingFutures[imagePath];
    }
    _cacheMisses++;
    final loadingFuture = _loadImageFromAssets(imagePath);
    _loadingFutures[imagePath] = loadingFuture;

    try {
      final imageData = await loadingFuture;
      _loadingFutures.remove(imagePath);

      if (imageData != null) {
        _addToCache(imagePath, imageData);
        developer.log(
          'Image loaded and cached: $imagePath (${imageData.length} bytes)',
          name: 'OptimizedImageService',
        );
      }

      return imageData;
    } catch (e) {
      _loadingFutures.remove(imagePath);
      developer.log(
        'Error loading image $imagePath: $e',
        name: 'OptimizedImageService',
      );
      return null;
    }
  }

  /// Carrega imagem dos assets com otimização
  Future<Uint8List?> _loadImageFromAssets(String imagePath) async {
    try {
      final ByteData data = await rootBundle.load(imagePath);
      final Uint8List bytes = data.buffer.asUint8List();
      if (bytes.length > 500000) {
        // Se > 500KB, comprime
        return await _compressImage(bytes);
      }

      _totalLoaded++;
      _totalSize += bytes.length;
      return bytes;
    } catch (e) {
      developer.log(
        'Error loading asset $imagePath: $e',
        name: 'OptimizedImageService',
      );
      if (imagePath != 'assets/imagens/bigsize/a.jpg') {
        return await _loadImageFromAssets('assets/imagens/bigsize/a.jpg');
      }

      return null;
    }
  }

  /// Comprime imagem para economizar memória
  Future<Uint8List?> _compressImage(Uint8List bytes) async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 400, // Máximo 400px de largura
        targetHeight: 400, // Máximo 400px de altura
      );

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ByteData? compressedData = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (compressedData != null) {
        final compressed = compressedData.buffer.asUint8List();
        developer.log(
          'Image compressed: ${bytes.length} -> ${compressed.length} bytes',
          name: 'OptimizedImageService',
        );
        return compressed;
      }

      return bytes;
    } catch (e) {
      developer.log(
        'Error compressing image: $e',
        name: 'OptimizedImageService',
      );
      return bytes;
    }
  }

  /// Adiciona imagem ao cache com LRU eviction
  void _addToCache(String imagePath, Uint8List imageData) {
    _cleanExpiredCache();
    if (_cache.length >= _maxCacheSize) {
      _evictOldestCacheItem();
    }
    final currentMemoryMB = _calculateTotalCacheSize() / (1024 * 1024);
    if (currentMemoryMB > _maxMemoryUsageMB) {
      _evictCacheBySize();
    }

    _cache[imagePath] = imageData;
    _cacheTimestamps[imagePath] = DateTime.now();
  }

  /// Remove item do cache
  void _removeFromCache(String imagePath) {
    _cache.remove(imagePath);
    _cacheTimestamps.remove(imagePath);
  }

  /// Limpa itens expirados do cache
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys =
        _cacheTimestamps.entries
            .where((entry) => now.difference(entry.value) > _cacheExpiration)
            .map((entry) => entry.key)
            .toList();

    for (final key in expiredKeys) {
      _removeFromCache(key);
    }
  }

  /// Remove item mais antigo do cache (LRU)
  void _evictOldestCacheItem() {
    if (_cacheTimestamps.isEmpty) return;

    final oldestEntry = _cacheTimestamps.entries.reduce(
      (a, b) => a.value.isBefore(b.value) ? a : b,
    );

    _removeFromCache(oldestEntry.key);
    developer.log(
      'Evicted oldest cache item: ${oldestEntry.key}',
      name: 'OptimizedImageService',
    );
  }

  /// Remove itens do cache até ficar abaixo do limite de memória
  void _evictCacheBySize() {
    final sortedEntries =
        _cacheTimestamps.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    while (_calculateTotalCacheSize() > _maxMemoryUsageMB * 1024 * 1024 &&
        sortedEntries.isNotEmpty) {
      final entry = sortedEntries.removeAt(0);
      _removeFromCache(entry.key);
    }
  }

  /// Calcula tamanho total do cache em bytes
  int _calculateTotalCacheSize() {
    return _cache.values
        .map((bytes) => bytes.length)
        .fold(0, (sum, size) => sum + size);
  }

  /// Pre-carrega imagens importantes
  Future<void> preloadCriticalImages() async {
    final criticalImages = [
      'assets/imagens/bigsize/a.jpg', // Fallback image
    ];

    final futures = criticalImages.map((path) => loadImage(path));
    await Future.wait(futures);

    developer.log(
      'Preloaded ${criticalImages.length} critical images',
      name: 'OptimizedImageService',
    );
  }

  /// Verifica se uma imagem existe nos assets
  Future<bool> imageExists(String imagePath) async {
    try {
      await rootBundle.load(imagePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _loadingFutures.clear();
    developer.log('Cache cleared', name: 'OptimizedImageService');
  }

  /// Estatísticas do cache para debug
  Map<String, dynamic> getStats() {
    final totalCacheSize = _calculateTotalCacheSize();
    return {
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate':
          _cacheHits + _cacheMisses > 0
              ? (_cacheHits / (_cacheHits + _cacheMisses) * 100)
                  .toStringAsFixed(1)
              : '0',
      'cachedItems': _cache.length,
      'totalCacheSizeMB': (totalCacheSize / (1024 * 1024)).toStringAsFixed(2),
      'totalImagesLoaded': _totalLoaded,
      'totalDataLoadedMB': (_totalSize / (1024 * 1024)).toStringAsFixed(2),
      'memoryUsage':
          '${(totalCacheSize / (1024 * 1024)).toStringAsFixed(1)}MB / ${_maxMemoryUsageMB}MB',
    };
  }

  /// Força coleta de lixo manual (para debug)
  void forceGarbageCollection() {
    _cleanExpiredCache();
    _evictCacheBySize();
    developer.log(
      'Forced garbage collection completed',
      name: 'OptimizedImageService',
    );
  }
}
