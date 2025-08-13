/// Animation Constants for Lista Culturas Module
///
/// This file contains all animation durations, curves, and configuration
/// constants used throughout the Lista Culturas module for consistent
/// micro-interactions and transitions.

library animation_constants;

// Flutter imports:
import 'package:flutter/material.dart';

/// Animation Durations
class AnimationDurations {
  AnimationDurations._();

  /// Duration for item entrance animations (staggered)
  static const Duration itemEntrance = Duration(milliseconds: 600);

  /// Additional delay per item for staggered animations
  static const Duration staggerDelay = Duration(milliseconds: 100);

  /// Duration for tap feedback animations
  static const Duration tapFeedback = Duration(milliseconds: 150);

  /// Duration for state transitions (loading, empty, content)
  static const Duration stateTransition = Duration(milliseconds: 500);

  /// Duration for search field focus animations
  static const Duration searchFocus = Duration(milliseconds: 300);

  /// Duration for loading indicator animations
  static const Duration loadingAnimation = Duration(milliseconds: 800);

  /// Duration for pulse animations
  static const Duration pulseAnimation = Duration(milliseconds: 1500);

  /// Duration for fade transitions
  static const Duration fadeTransition = Duration(milliseconds: 400);

  /// Duration for container animations
  static const Duration containerAnimation = Duration(milliseconds: 200);
}

/// Animation Curves
class AnimationCurves {
  AnimationCurves._();

  /// Curve for entrance animations with bounce effect
  static const Curve entrance = Curves.easeOutBack;

  /// Curve for tap feedback
  static const Curve tapFeedback = Curves.easeInOut;

  /// Curve for state transitions
  static const Curve stateTransition = Curves.easeInOut;

  /// Curve for elastic entrance effects
  static const Curve elasticOut = Curves.elasticOut;

  /// Curve for smooth fade effects
  static const Curve fadeOut = Curves.easeOut;

  /// Curve for focus animations
  static const Curve focus = Curves.easeInOut;
}

/// Animation Values
class AnimationValues {
  AnimationValues._();

  /// Scale values for entrance animations
  static const double entranceScaleStart = 0.5;
  static const double entranceScaleEnd = 1.0;

  /// Scale values for tap feedback
  static const double tapScaleStart = 0.95;
  static const double tapScaleEnd = 1.0;

  /// Slide distance for entrance animations
  static const double slideDistance = 50.0;

  /// Slide distance for empty state
  static const double emptyStateSlide = 30.0;

  /// Pulse animation values
  static const double pulseMin = 0.8;
  static const double pulseMax = 1.1;

  /// Rotation values for tap feedback (in turns)
  static const double rotationMin = 0.0;
  static const double rotationMax = 0.05;

  /// Arrow rotation for tap feedback
  static const double arrowRotation = 0.25;

  /// Elevation values for focus states
  static const double elevationMin = 5.0;
  static const double elevationMax = 15.0;
}

/// Animation Intervals (for complex animations)
class AnimationIntervals {
  AnimationIntervals._();

  /// Fade in interval for entrance animations
  static const Interval fadeIn = Interval(0.0, 0.6, curve: Curves.easeOut);

  /// Scale interval for entrance animations
  static const Interval scale = Interval(0.2, 0.8, curve: Curves.elasticOut);

  /// Slide interval for entrance animations
  static const Interval slide = Interval(0.4, 1.0, curve: Curves.easeOutBack);

  /// Fade interval for loading animations
  static const Interval loadingFade = Interval(0.0, 0.8, curve: Curves.easeOut);
}

/// Hero Tags for navigation animations
class HeroTags {
  HeroTags._();

  /// Generate hero tag for cultura item
  static String culturaItem(String idReg) => 'cultura_$idReg';

  /// Hero tag for search field
  static const String searchField = 'cultura_search_field';

  /// Hero tag for app bar
  static const String appBar = 'cultura_app_bar';
}

/// Animation Keys for AnimatedSwitcher widgets
class AnimationKeys {
  AnimationKeys._();

  /// Key for loading state
  static const ValueKey<String> loading = ValueKey('loading');

  /// Key for empty state
  static const ValueKey<String> empty = ValueKey('empty');

  /// Key for search icon
  static const ValueKey<String> searchIcon = ValueKey('search');

  /// Key for loading icon
  static const ValueKey<String> loadingIcon = ValueKey('loading');

  /// Key for clear button
  static const ValueKey<String> clearButton = ValueKey('clear');

  /// Key for empty clear space
  static const ValueKey<String> emptyClear = ValueKey('empty');

  /// Generate key for list content
  static ValueKey<String> listContent(int length) => ValueKey('list_$length');
}

/// Performance Guidelines
///
/// To maintain 60fps animations:
/// - Keep animation durations under 1000ms for entrance effects
/// - Use const curves when possible
/// - Limit simultaneous complex animations
/// - Profile animations on lower-end devices
/// - Consider reducing animations for accessibility preferences
class AnimationPerformance {
  AnimationPerformance._();

  /// Maximum recommended items for staggered animations
  static const int maxStaggeredItems = 10;

  /// Reduced animation duration for accessibility
  static const Duration accessibilityDuration = Duration(milliseconds: 200);

  /// Check if reduced motion is preferred
  static bool shouldReduceAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}
