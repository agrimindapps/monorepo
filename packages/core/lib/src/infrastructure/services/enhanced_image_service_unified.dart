import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/result.dart';

/// Enhanced Image Service Configuration
/// Consolidates all image service configurations into one
class EnhancedImageServiceConfig {
  final int maxWidth;
  final int maxHeight;
  final int imageQuality;
  final int maxImagesCount;
  final int maxFileSizeInMB;
  final List<String> allowedFormats;
  final String defaultFolder;
  final Map<String, String> folders;
  final bool enableCaching;
  final int maxCacheSize;
  final Duration cacheExpiration;
  final int maxMemoryUsageMB;
  final bool enablePreloading;
  final int maxConcurrentPreloads;
  final int preloadQueueSize;
  final bool autoOptimize;
  final int compressionThreshold;
  final double compressionRatio;
  final int thumbnailSize;

  const EnhancedImageServiceConfig({
    this.maxWidth = 1920,
    this.maxHeight = 1920,
    this.imageQuality = 85,
    this.maxImagesCount = 5,
    this.maxFileSizeInMB = 10,
    this.allowedFormats = const ['.jpg', '.jpeg', '.png', '.webp'],
    this.defaultFolder = 'images',
    this.folders = const {},
    this.enableCaching = true,
    this.maxCacheSize = 50,
    this.cacheExpiration = const Duration(minutes: 30),
    this.maxMemoryUsageMB = 50,
    this.enablePreloading = true,
    this.maxConcurrentPreloads = 3,
    this.preloadQueueSize = 100,
    this.autoOptimize = true,
    this.compressionThreshold = 1024 * 1024, // 1MB
    this.compressionRatio = 0.8,
    this.thumbnailSize = 200,
  });

  /// Plant-specific configuration
  const EnhancedImageServiceConfig.plantis({
    this.maxWidth = 1200,
    this.maxHeight = 1200,
    this.imageQuality = 80,
    this.maxImagesCount = 5,
    this.maxFileSizeInMB = 5,
    this.allowedFormats = const ['.jpg', '.jpeg', '.png', '.webp'],
    this.defaultFolder = 'plants',
    this.folders = const {
      'plants': 'plants',
      'spaces': 'spaces',
      'tasks': 'tasks',
      'profiles': 'profiles',
    },
    this.enableCaching = true,
    this.maxCacheSize = 100, // More cache for plants
    this.cacheExpiration = const Duration(hours: 2), // Longer cache
    this.maxMemoryUsageMB = 75,
    this.enablePreloading = true,
    this.maxConcurrentPreloads = 3,
    this.preloadQueueSize = 150, // Larger queue for plants
    this.autoOptimize = true,
    this.compressionThreshold = 800 * 1024, // 800KB
    this.compressionRatio = 0.75, // Higher compression for plants
    this.thumbnailSize = 200,
  });

  /// Gasometer-specific configuration
  const EnhancedImageServiceConfig.gasometer({
    this.maxWidth = 1920,
    this.maxHeight = 1920,
    this.imageQuality = 90, // Higher quality for receipts
    this.maxImagesCount = 10,
    this.maxFileSizeInMB = 8,
    this.allowedFormats = const ['.jpg', '.jpeg', '.png', '.webp'],
    this.defaultFolder = 'receipts',
    this.folders = const {
      'receipts': 'receipts',
      'vehicles': 'vehicles',
      'maintenance': 'maintenance',
    },
    this.enableCaching = true,
    this.maxCacheSize = 30, // Less cache for receipts
    this.cacheExpiration = const Duration(hours: 6), // Longer cache
    this.maxMemoryUsageMB = 40,
    this.enablePreloading = false, // Disable preloading for receipts
    this.maxConcurrentPreloads = 1,
    this.preloadQueueSize = 20,
    this.autoOptimize = true,
    this.compressionThreshold = 2 * 1024 * 1024, // 2MB
    this.compressionRatio = 0.9, // Lower compression for receipts
    this.thumbnailSize = 300, // Larger thumbnails for receipts
  });

  EnhancedImageServiceConfig copyWith({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? maxImagesCount,
    int? maxFileSizeInMB,
    List<String>? allowedFormats,
    String? defaultFolder,
    Map<String, String>? folders,
    bool? enableCaching,
    int? maxCacheSize,
    Duration? cacheExpiration,
    int? maxMemoryUsageMB,
    bool? enablePreloading,
    int? maxConcurrentPreloads,
    int? preloadQueueSize,
    bool? autoOptimize,
    int? compressionThreshold,
    double? compressionRatio,
    int? thumbnailSize,
  }) {
    return EnhancedImageServiceConfig(
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      imageQuality: imageQuality ?? this.imageQuality,
      maxImagesCount: maxImagesCount ?? this.maxImagesCount,
      maxFileSizeInMB: maxFileSizeInMB ?? this.maxFileSizeInMB,
      allowedFormats: allowedFormats ?? this.allowedFormats,
      defaultFolder: defaultFolder ?? this.defaultFolder,
      folders: folders ?? this.folders,
      enableCaching: enableCaching ?? this.enableCaching,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      cacheExpiration: cacheExpiration ?? this.cacheExpiration,
      maxMemoryUsageMB: maxMemoryUsageMB ?? this.maxMemoryUsageMB,
      enablePreloading: enablePreloading ?? this.enablePreloading,
      maxConcurrentPreloads: maxConcurrentPreloads ?? this.maxConcurrentPreloads,
      preloadQueueSize: preloadQueueSize ?? this.preloadQueueSize,
      autoOptimize: autoOptimize ?? this.autoOptimize,
      compressionThreshold: compressionThreshold ?? this.compressionThreshold,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    );
  }
}

/// Enhanced Image Result with caching metadata
class EnhancedImageResult {
  final String downloadUrl;
  final String fileName;
  final String folder;
  final DateTime uploadedAt;
  final bool isFromCache;
  final Uint8List? thumbnail;

  const EnhancedImageResult({
    required this.downloadUrl,
    required this.fileName,
    required this.folder,
    required this.uploadedAt,
    this.isFromCache = false,
    this.thumbnail,
  });

  Map<String, dynamic> toMap() {
    return {
      'downloadUrl': downloadUrl,
      'fileName': fileName,
      'folder': folder,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isFromCache': isFromCache,
    };
  }
}

/// Image Loading Progress for monitoring
class ImageLoadProgress {
  final String url;
  final double progress; // 0.0 to 1.0
  final ImageLoadStatus status;

  const ImageLoadProgress({
    required this.url,
    required this.progress,
    required this.status,
  });
}

enum ImageLoadStatus {
  queued,
  loading,
  cached,
  completed,
  failed,
}

/// Enhanced Unified Image Service
/// Consolidates functionality from all 4 image services:
/// - Core ImageService: Selection + Upload + Basic operations
/// - EnhancedImageService: Caching + Compression + Optimization
/// - OptimizedImageService: LRU cache + Memory management
/// - ImagePreloaderService: Queue-based preloading + Priority system
class EnhancedImageServiceUnified {
  final ImagePicker _picker;
  final FirebaseStorage _storage;
  final EnhancedImageServiceConfig _config;
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Future<Uint8List?>> _loadingFutures = {};
  late final Directory _cacheDir;
  bool _initialized = false;
  final Queue<String> _preloadQueue = Queue<String>();
  final Set<String> _preloadedImages = <String>{};
  final Set<String> _preloadingImages = <String>{};
  bool _isProcessing = false;
  Timer? _preloadTimer;
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalLoaded = 0;
  int _totalSize = 0;
  int _uploadsCount = 0;
  int _preloadCount = 0;
  final StreamController<ImageLoadProgress> _progressController =
      StreamController<ImageLoadProgress>.broadcast();

  EnhancedImageServiceUnified({
    ImagePicker? picker,
    FirebaseStorage? storage,
    required EnhancedImageServiceConfig config,
  })  : _picker = picker ?? ImagePicker(),
        _storage = storage ?? FirebaseStorage.instance,
        _config = config;

  /// Initialize the service (must be called before use)
  Future<Result<void>> initialize() async {
    if (_initialized) return Result.success(null);

    try {
      if (_config.enableCaching) {
        final appDir = await getApplicationDocumentsDirectory();
        _cacheDir = Directory(path.join(appDir.path, 'enhanced_image_cache'));

        if (!await _cacheDir.exists()) {
          await _cacheDir.create(recursive: true);
        }
      }

      _initialized = true;
      debugPrint('🚀 EnhancedImageServiceUnified initialized');
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to initialize enhanced image service: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Pick single image from gallery (backward compatible)
  Future<Result<File>> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _config.maxWidth.toDouble(),
        maxHeight: _config.maxHeight.toDouble(),
        imageQuality: _config.imageQuality,
      );

      if (pickedFile == null) {
        return Result.failure(AppError.custom(
          message: 'Image selection was cancelled',
          code: 'CANCELLED',
        ));
      }

      final file = File(pickedFile.path);
      if (_config.autoOptimize) {
        final optimizedResult = await _optimizeImageIfNeeded(file);
        return optimizedResult.fold(
          (error) => Result.failure(error),
          (optimizedFile) => Result.success(optimizedFile),
        );
      }

      return Result.success(file);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to pick image from gallery: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Pick single image from camera (backward compatible)
  Future<Result<File>> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _config.maxWidth.toDouble(),
        maxHeight: _config.maxHeight.toDouble(),
        imageQuality: _config.imageQuality,
      );

      if (pickedFile == null) {
        return Result.failure(AppError.custom(
          message: 'Camera image capture was cancelled',
          code: 'CANCELLED',
        ));
      }

      final file = File(pickedFile.path);
      if (_config.autoOptimize) {
        final optimizedResult = await _optimizeImageIfNeeded(file);
        return optimizedResult.fold(
          (error) => Result.failure(error),
          (optimizedFile) => Result.success(optimizedFile),
        );
      }

      return Result.success(file);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to pick image from camera: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Pick multiple images (backward compatible)
  Future<Result<List<File>>> pickMultipleImages({int? maxImages}) async {
    try {
      final int limit = maxImages ?? _config.maxImagesCount;
      final List<XFile> pickedFiles = [];
      try {
        final medias = await _picker.pickMultipleMedia(
          limit: limit,
        );
        for (final media in medias) {
          if (media.mimeType?.startsWith('image/') ?? false) {
            pickedFiles.add(media);
          }
        }
      } catch (e) {
        return Result.failure(
          AppError.custom(
            message: 'Multiple image selection not supported on this device. Please select one image at a time.',
            code: 'MULTIPLE_SELECTION_NOT_SUPPORTED',
          ),
        );
      }

      if (pickedFiles.isEmpty) {
        return Result.failure(AppError.custom(
          message: 'Multiple images selection was cancelled',
          code: 'CANCELLED',
        ));
      }

      if (pickedFiles.length > limit) {
        return Result.failure(
          ValidationError(
            message: 'Maximum $limit images allowed',
          ),
        );
      }

      final List<File> files = [];
      for (final xfile in pickedFiles) {
        final file = File(xfile.path);
        if (_config.autoOptimize) {
          final optimizedResult = await _optimizeImageIfNeeded(file);
          final optimizedFile = optimizedResult.fold(
            (error) => file, // Use original if optimization fails
            (optimized) => optimized,
          );
          files.add(optimizedFile);
        } else {
          files.add(file);
        }
      }

      return Result.success(files);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to pick multiple images: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Upload single image (backward compatible, returns enhanced result)
  Future<Result<EnhancedImageResult>> uploadImage(
    File imageFile, {
    String? folder,
    String? fileName,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final validationResult = await _validateImageFile(imageFile);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error!);
      }
      final uploadFolder = folder ??
          _config.folders[uploadType] ??
          _config.defaultFolder;
      final String uniqueFileName = fileName ??
          '${const Uuid().v4()}.${path.extension(imageFile.path).substring(1)}';
      final storageRef = _storage
          .ref()
          .child(uploadFolder)
          .child(uniqueFileName);
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress?.call(progress);
        }
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      Uint8List? thumbnail;
      if (_config.enableCaching) {
        final thumbnailResult = await _createThumbnail(imageFile);
        thumbnail = thumbnailResult.fold(
          (error) => null,
          (data) => data,
        );
      }

      _uploadsCount++;

      final result = EnhancedImageResult(
        downloadUrl: downloadUrl,
        fileName: uniqueFileName,
        folder: uploadFolder,
        uploadedAt: DateTime.now(),
        thumbnail: thumbnail,
      );

      debugPrint('✅ Image uploaded successfully: $downloadUrl');
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to upload image: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Load cached image with intelligent caching
  Future<Result<Uint8List>> loadCachedImage(String url) async {
    if (!_config.enableCaching) {
      return _loadImageDirectly(url);
    }

    try {
      if (_memoryCache.containsKey(url)) {
        final timestamp = _cacheTimestamps[url];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _config.cacheExpiration) {
          _cacheHits++;
          debugPrint('💾 Memory cache HIT: $url');
          return Result.success(_memoryCache[url]!);
        } else {
          _removeFromCache(url);
        }
      }
      if (_loadingFutures.containsKey(url)) {
        final data = await _loadingFutures[url];
        if (data != null) {
          return Result.success(data);
        }
      }
      _cacheMisses++;
      final loadingFuture = _loadAndCacheImage(url);
      _loadingFutures[url] = loadingFuture;

      final data = await loadingFuture;
      _loadingFutures.remove(url);

      if (data != null) {
        return Result.success(data);
      } else {
        return Result.failure(
          BusinessError(
            message: 'Failed to load image',
            businessRule: 'RESOURCE_NOT_FOUND',
          ),
        );
      }
    } catch (e, stackTrace) {
      _loadingFutures.remove(url);
      return Result.failure(
        AppError.unknown(
          'Failed to load cached image: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Create thumbnail from image
  Future<Result<Uint8List>> createThumbnail(
    String imageUrl, {
    int? size,
  }) async {
    try {
      final thumbnailSize = size ?? _config.thumbnailSize;
      final cacheKey = '${imageUrl}_thumb_$thumbnailSize';
      if (_config.enableCaching && _memoryCache.containsKey(cacheKey)) {
        final timestamp = _cacheTimestamps[cacheKey];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _config.cacheExpiration) {
          return Result.success(_memoryCache[cacheKey]!);
        }
      }
      final imageResult = await loadCachedImage(imageUrl);
      if (imageResult.isFailure) {
        return Result.failure(imageResult.error!);
      }

      final originalData = imageResult.data!;
      final thumbnailData = await _resizeImage(
        originalData,
        thumbnailSize,
        thumbnailSize,
      );
      if (_config.enableCaching) {
        _addToCache(cacheKey, thumbnailData);
      }

      return Result.success(thumbnailData);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to create thumbnail: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Preload multiple images with priority support
  Future<void> preloadImages(
    List<String> imageUrls, {
    bool priority = false,
  }) async {
    if (!_config.enablePreloading || imageUrls.isEmpty) return;

    final newImages = imageUrls
        .where((url) => url.isNotEmpty)
        .where((url) => !_preloadedImages.contains(url))
        .where((url) => !_preloadingImages.contains(url))
        .where((url) => !_preloadQueue.contains(url))
        .toList();

    if (newImages.isEmpty) return;

    if (priority) {
      final currentQueue = List<String>.from(_preloadQueue);
      _preloadQueue.clear();
      _preloadQueue.addAll(newImages);
      _preloadQueue.addAll(currentQueue);
    } else {
      _preloadQueue.addAll(newImages);
    }
    while (_preloadQueue.length > _config.preloadQueueSize) {
      _preloadQueue.removeLast();
    }

    _startPreloading();
    debugPrint('📥 Added ${newImages.length} images to preload queue');
  }

  /// Preload plant-specific images (convenience method for app-plantis)
  Future<void> preloadPlantImages(List<dynamic> plants) async {
    if (!_config.enablePreloading) return;

    final imageUrls = <String>[];
    for (final plant in plants) {
      if (plant is Map<String, dynamic>) {
        final images = plant['images'] as List<dynamic>?;
        if (images != null) {
          for (final image in images) {
            if (image is String && image.isNotEmpty) {
              imageUrls.add(image);
            } else if (image is Map<String, dynamic>) {
              final url = image['url'] as String?;
              if (url != null && url.isNotEmpty) {
                imageUrls.add(url);
              }
            }
          }
        }
        final singleImage = plant['imageUrl'] as String?;
        if (singleImage != null && singleImage.isNotEmpty) {
          imageUrls.add(singleImage);
        }
      }
    }

    await preloadImages(imageUrls);
  }

  /// Check if image is preloaded
  bool isPreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl) ||
           _memoryCache.containsKey(imageUrl);
  }

  /// Clear image cache
  Future<Result<void>> clearImageCache({bool memoryOnly = false}) async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();
      _preloadedImages.clear();
      _preloadingImages.clear();
      _preloadQueue.clear();

      if (!memoryOnly && _config.enableCaching && _initialized) {
        if (await _cacheDir.exists()) {
          await _cacheDir.delete(recursive: true);
          await _cacheDir.create(recursive: true);
        }
      }
      _cacheHits = 0;
      _cacheMisses = 0;
      _totalLoaded = 0;
      _totalSize = 0;

      debugPrint('🧹 Image cache cleared (memoryOnly: $memoryOnly)');
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to clear image cache: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get comprehensive cache and service statistics
  Map<String, dynamic> getCacheStats() {
    final memoryUsageMB = _calculateMemoryUsageMB();

    return {
      'cache_enabled': _config.enableCaching,
      'preloading_enabled': _config.enablePreloading,
      'memory_cache_size': _memoryCache.length,
      'memory_usage_mb': memoryUsageMB,
      'max_memory_mb': _config.maxMemoryUsageMB,
      'memory_usage_percent': memoryUsageMB / _config.maxMemoryUsageMB * 100,
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'hit_rate_percent': _cacheHits + _cacheMisses > 0
          ? _cacheHits / (_cacheHits + _cacheMisses) * 100
          : 0,
      'total_loaded': _totalLoaded,
      'total_uploads': _uploadsCount,
      'preload_queue_size': _preloadQueue.length,
      'preloaded_images': _preloadedImages.length,
      'preloading_images': _preloadingImages.length,
      'total_preloaded': _preloadCount,
      'config': {
        'max_cache_size': _config.maxCacheSize,
        'cache_expiration_minutes': _config.cacheExpiration.inMinutes,
        'max_concurrent_preloads': _config.maxConcurrentPreloads,
        'auto_optimize': _config.autoOptimize,
        'compression_threshold_kb': _config.compressionThreshold / 1024,
        'thumbnail_size': _config.thumbnailSize,
      }
    };
  }

  /// Watch image loading progress
  Stream<ImageLoadProgress> watchImageLoading(String url) {
    return _progressController.stream
        .where((progress) => progress.url == url);
  }

  /// Dispose resources
  Future<void> dispose() async {
    _preloadTimer?.cancel();
    _progressController.close();
    debugPrint('🔌 EnhancedImageServiceUnified disposed');
  }

  Future<Result<File>> _optimizeImageIfNeeded(File imageFile) async {
    try {
      final fileSizeBytes = await imageFile.length();

      if (fileSizeBytes <= _config.compressionThreshold) {
        return Result.success(imageFile);
      }
      debugPrint('⚡ Image optimization skipped (TODO: implement compression)');
      return Result.success(imageFile);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to optimize image: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<Uint8List>> _createThumbnail(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final resized = await _resizeImage(
        bytes,
        _config.thumbnailSize,
        _config.thumbnailSize,
      );
      return Result.success(resized);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to create thumbnail: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Uint8List> _resizeImage(Uint8List data, int width, int height) async {
    return data;
  }

  Future<Result<AppError?>> _validateImageFile(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return Result.failure(
          BusinessError(
            message: 'Image file does not exist',
            businessRule: 'RESOURCE_NOT_FOUND',
          ),
        );
      }

      final fileSizeBytes = await imageFile.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (fileSizeMB > _config.maxFileSizeInMB) {
        return Result.failure(
          ValidationError(
            message: 'File size (${fileSizeMB.toStringAsFixed(1)}MB) exceeds maximum allowed size (${_config.maxFileSizeInMB}MB)',
          ),
        );
      }

      final extension = path.extension(imageFile.path).toLowerCase();
      if (!_config.allowedFormats.contains(extension)) {
        return Result.failure(
          ValidationError(
            message: 'File format $extension is not allowed. Allowed formats: ${_config.allowedFormats.join(', ')}',
          ),
        );
      }

      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to validate image file: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<Uint8List>> _loadImageDirectly(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Result.success(Uint8List.fromList(response.data!));
      } else {
        return Result.failure(
          NetworkError(
            message: 'Failed to load image: HTTP ${response.statusCode}',
            code: 'HTTP_ERROR',
          ),
        );
      }
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to load image directly: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Uint8List?> _loadAndCacheImage(String url) async {
    try {
      _progressController.add(ImageLoadProgress(
        url: url,
        progress: 0.0,
        status: ImageLoadStatus.loading,
      ));
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to load image: HTTP ${response.statusCode}');
      }

      final data = Uint8List.fromList(response.data!);

      _progressController.add(ImageLoadProgress(
        url: url,
        progress: 1.0,
        status: ImageLoadStatus.completed,
      ));
      if (_config.enableCaching) {
        _addToCache(url, data);
      }

      _totalLoaded++;
      _totalSize += data.length;

      debugPrint('📥 Image loaded and cached: $url (${data.length} bytes)');
      return data;
    } catch (e) {
      _progressController.add(ImageLoadProgress(
        url: url,
        progress: 0.0,
        status: ImageLoadStatus.failed,
      ));

      debugPrint('❌ Failed to load image: $url - $e');
      return null;
    }
  }

  void _addToCache(String key, Uint8List data) {
    if (!_config.enableCaching) return;
    if (_memoryCache.length >= _config.maxCacheSize) {
      _evictOldestCacheEntry();
    }

    final memoryUsageMB = _calculateMemoryUsageMB();
    if (memoryUsageMB >= _config.maxMemoryUsageMB) {
      _evictOldestCacheEntry();
    }

    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  void _removeFromCache(String key) {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  void _evictOldestCacheEntry() {
    if (_cacheTimestamps.isEmpty) return;
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cacheTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _removeFromCache(oldestKey);
    }
  }

  double _calculateMemoryUsageMB() {
    int totalBytes = 0;
    for (final data in _memoryCache.values) {
      totalBytes += data.length;
    }
    return totalBytes / (1024 * 1024);
  }

  void _startPreloading() async {
    if (_isProcessing || !_config.enablePreloading) return;
    if (_preloadQueue.isEmpty) return;

    _isProcessing = true;

    try {
      final List<Future<void>> futures = [];
      int concurrent = 0;

      while (_preloadQueue.isNotEmpty &&
             concurrent < _config.maxConcurrentPreloads) {
        final url = _preloadQueue.removeFirst();

        if (_preloadedImages.contains(url) ||
            _preloadingImages.contains(url)) {
          continue;
        }

        _preloadingImages.add(url);
        concurrent++;

        futures.add(_preloadSingleImage(url));
      }

      await Future.wait(futures);
    } finally {
      _isProcessing = false;
      if (_preloadQueue.isNotEmpty) {
        _preloadTimer = Timer(const Duration(milliseconds: 500), _startPreloading);
      }
    }
  }

  Future<void> _preloadSingleImage(String url) async {
    try {
      final result = await loadCachedImage(url);
      if (result.isSuccess) {
        _preloadedImages.add(url);
        _preloadCount++;
        debugPrint('✅ Preloaded image: $url');
      } else {
        debugPrint('❌ Failed to preload image: $url');
      }
    } catch (e) {
      debugPrint('❌ Error preloading image: $url - $e');
    } finally {
      _preloadingImages.remove(url);
    }
  }
}
