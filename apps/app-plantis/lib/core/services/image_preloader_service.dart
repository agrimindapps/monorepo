import 'dart:async';
import 'dart:collection';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'enhanced_image_cache_manager.dart';

/// Service for preloading images to improve UI performance
class ImagePreloaderService {
  static ImagePreloaderService? _instance;
  static ImagePreloaderService get instance {
    return _instance ??= ImagePreloaderService._internal();
  }

  ImagePreloaderService._internal();

  final Queue<String> _preloadQueue = Queue<String>();
  final Set<String> _preloadedImages = <String>{};
  final Set<String> _preloadingImages = <String>{};

  bool _isProcessing = false;
  Timer? _preloadTimer;
  static const int maxConcurrentPreloads = 3;
  static const Duration preloadDelay = Duration(milliseconds: 500);
  static const int maxPreloadedImages = 100;

  /// Add images to preload queue
  void preloadImages(List<String> imageUrls, {bool priority = false}) {
    final newImages = imageUrls
        .where((url) => url.isNotEmpty)
        .where((url) => !_preloadedImages.contains(url))
        .where((url) => !_preloadingImages.contains(url))
        .where((url) => !_preloadQueue.contains(url));

    if (priority) {
      final currentQueue = List<String>.from(_preloadQueue);
      _preloadQueue.clear();
      _preloadQueue.addAll(newImages);
      _preloadQueue.addAll(currentQueue);
    } else {
      _preloadQueue.addAll(newImages);
    }

    _startPreloading();
  }

  /// Preload a single image with priority
  void preloadImage(String imageUrl, {bool priority = false}) {
    preloadImages([imageUrl], priority: priority);
  }

  /// Preload images for a list of plants (for plant list optimization)
  void preloadPlantImages(List<dynamic> plants) {
    final imageUrls = <String>[];

    for (final plant in plants) {
      if (plant is Map<String, dynamic>) {
        final images = plant['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          for (final image in images) {
            if (image is String && image.isNotEmpty) {
              imageUrls.add(image);
            }
          }
        }
      }
    }

    preloadImages(imageUrls);
  }

  /// Start the preloading process
  void _startPreloading() {
    if (_isProcessing || _preloadQueue.isEmpty) return;

    _preloadTimer?.cancel();
    _preloadTimer = Timer(preloadDelay, _processPreloadQueue);
  }

  /// Process the preload queue
  Future<void> _processPreloadQueue() async {
    if (_preloadQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    final batch = <String>[];
    while (batch.length < maxConcurrentPreloads && _preloadQueue.isNotEmpty) {
      final imageUrl = _preloadQueue.removeFirst();
      if (!_preloadedImages.contains(imageUrl) &&
          !_preloadingImages.contains(imageUrl)) {
        batch.add(imageUrl);
        _preloadingImages.add(imageUrl);
      }
    }

    if (batch.isEmpty) {
      _isProcessing = false;
      return;
    }
    final futures = batch.map(_preloadSingleImage);
    await Future.wait(futures);
    if (_preloadQueue.isNotEmpty) {
      _preloadTimer = Timer(preloadDelay, _processPreloadQueue);
    } else {
      _isProcessing = false;
    }
  }

  /// Preload a single image
  Future<void> _preloadSingleImage(String imageUrl) async {
    try {
      if (imageUrl.startsWith('http')) {
        await _preloadNetworkImage(imageUrl);
      } else if (imageUrl.length > 100) {
        await _preloadBase64Image(imageUrl);
      }

      _preloadedImages.add(imageUrl);
      if (_preloadedImages.length > maxPreloadedImages) {
        final excess = _preloadedImages.length - maxPreloadedImages;
        final imagesToRemove = _preloadedImages.take(excess).toList();
        for (final image in imagesToRemove) {
          _preloadedImages.remove(image);
        }
      }
    } catch (e) {
      debugPrint('Error preloading image $imageUrl: $e');
    } finally {
      _preloadingImages.remove(imageUrl);
    }
  }

  /// Preload network image using CachedNetworkImage
  Future<void> _preloadNetworkImage(String imageUrl) async {
    try {
      final imageProvider = CachedNetworkImageProvider(imageUrl);
      final completer = Completer<void>();
      final imageStream = imageProvider.resolve(const ImageConfiguration());

      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          imageStream.removeListener(listener);
          completer.complete();
        },
        onError: (Object exception, StackTrace? stackTrace) {
          imageStream.removeListener(listener);
          completer.completeError(exception);
        },
      );

      imageStream.addListener(listener);
      await completer.future;
    } catch (e) {
      debugPrint('Error preloading network image: $e');
    }
  }

  /// Preload base64 image
  Future<void> _preloadBase64Image(String base64String) async {
    try {
      await EnhancedImageCacheManager.instance.getBase64Image(base64String);
    } catch (e) {
      debugPrint('Error preloading base64 image: $e');
    }
  }

  /// Clear preload queue and cache
  void clearPreloadQueue() {
    _preloadQueue.clear();
    _preloadingImages.clear();
    _preloadTimer?.cancel();
    _isProcessing = false;
  }

  /// Clear preloaded images cache
  void clearPreloadedCache() {
    _preloadedImages.clear();
  }

  /// Get preloader statistics
  Map<String, dynamic> getStats() {
    return {
      'queueSize': _preloadQueue.length,
      'preloadedCount': _preloadedImages.length,
      'preloadingCount': _preloadingImages.length,
      'isProcessing': _isProcessing,
    };
  }

  /// Check if an image is already preloaded
  bool isPreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }

  /// Dispose the service
  void dispose() {
    _preloadTimer?.cancel();
    clearPreloadQueue();
    clearPreloadedCache();
  }
}

/// Mixin for widgets that need to preload images
mixin ImagePreloadingMixin<T extends StatefulWidget> on State<T> {
  /// Preload images when widget is initialized
  void preloadImagesOnInit(List<String> imageUrls) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImagePreloaderService.instance.preloadImages(imageUrls);
    });
  }

  /// Preload images with priority
  void preloadImagesWithPriority(List<String> imageUrls) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImagePreloaderService.instance.preloadImages(imageUrls, priority: true);
    });
  }
}
