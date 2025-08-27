import 'package:flutter/material.dart';

/// Animation manager for Calorie Calculator
/// 
/// Responsibilities:
/// - Manage fade animations
/// - Handle transition animations
/// - Optimize animation performance
/// - Prevent memory leaks
class CalorieAnimationManager {
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;
  bool _isDisposed = false;

  /// Initialize the animation manager
  void initialize(TickerProvider tickerProvider) {
    _fadeController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0, 
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController!, 
        curve: Curves.easeInOut,
      ),
    );
    
    // Start initial animation
    _fadeController!.forward();
  }

  /// Get the fade animation for widgets
  Animation<double>? get fadeAnimation => _fadeAnimation;

  /// Trigger transition animation
  void animateTransition() {
    if (_isDisposed || _fadeController == null) return;
    
    if (_fadeController!.isCompleted || _fadeController!.isDismissed) {
      _fadeController!.reset();
      _fadeController!.forward();
    }
  }

  /// Animate fade in
  void fadeIn() {
    if (_isDisposed || _fadeController == null) return;
    _fadeController!.forward();
  }

  /// Animate fade out
  void fadeOut() {
    if (_isDisposed || _fadeController == null) return;
    _fadeController!.reverse();
  }

  /// Reset animation to beginning
  void reset() {
    if (_isDisposed || _fadeController == null) return;
    _fadeController!.reset();
  }

  /// Check if animation is running
  bool get isAnimating => 
    !_isDisposed && 
    _fadeController != null && 
    _fadeController!.isAnimating;

  /// Check if controller is disposed
  bool get isDisposed => _isDisposed;

  /// Stop current animation safely
  void stopAnimation() {
    if (_isDisposed || _fadeController == null || !_fadeController!.isAnimating) {
      return;
    }
    _fadeController!.stop();
  }

  /// Dispose of animation resources
  void dispose() {
    if (_isDisposed) return;
    
    // Stop animation before disposing
    if (_fadeController != null && _fadeController!.isAnimating) {
      _fadeController!.stop();
    }
    
    _fadeController?.dispose();
    _fadeController = null;
    _fadeAnimation = null;
    _isDisposed = true;
  }
}