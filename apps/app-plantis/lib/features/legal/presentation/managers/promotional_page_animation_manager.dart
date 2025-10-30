import 'package:flutter/material.dart';

/// Gerencia o ciclo de vida e lógica de animações da página promocional
/// SRP: Isolates animation responsibilities from promotional page
class PromotionalPageAnimationManager {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  /// Inicializa o controlador de animação
  void initAnimations(TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: vsync,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  /// Retorna a animação de fade
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// Faz forward da animação
  void forward() {
    _animationController.forward();
  }

  /// Dispose do controlador
  void dispose() {
    _animationController.dispose();
  }
}
