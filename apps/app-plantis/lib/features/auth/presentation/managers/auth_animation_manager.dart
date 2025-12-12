import 'package:flutter/material.dart';

/// Configuration for authentication page animations
class AuthAnimationConfig {
  final Duration entranceDuration;
  final Duration backgroundDuration;

  const AuthAnimationConfig({
    this.entranceDuration = const Duration(milliseconds: 1200),
    this.backgroundDuration = const Duration(seconds: 15),
  });

  static const defaultConfig = AuthAnimationConfig();
}

/// Manages animation controllers and animations for auth page
/// Extracts animation complexity from AuthPage
class AuthAnimationManager {
  late final AnimationController entranceController;
  late final AnimationController backgroundController;
  late final Animation<double> fadeInAnimation;
  late final Animation<double> slideAnimation;
  late final Animation<double> backgroundAnimation;
  late final Animation<double> logoAnimation;

  final TickerProvider vsync;
  final AuthAnimationConfig config;

  AuthAnimationManager({
    required this.vsync,
    this.config = AuthAnimationConfig.defaultConfig,
  }) {
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    entranceController = AnimationController(
      duration: config.entranceDuration,
      vsync: vsync,
    );

    backgroundController = AnimationController(
      duration: config.backgroundDuration,
      vsync: vsync,
    )..repeat();
  }

  void _initializeAnimations() {
    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: backgroundController, curve: Curves.linear),
    );

    logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
  }

  /// Starts entrance animations
  void startEntranceAnimation() {
    entranceController.forward();
  }

  /// Disposes animation controllers
  void dispose() {
    entranceController.dispose();
    backgroundController.dispose();
  }
}
