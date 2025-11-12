import 'dart:async';
import 'dart:io';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../services/image_preloader_service.dart';

/// Plantis Image Service Adapter
///
/// Provides a seamless migration path from fragmented image services
/// to the consolidated Core ImageService with enhanced features.
///
/// Phase 1: Enhanced Integration
/// - Maintains backward compatibility with existing ImageService API
/// - Adds preloading capabilities from ImagePreloaderService
/// - Provides unified interface for image operations
///
/// This adapter consolidates functionality from:
/// - Core ImageService: Selection + Upload + Basic operations
/// - ImagePreloaderService: Queue-based preloading + Priority system
class PlantisImageServiceAdapter {
  final ImageService _coreImageService;
  final ImagePreloaderService _preloaderService;

  PlantisImageServiceAdapter({
    required ImageService coreImageService,
    ImagePreloaderService? preloaderService,
  }) : _coreImageService = coreImageService,
       _preloaderService = preloaderService ?? ImagePreloaderService.instance;

  /// Sanitiza nome de arquivo removendo espaços e caracteres especiais
  /// Essencial para compatibilidade com Firebase Storage em web
  static String _sanitizeFileName(String fileName) {
    // Remove espaços e substitui por underscore
    String sanitized = fileName.replaceAll(RegExp(r'\s+'), '_');

    // Remove caracteres especiais mantendo apenas alphanumericos, pontos, hífens e underscores
    sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');

    // Remove múltiplos underscores consecutivos
    sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');

    // Remove pontos no início
    while (sanitized.startsWith('.')) {
      sanitized = sanitized.substring(1);
    }

    // Se ficou vazio, usa um padrão
    if (sanitized.isEmpty) {
      sanitized = 'image_${DateTime.now().millisecondsSinceEpoch}';
    }

    return sanitized;
  }

  /// Pick single image from gallery (backward compatible)
  Future<Either<Failure, File>> pickImageFromGallery() async {
    final result = await _coreImageService.pickImageFromGallery();
    return result.toEither();
  }

  /// Pick single image from camera (backward compatible)
  Future<Either<Failure, File>> pickImageFromCamera() async {
    final result = await _coreImageService.pickImageFromCamera();
    return result.toEither();
  }

  /// Pick multiple images (backward compatible)
  Future<Either<Failure, List<File>>> pickMultipleImages({int? maxImages}) async {
    final result = await _coreImageService.pickMultipleImages(maxImages: maxImages);
    return result.toEither();
  }

  /// Upload single image (backward compatible)
  Future<Either<Failure, ImageUploadResult>> uploadImage(
    File imageFile, {
    String? folder,
    String? fileName,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    // Sanitiza o nome do arquivo se fornecido
    final sanitizedFileName = fileName != null ? _sanitizeFileName(fileName) : null;

    final result = await _coreImageService.uploadImage(
      imageFile,
      folder: folder,
      fileName: sanitizedFileName,
      uploadType: uploadType,
      onProgress: onProgress,
    );
    return result.toEither();
  }

  /// Upload multiple images (backward compatible)
  Future<Either<Failure, MultipleImageUploadResult>> uploadMultipleImages(
    List<File> imageFiles, {
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final result = await _coreImageService.uploadMultipleImages(
      imageFiles,
      folder: folder,
      uploadType: uploadType,
      onProgress: onProgress != null
          ? (int index, double progress) => onProgress(progress)
          : null,
    );
    return result.toEither();
  }

  /// Delete image (backward compatible)
  Future<Either<Failure, void>> deleteImage(String downloadUrl) async {
    final result = await _coreImageService.deleteImage(downloadUrl);
    return result.toEither();
  }

  /// Delete multiple images (backward compatible)
  Future<Either<Failure, List<AppError>>> deleteMultipleImages(
    List<String> downloadUrls,
  ) async {
    final result = await _coreImageService.deleteMultipleImages(downloadUrls);
    return result.toEither();
  }

  /// Compress image (backward compatible)
  Future<Either<Failure, File>> compressImage(
    File imageFile, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    final result = await _coreImageService.compressImage(
      imageFile,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
    return result.toEither();
  }

  /// Preload single image (ImagePreloaderService compatibility)
  void preloadImage(String imageUrl, {bool priority = false}) {
    if (imageUrl.isEmpty) return;

    _preloaderService.preloadImages([imageUrl], priority: priority);
    debugPrint('📥 Preloading single image: $imageUrl (priority: $priority)');
  }

  /// Preload multiple images (ImagePreloaderService compatibility)
  void preloadImages(List<String> imageUrls, {bool priority = false}) {
    if (imageUrls.isEmpty) return;

    _preloaderService.preloadImages(imageUrls, priority: priority);
    debugPrint(
      '📥 Preloading ${imageUrls.length} images (priority: $priority)',
    );
  }

  /// Preload plant images (convenience method)
  void preloadPlantImages(List<dynamic> plants) {
    _preloaderService.preloadPlantImages(plants);
    debugPrint('🌱 Preloading plant images for ${plants.length} plants');
  }

  /// Check if image is preloaded (ImagePreloaderService compatibility)
  bool isPreloaded(String imageUrl) {
    return _preloaderService.isPreloaded(imageUrl);
  }

  /// Get preloader statistics (ImagePreloaderService compatibility)
  Map<String, dynamic> getStats() {
    return _preloaderService.getStats();
  }

  /// Pick and upload image in one operation (new convenience method)
  Future<Either<Failure, ImageUploadResult>> pickAndUploadFromGallery({
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final pickResult = await pickImageFromGallery();

    return pickResult.fold(
      (failure) => Left(failure),
      (imageFile) => uploadImage(
        imageFile,
        folder: folder,
        uploadType: uploadType,
        onProgress: onProgress,
      ),
    );
  }

  /// Pick and upload image from camera in one operation (new convenience method)
  Future<Either<Failure, ImageUploadResult>> pickAndUploadFromCamera({
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final pickResult = await pickImageFromCamera();

    return pickResult.fold(
      (failure) => Left(failure),
      (imageFile) => uploadImage(
        imageFile,
        folder: folder,
        uploadType: uploadType,
        onProgress: onProgress,
      ),
    );
  }

  /// Pick and upload multiple images in one operation (new convenience method)
  Future<Either<Failure, MultipleImageUploadResult>> pickAndUploadMultiple({
    int? maxImages,
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final pickResult = await pickMultipleImages(maxImages: maxImages);

    return pickResult.fold(
      (failure) => Left(failure),
      (imageFiles) => uploadMultipleImages(
        imageFiles,
        folder: folder,
        uploadType: uploadType,
        onProgress: onProgress,
      ),
    );
  }

  /// Upload image and preload it (new convenience method)
  Future<Either<Failure, ImageUploadResult>> uploadAndPreload(
    File imageFile, {
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final uploadResult = await uploadImage(
      imageFile,
      folder: folder,
      uploadType: uploadType,
      onProgress: onProgress,
    );
    uploadResult.fold(
      (failure) => null,
      (result) => preloadImage(result.downloadUrl, priority: true),
    );

    return uploadResult;
  }

  /// Get ImageService configuration (for inspection)
  ImageServiceConfig get config => _coreImageService.config;

  /// Get comprehensive service statistics (enhanced)
  Map<String, dynamic> getComprehensiveStats() {
    final preloaderStats = _preloaderService.getStats();

    return {
      'service_type': 'PlantisImageServiceAdapter',
      'core_service_config': {
        'max_width': config.maxWidth,
        'max_height': config.maxHeight,
        'image_quality': config.imageQuality,
        'max_images_count': config.maxImagesCount,
        'max_file_size_mb': config.maxFileSizeInMB,
        'allowed_formats': config.allowedFormats,
        'default_folder': config.defaultFolder,
        'folders': config.folders,
      },
      'preloader_stats': preloaderStats,
      'integration_status': {
        'core_service_available': true,
        'preloader_service_available': true,
        'backward_compatible': true,
        'enhanced_methods_available': true,
      },
    };
  }

  /// Validate adapter configuration (health check)
  Map<String, dynamic> validateConfiguration() {
    final issues = <String>[];
    final warnings = <String>[];
    if (config.maxWidth <= 0 || config.maxHeight <= 0) {
      issues.add('Invalid image dimensions in core service');
    }

    if (config.imageQuality <= 0 || config.imageQuality > 100) {
      issues.add('Invalid image quality in core service');
    }

    if (config.maxFileSizeInMB <= 0) {
      issues.add('Invalid max file size in core service');
    }

    if (config.folders.isEmpty) {
      warnings.add('No custom folders configured, using default folder only');
    }
    final preloaderStats = _preloaderService.getStats();
    if (preloaderStats['queue_size'] as int > 50) {
      warnings.add('Large preloader queue size may impact memory usage');
    }

    return {
      'is_valid': issues.isEmpty,
      'has_warnings': warnings.isNotEmpty,
      'issues': issues,
      'warnings': warnings,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Cleanup resources (optional, for disposal)
  void dispose() {
    if (kDebugMode) {
      SecureLogger.debug('PlantisImageServiceAdapter disposed');
    }
  }
}

/// Factory class for creating pre-configured adapters
/// Note: Uses static methods as a factory pattern. No state to maintain.
// ignore: avoid_classes_with_only_static_members
class PlantisImageServiceAdapterFactory {
  /// Create adapter with plantis-optimized configuration
  static PlantisImageServiceAdapter createForPlantis() {
    final coreImageService = ImageService(
      config: const ImageServiceConfig(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
        maxFileSizeInMB: 5,
        allowedFormats: ['.jpg', '.jpeg', '.png', '.webp'],
        folders: {
          'plants': 'plants',
          'spaces': 'spaces',
          'tasks': 'tasks',
          'profiles': 'profiles',
        },
      ),
    );

    return PlantisImageServiceAdapter(
      coreImageService: coreImageService,
      preloaderService: ImagePreloaderService.instance,
    );
  }

  /// Create adapter with custom configuration
  static PlantisImageServiceAdapter createCustom({
    required ImageServiceConfig config,
    ImagePreloaderService? preloaderService,
  }) {
    final coreImageService = ImageService(config: config);

    return PlantisImageServiceAdapter(
      coreImageService: coreImageService,
      preloaderService: preloaderService,
    );
  }

  /// Create adapter from existing services (for testing)
  static PlantisImageServiceAdapter fromExisting({
    required ImageService coreImageService,
    ImagePreloaderService? preloaderService,
  }) {
    return PlantisImageServiceAdapter(
      coreImageService: coreImageService,
      preloaderService: preloaderService,
    );
  }
}
