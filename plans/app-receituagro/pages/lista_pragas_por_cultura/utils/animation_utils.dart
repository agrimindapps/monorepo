// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'praga_cultura_constants.dart';

class AnimationUtils {
  // Animation durations
  static const Duration defaultDuration = PragaCulturaConstants.animationDuration;
  static const Duration scaleDuration = PragaCulturaConstants.scaleAnimationDuration;
  static const Duration shimmerDuration = PragaCulturaConstants.shimmerDuration;
  static const Duration itemDelay = PragaCulturaConstants.itemDelayDuration;

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve cubicCurve = Curves.easeOutCubic;

  // Scale animation values
  static const double scaleStart = 0.8;
  static const double scaleEnd = 1.0;

  // Fade animation values
  static const double fadeStart = 0.0;
  static const double fadeEnd = 1.0;

  // Slide animation values
  static const Offset slideStart = Offset(0.3, 0);
  static const Offset slideEnd = Offset.zero;

  // Shimmer animation values
  static const double shimmerStart = 0.0;
  static const double shimmerEnd = 1.0;

  // Animation intervals
  static const Interval fadeInterval = Interval(0.0, 0.6, curve: Curves.easeOut);
  static const Interval scaleInterval = Interval(0.0, 1.0, curve: Curves.elasticOut);

  // Helper methods
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: fadeStart,
      end: fadeEnd,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: defaultCurve,
    ));
  }

  static Animation<double> createScaleAnimation(AnimationController controller) {
    return Tween<double>(
      begin: scaleStart,
      end: scaleEnd,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: elasticCurve,
    ));
  }

  static Animation<Offset> createSlideAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: slideStart,
      end: slideEnd,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: cubicCurve,
    ));
  }

  static Animation<double> createShimmerAnimation(AnimationController controller) {
    return Tween<double>(
      begin: shimmerStart,
      end: shimmerEnd,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: defaultCurve,
    ));
  }

  // Animation utilities
  static Duration getDelayForIndex(int index) {
    return itemDelay * index;
  }

  static bool shouldAnimate(AnimationController controller) {
    return !controller.isAnimating;
  }

  // Transition builders
  static Widget buildFadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget buildScaleTransition(Animation<double> animation, Widget child) {
    return Transform.scale(
      scale: animation.value,
      child: child,
    );
  }

  static Widget buildSlideTransition(Animation<Offset> animation, Widget child) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  // Complex transition builder
  static Widget buildComplexTransition({
    required Animation<double> fadeAnimation,
    required Animation<double> scaleAnimation,
    required Animation<Offset> slideAnimation,
    required Widget child,
  }) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Transform.scale(
          scale: scaleAnimation.value,
          child: child,
        ),
      ),
    );
  }

  // Shimmer gradient builder
  static LinearGradient buildShimmerGradient({
    required double animationValue,
    required bool isDark,
  }) {
    final colors = isDark
        ? [
            Colors.grey.shade800,
            Colors.grey.shade700,
            Colors.grey.shade800,
          ]
        : [
            Colors.grey.shade300,
            Colors.grey.shade200,
            Colors.grey.shade300,
          ];

    return LinearGradient(
      colors: colors,
      stops: [
        (animationValue - 0.3).clamp(0.0, 1.0),
        animationValue.clamp(0.0, 1.0),
        (animationValue + 0.3).clamp(0.0, 1.0),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}
