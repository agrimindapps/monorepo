// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Helper class to determine device performance characteristics
/// and optimize loading thresholds accordingly
class DevicePerformanceHelper {

  /// Determines the device performance tier
  static DevicePerformanceTier getPerformanceTier() {
    if (kIsWeb) {
      return DevicePerformanceTier.midRange;
    }

    // For mobile platforms, use basic heuristics
    if (Platform.isIOS) {
      return DevicePerformanceTier.highEnd; // iOS devices generally have good performance
    }

    if (Platform.isAndroid) {
      // Basic Android performance detection
      return DevicePerformanceTier.midRange;
    }

    return DevicePerformanceTier.midRange;
  }

  /// Gets optimized loading thresholds based on device performance
  static LoadingThresholds getOptimizedThresholds() {
    final tier = getPerformanceTier();
    
    switch (tier) {
      case DevicePerformanceTier.lowEnd:
        return const LoadingThresholds(
          imagePreloadCount: 1,
          maxConcurrentImageLoads: 2,
          itemsPerPage: 3,
          imageQuality: ImageQuality.low,
          enableImageCaching: true,
          preloadDistance: 0.5,
        );
      
      case DevicePerformanceTier.midRange:
        return const LoadingThresholds(
          imagePreloadCount: 2,
          maxConcurrentImageLoads: 3,
          itemsPerPage: 5,
          imageQuality: ImageQuality.medium,
          enableImageCaching: true,
          preloadDistance: 0.7,
        );
      
      case DevicePerformanceTier.highEnd:
        return const LoadingThresholds(
          imagePreloadCount: 3,
          maxConcurrentImageLoads: 5,
          itemsPerPage: 8,
          imageQuality: ImageQuality.high,
          enableImageCaching: true,
          preloadDistance: 1.0,
        );
    }
  }

  /// Gets optimized image dimensions based on screen size and performance
  static ImageDimensions getOptimizedImageDimensions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final tier = getPerformanceTier();
    
    // Base dimensions for carousel images
    int carouselWidth = (size.width * 0.6 * pixelRatio).round();
    int carouselHeight = (280 * pixelRatio).round();
    
    // Base dimensions for avatar images
    int avatarSize = (40 * pixelRatio).round();
    
    // Adjust based on performance tier
    switch (tier) {
      case DevicePerformanceTier.lowEnd:
        carouselWidth = (carouselWidth * 0.7).round();
        carouselHeight = (carouselHeight * 0.7).round();
        avatarSize = (avatarSize * 0.8).round();
        break;
      case DevicePerformanceTier.midRange:
        // Use base dimensions
        break;
      case DevicePerformanceTier.highEnd:
        carouselWidth = (carouselWidth * 1.2).round();
        carouselHeight = (carouselHeight * 1.2).round();
        break;
    }
    
    return ImageDimensions(
      carouselWidth: carouselWidth,
      carouselHeight: carouselHeight,
      avatarSize: avatarSize,
    );
  }

  /// Determines if the device should use reduced animations
  static bool shouldUseReducedAnimations() {
    final tier = getPerformanceTier();
    return tier == DevicePerformanceTier.lowEnd;
  }
}

enum DevicePerformanceTier {
  lowEnd,
  midRange,
  highEnd,
}

enum ImageQuality {
  low,
  medium,
  high,
}

class LoadingThresholds {
  final int imagePreloadCount;
  final int maxConcurrentImageLoads;
  final int itemsPerPage;
  final ImageQuality imageQuality;
  final bool enableImageCaching;
  final double preloadDistance;

  const LoadingThresholds({
    required this.imagePreloadCount,
    required this.maxConcurrentImageLoads,
    required this.itemsPerPage,
    required this.imageQuality,
    required this.enableImageCaching,
    required this.preloadDistance,
  });
}

class ImageDimensions {
  final int carouselWidth;
  final int carouselHeight;
  final int avatarSize;

  const ImageDimensions({
    required this.carouselWidth,
    required this.carouselHeight,
    required this.avatarSize,
  });
}
