import 'package:flutter/material.dart';

/// Gerencia a lógica de scroll para seções de documentos legais
/// SRP: Isolates scroll behavior for legal pages
class LegalPageScrollManager {
  final ScrollController scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  VoidCallback? _onScrollStateChanged;

  /// Adiciona listener para mudanças de scroll
  void addScrollListener(VoidCallback onStateChanged) {
    _onScrollStateChanged = onStateChanged;
    scrollController.addListener(_onScrollListener);
  }

  void _onScrollListener() {
    final shouldShow = scrollController.offset >= 400;
    if (shouldShow != _showScrollToTopButton) {
      _showScrollToTopButton = shouldShow;
      _onScrollStateChanged?.call();
    }
  }

  /// Faz scroll para o topo
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Retorna se deve mostrar botão
  bool get showScrollToTopButton => _showScrollToTopButton;

  /// Dispose
  void dispose() {
    scrollController.dispose();
  }
}
