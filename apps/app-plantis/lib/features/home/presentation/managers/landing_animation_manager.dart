import 'package:flutter/material.dart';

/// Manages animation lifecycle and setup for landing page
/// Isolates animation logic from page widget
class LandingAnimationManager {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// Initialize animations with given vsync provider
  void initAnimations(
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    _animationController = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
  }

  /// Start animations
  void forward() {
    _animationController.forward();
  }

  /// Get fade animation
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// Get slide animation
  Animation<Offset> get slideAnimation => _slideAnimation;

  /// Dispose resources
  void dispose() {
    _animationController.dispose();
  }
}
