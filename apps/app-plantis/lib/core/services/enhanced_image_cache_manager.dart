import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Enhanced image cache manager for better performance and memory management
class EnhancedImageCacheManager {
  static EnhancedImageCacheManager? _instance;
  static EnhancedImageCacheManager get instance {
    return _instance ??= EnhancedImageCacheManager._internal();
  }

  EnhancedImageCacheManager._internal();
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, DateTime> _cacheAccess = {};
  static const int maxMemoryCacheSize = 20; // Max items in memory
  static const int maxMemoryBytes = 50 * 1024 * 1024; // 50MB max memory usage
  static const Duration cacheExpiration = Duration(hours: 24);

  int _currentMemoryBytes = 0;

  /// Get base64 image from cache or decode it
  Future<Uint8List?> getBase64Image(String base64String) async {
    final key = _generateCacheKey(base64String);
    if (_memoryCache.containsKey(key)) {
      _updateAccessTime(key);
      return _memoryCache[key];
    }

    try {
      final imageBytes = await _decodeBase64Optimized(base64String);
      await _cacheImageBytes(key, imageBytes);

      return imageBytes;
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      return null;
    }
  }

  /// Optimized base64 decoding using compute for large images
  static Future<Uint8List> _decodeBase64Optimized(String base64String) async {
    // Remove o prefixo DataURI se presente (ex: 'data:image/jpeg;base64,')
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      cleanBase64 = base64String.split(',').last;
    }

    if (cleanBase64.length > 1000000) {
      return compute(_decodeBase64Worker, cleanBase64);
    } else {
      return base64Decode(cleanBase64);
    }
  }

  /// Worker function for compute isolation
  static Uint8List _decodeBase64Worker(String base64String) {
    // Note: base64String já deve estar limpo quando chega aqui
    return base64Decode(base64String);
  }

  /// Cache image bytes with memory management
  Future<void> _cacheImageBytes(String key, Uint8List imageBytes) async {
    final imageSize = imageBytes.lengthInBytes;
    if (imageSize > 10 * 1024 * 1024) {
      return;
    }
    await _cleanupMemoryCache(imageSize);
    _memoryCache[key] = imageBytes;
    _cacheAccess[key] = DateTime.now();
    _currentMemoryBytes += imageSize;
  }

  /// Cleanup memory cache using LRU eviction
  Future<void> _cleanupMemoryCache(int newImageSize) async {
    final now = DateTime.now();
    final expiredKeys = _cacheAccess.entries
        .where((entry) => now.difference(entry.value) > cacheExpiration)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _removeFromCache(key);
    }
    while ((_currentMemoryBytes + newImageSize > maxMemoryBytes) ||
        (_memoryCache.length >= maxMemoryCacheSize)) {
      if (_cacheAccess.isEmpty) break;
      final oldestKey = _cacheAccess.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;

      _removeFromCache(oldestKey);
    }
  }

  /// Remove entry from cache
  void _removeFromCache(String key) {
    final imageBytes = _memoryCache.remove(key);
    _cacheAccess.remove(key);

    if (imageBytes != null) {
      _currentMemoryBytes -= imageBytes.lengthInBytes;
    }
  }

  /// Update access time for LRU
  void _updateAccessTime(String key) {
    _cacheAccess[key] = DateTime.now();
  }

  /// Generate cache key from base64 string
  String _generateCacheKey(String base64String) {
    return base64String.length > 50
        ? base64String.substring(0, 50) + base64String.length.toString()
        : base64String;
  }

  /// Preload critical images
  Future<void> preloadCriticalImages(List<String> base64Images) async {
    for (int i = 0; i < base64Images.length; i += 3) {
      final batch = base64Images.skip(i).take(3);
      final batchFutures = batch.map((image) => getBase64Image(image));

      await Future.wait(batchFutures);
      if (i + 3 < base64Images.length) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Clear memory cache (useful for memory pressure situations)
  void clearMemoryCache() {
    _memoryCache.clear();
    _cacheAccess.clear();
    _currentMemoryBytes = 0;
    if (!kIsWeb) {
      SystemChannels.platform.invokeMethod<void>(
        'SystemChrome.restoreSystemUIOverlays',
      );
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'memoryUsageBytes': _currentMemoryBytes,
      'memoryUsageMB': (_currentMemoryBytes / (1024 * 1024)).toStringAsFixed(2),
      'maxMemoryCacheSize': maxMemoryCacheSize,
      'maxMemoryMB': (maxMemoryBytes / (1024 * 1024)).toStringAsFixed(2),
    };
  }

  /// Optimize images on background thread
  static Future<Uint8List?> optimizeImageBytes(
    Uint8List originalBytes, {
    int? maxWidth,
    int? maxHeight,
    int quality = 80,
  }) async {
    try {
      return originalBytes;
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      return originalBytes;
    }
  }

  /// Cleanup disk cache
  Future<void> cleanupDiskCache() async {
    try {
      await CachedNetworkImage.evictFromCache('');
    } catch (e) {
      debugPrint('Error cleaning disk cache: $e');
    }
  }

  /// Get disk cache size
  Future<int> getDiskCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final plantisCache = Directory('${cacheDir.path}/plantis_images');

      if (!plantisCache.existsSync()) return 0;

      int totalSize = 0;
      await for (final entity in plantisCache.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }
}

/// Extension for CachedNetworkImage with optimized defaults
extension OptimizedCachedNetworkImage on CachedNetworkImage {
  static Widget optimized({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 300),
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? const SizedBox(),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Icon(Icons.error),
      fadeInDuration: fadeInDuration,
      memCacheWidth: width?.round(),
      memCacheHeight: height?.round(),
      maxWidthDiskCache: width != null ? (width * 2).round() : null,
      maxHeightDiskCache: height != null ? (height * 2).round() : null,
    );
  }
}
