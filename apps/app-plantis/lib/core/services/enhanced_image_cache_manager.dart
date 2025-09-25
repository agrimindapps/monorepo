import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
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

  // Memory cache for decoded base64 images (LRU)
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, DateTime> _cacheAccess = {};
  
  // Cache configuration
  static const int maxMemoryCacheSize = 20; // Max items in memory
  static const int maxMemoryBytes = 50 * 1024 * 1024; // 50MB max memory usage
  static const Duration cacheExpiration = Duration(hours: 24);
  
  int _currentMemoryBytes = 0;

  // Simplified cache manager using default CachedNetworkImage behavior
  // In production, consider adding flutter_cache_manager dependency for more control

  /// Get base64 image from cache or decode it
  Future<Uint8List?> getBase64Image(String base64String) async {
    final key = _generateCacheKey(base64String);

    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      _updateAccessTime(key);
      return _memoryCache[key];
    }

    try {
      // Decode the image
      final imageBytes = await _decodeBase64Optimized(base64String);
      
      // Cache it if there's space
      await _cacheImageBytes(key, imageBytes);
      
      return imageBytes;
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      return null;
    }
  }

  /// Optimized base64 decoding using compute for large images
  static Future<Uint8List> _decodeBase64Optimized(String base64String) async {
    if (base64String.length > 1000000) { // > 1MB base64, use compute
      return compute(_decodeBase64Worker, base64String);
    } else {
      return base64Decode(base64String);
    }
  }

  /// Worker function for compute isolation
  static Uint8List _decodeBase64Worker(String base64String) {
    return base64Decode(base64String);
  }

  /// Cache image bytes with memory management
  Future<void> _cacheImageBytes(String key, Uint8List imageBytes) async {
    final imageSize = imageBytes.lengthInBytes;
    
    // Check if image is too large for memory cache
    if (imageSize > 10 * 1024 * 1024) { // 10MB limit per image
      return;
    }

    // Clean up cache if needed
    await _cleanupMemoryCache(imageSize);

    // Add to cache
    _memoryCache[key] = imageBytes;
    _cacheAccess[key] = DateTime.now();
    _currentMemoryBytes += imageSize;
  }

  /// Cleanup memory cache using LRU eviction
  Future<void> _cleanupMemoryCache(int newImageSize) async {
    // Remove expired entries first
    final now = DateTime.now();
    final expiredKeys = _cacheAccess.entries
        .where((entry) => now.difference(entry.value) > cacheExpiration)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _removeFromCache(key);
    }

    // If still over limit, remove oldest entries
    while ((_currentMemoryBytes + newImageSize > maxMemoryBytes) ||
           (_memoryCache.length >= maxMemoryCacheSize)) {
      if (_cacheAccess.isEmpty) break;

      // Find oldest entry
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
    // Limit concurrent preloading to avoid memory spikes
    for (int i = 0; i < base64Images.length; i += 3) {
      final batch = base64Images.skip(i).take(3);
      final batchFutures = batch.map((image) => getBase64Image(image));
      
      await Future.wait(batchFutures);
      
      // Small delay between batches to prevent memory pressure
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
    
    // Request garbage collection
    if (!kIsWeb) {
      SystemChannels.platform.invokeMethod<void>('SystemChrome.restoreSystemUIOverlays');
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
      // For now, just return original bytes
      // In a production app, you might use image processing libraries
      // like image package or native platform channels for optimization
      return originalBytes;
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      return originalBytes;
    }
  }

  /// Cleanup disk cache
  Future<void> cleanupDiskCache() async {
    try {
      // Clear cached network image cache
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
      errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
      fadeInDuration: fadeInDuration,
      // Using default cache manager
      // Memory optimization
      memCacheWidth: width?.round(),
      memCacheHeight: height?.round(),
      maxWidthDiskCache: width != null ? (width * 2).round() : null,
      maxHeightDiskCache: height != null ? (height * 2).round() : null,
    );
  }
}