/// Skeleton Loading Constants for Lista Culturas Module
///
/// This file contains all skeleton loading configuration constants
/// including shimmer effects, timing, and visual parameters.

library skeleton_constants;

// Flutter imports:
import 'package:flutter/material.dart';

/// Skeleton Animation Durations
class SkeletonDurations {
  SkeletonDurations._();

  /// Duration for shimmer animation cycle
  static const Duration shimmerCycle = Duration(milliseconds: 1500);

  /// Duration for skeleton entrance animation
  static const Duration entrance = Duration(milliseconds: 600);

  /// Stagger delay between skeleton items
  static const Duration staggerDelay = Duration(milliseconds: 80);

  /// Duration for fade-in when real content loads
  static const Duration contentFadeIn = Duration(milliseconds: 400);

  /// Duration for skeleton fade-out when content appears
  static const Duration skeletonFadeOut = Duration(milliseconds: 300);

  /// Duration for progress indicator updates
  static const Duration progressUpdate = Duration(seconds: 1);

  /// Estimated loading time for progress calculation
  static const Duration estimatedLoadTime = Duration(seconds: 3);
}

/// Skeleton Animation Values
class SkeletonValues {
  SkeletonValues._();

  /// Shimmer gradient position range
  static const double shimmerStart = -1.0;
  static const double shimmerEnd = 2.0;

  /// Shimmer gradient spread
  static const double shimmerSpread = 0.3;

  /// Entrance slide distance
  static const double entranceSlideDistance = 20.0;

  /// Grid entrance slide distance (larger for more dramatic effect)
  static const double gridEntranceSlideDistance = 30.0;

  /// Fade animation opacity range
  static const double fadeStart = 0.0;
  static const double fadeEnd = 1.0;

  /// Border radius for skeleton containers
  static const double containerBorderRadius = 8.0;
  static const double avatarBorderRadius = 12.0;
  static const double smallBorderRadius = 6.0;
  static const double cardBorderRadius = 12.0;
}

/// Skeleton Dimensions
class SkeletonDimensions {
  SkeletonDimensions._();

  /// List item dimensions
  static const double listAvatarSize = 45.0;
  static const double listTitleHeight = 16.0;
  static const double listSubtitleHeight = 12.0;
  static const double listArrowSize = 12.0;

  /// Grid item dimensions
  static const double gridIconSize = 32.0;
  static const double gridTitleHeight = 16.0;
  static const double gridSubtitleHeight = 12.0;
  static const double gridTagHeight = 8.0;
  static const double gridBadgeSize = 8.0;

  /// Spacing
  static const double horizontalSpacing = 16.0;
  static const double verticalSpacing = 8.0;
  static const double smallSpacing = 6.0;
  static const double largeSpacing = 20.0;

  /// Progress indicator
  static const double progressIndicatorHeight = 4.0;
  static const double progressIconSize = 20.0;
}

/// Skeleton Colors
class SkeletonColors {
  SkeletonColors._();

  /// Light theme colors
  static const Color lightBaseColor = Color(0xFFE0E0E0);
  static const Color lightHighlightColor = Color(0xFFF5F5F5);
  static const Color lightShimmerStart = Color(0xFFE8E8E8);
  static const Color lightShimmerMiddle = Color(0xFFF0F0F0);
  static const Color lightShimmerEnd = Color(0xFFE8E8E8);

  /// Dark theme colors
  static const Color darkBaseColor = Color(0xFF2A2A2A);
  static const Color darkHighlightColor = Color(0xFF3A3A3A);
  static const Color darkShimmerStart = Color(0xFF2E2E2E);
  static const Color darkShimmerMiddle = Color(0xFF383838);
  static const Color darkShimmerEnd = Color(0xFF2E2E2E);

  /// Progress colors
  static final Color progressLight = Colors.green.shade600;
  static final Color progressDark = Colors.green.shade300;
  static final Color progressBackgroundLight = Colors.grey.shade200;
  static final Color progressBackgroundDark = Colors.grey.shade800;
}

/// Skeleton Configuration
class SkeletonConfig {
  SkeletonConfig._();

  /// Default number of skeleton items to show
  static const int defaultItemCount = 8;

  /// Reduced item count for grid view
  static const int gridItemCount = 6;

  /// Maximum staggered animations for performance
  static const int maxStaggeredItems = 10;

  /// Enable shimmer effect by default
  static const bool defaultShimmerEnabled = true;

  /// Enable entrance animations by default
  static const bool defaultEntranceEnabled = true;

  /// Enable progress indicator by default
  static const bool defaultProgressEnabled = true;
}

/// Skeleton Curves
class SkeletonCurves {
  SkeletonCurves._();

  /// Shimmer animation curve
  static const Curve shimmer = Curves.easeInOut;

  /// Entrance animation curve
  static const Curve entrance = Curves.easeOut;

  /// Grid entrance curve (more dramatic)
  static const Curve gridEntrance = Curves.easeOutBack;

  /// Fade transition curve
  static const Curve fade = Curves.easeOut;

  /// Progress indicator curve
  static const Curve progress = Curves.easeInOut;
}

/// Skeleton Intervals (for complex animations)
class SkeletonIntervals {
  SkeletonIntervals._();

  /// Fade interval for entrance animations
  static const Interval fadeIn = Interval(0.0, 0.8, curve: Curves.easeOut);

  /// Slide interval for entrance animations
  static const Interval slideIn = Interval(0.2, 1.0, curve: Curves.easeOut);

  /// Stagger interval for multiple items
  static const Interval stagger = Interval(0.0, 0.6, curve: Curves.easeOut);
}

/// Accessibility Configuration
class SkeletonAccessibility {
  SkeletonAccessibility._();

  /// Semantic labels
  static const String loadingLabel = 'Carregando lista de culturas';
  static const String progressLabel = 'Progresso do carregamento';
  static const String skeletonItemLabel = 'Item sendo carregado';

  /// Reduced motion configuration
  static const bool respectReducedMotion = true;
  static const Duration reducedMotionDuration = Duration(milliseconds: 200);

  /// High contrast support
  static const bool supportHighContrast = true;
  static const double highContrastOpacity = 0.8;
}

/// Performance Guidelines
class SkeletonPerformance {
  SkeletonPerformance._();

  /// Recommended maximum concurrent shimmer animations
  static const int maxConcurrentShimmers = 8;

  /// Enable hardware acceleration for better performance
  static const bool enableHardwareAcceleration = true;

  /// Use RepaintBoundary for complex skeleton items
  static const bool useRepaintBoundary = true;

  /// Optimize animations for 60fps
  static const int targetFps = 60;

  /// Memory usage guidelines
  static const String memoryGuideline = '''
    Keep skeleton animations lightweight:
    - Limit gradient stops to 3 colors
    - Use const constructors where possible
    - Dispose controllers properly
    - Consider using cached gradients for repeated patterns
  ''';
}
