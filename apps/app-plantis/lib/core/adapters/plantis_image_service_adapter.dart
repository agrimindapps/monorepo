import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../services/image_preloader_service.dart';

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
  })  : _coreImageService = coreImageService,
        _preloaderService = preloaderService ?? ImagePreloaderService.instance;

  // ==========================================================================
  // CORE IMAGE SERVICE METHODS (Direct delegation)
  // ==========================================================================

  /// Pick single image from gallery (backward compatible)
  Future<Result<File>> pickImageFromGallery() {
    return _coreImageService.pickImageFromGallery();
  }

  /// Pick single image from camera (backward compatible)
  Future<Result<File>> pickImageFromCamera() {
    return _coreImageService.pickImageFromCamera();
  }

  /// Pick multiple images (backward compatible)
  Future<Result<List<File>>> pickMultipleImages({int? maxImages}) {
    return _coreImageService.pickMultipleImages(maxImages: maxImages);
  }

  /// Upload single image (backward compatible)
  Future<Result<ImageUploadResult>> uploadImage(
    File imageFile, {
    String? folder,
    String? fileName,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) {
    return _coreImageService.uploadImage(
      imageFile,
      folder: folder,
      fileName: fileName,
      uploadType: uploadType,
      onProgress: onProgress,
    );
  }

  /// Upload multiple images (backward compatible)
  Future<Result<MultipleImageUploadResult>> uploadMultipleImages(
    List<File> imageFiles, {
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) {
    return _coreImageService.uploadMultipleImages(
      imageFiles,
      folder: folder,
      uploadType: uploadType,
      onProgress: onProgress != null
        ? (int index, double progress) => onProgress(progress)
        : null,
    );
  }

  /// Delete image (backward compatible)
  Future<Result<void>> deleteImage(String downloadUrl) {
    return _coreImageService.deleteImage(downloadUrl);
  }

  /// Delete multiple images (backward compatible)
  Future<Result<List<AppError>>> deleteMultipleImages(List<String> downloadUrls) {
    return _coreImageService.deleteMultipleImages(downloadUrls);
  }

  /// Compress image (backward compatible)
  Future<Result<File>> compressImage(
    File imageFile, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) {
    return _coreImageService.compressImage(
      imageFile,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
  }

  // ==========================================================================
  // ENHANCED PRELOADING METHODS (ImagePreloaderService integration)
  // ==========================================================================

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
    debugPrint('📥 Preloading ${imageUrls.length} images (priority: $priority)');
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

  // ==========================================================================
  // ENHANCED CONVENIENCE METHODS (New functionality)
  // ==========================================================================

  /// Pick and upload image in one operation (new convenience method)
  Future<Result<ImageUploadResult>> pickAndUploadFromGallery({
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final pickResult = await pickImageFromGallery();

    return pickResult.fold(
      (error) => Result.failure(error),
      (imageFile) => uploadImage(
        imageFile,
        folder: folder,
        uploadType: uploadType,
        onProgress: onProgress,
      ),
    );
  }

  /// Pick and upload image from camera in one operation (new convenience method)
  Future<Result<ImageUploadResult>> pickAndUploadFromCamera({
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final pickResult = await pickImageFromCamera();

    return pickResult.fold(
      (error) => Result.failure(error),
      (imageFile) => uploadImage(
        imageFile,
        folder: folder,
        uploadType: uploadType,
        onProgress: onProgress,
      ),
    );
  }

  /// Pick and upload multiple images in one operation (new convenience method)
  Future<Result<MultipleImageUploadResult>> pickAndUploadMultiple({
    int? maxImages,
    String? folder,
    String? uploadType,
    void Function(double progress)? onProgress,
  }) async {
    final pickResult = await pickMultipleImages(maxImages: maxImages);

    return pickResult.fold(
      (error) => Result.failure(error),
      (imageFiles) => uploadMultipleImages(
        imageFiles,
        folder: folder,
        uploadType: uploadType,
        onProgress: onProgress,
      ),
    );
  }

  /// Upload image and preload it (new convenience method)
  Future<Result<ImageUploadResult>> uploadAndPreload(
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

    // Preload the uploaded image for faster display
    uploadResult.fold(
      (error) => null,
      (result) => preloadImage(result.downloadUrl, priority: true),
    );

    return uploadResult;
  }

  // ==========================================================================
  // MIGRATION HELPERS (Backward compatibility)
  // ==========================================================================

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

    // Check core service configuration
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

    // Check preloader service
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
    // ImagePreloaderService is a singleton, so we don't dispose it
    // Core ImageService doesn't require disposal
    debugPrint('🔌 PlantisImageServiceAdapter disposed');
  }
}

/// Factory class for creating pre-configured adapters
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