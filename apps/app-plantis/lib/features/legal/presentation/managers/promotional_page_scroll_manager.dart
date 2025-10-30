import 'package:flutter/material.dart';

/// Gerencia a lógica de navegação e scroll para seções da página promocional
/// SRP: Isolates scroll navigation logic from promotional page
class PromotionalPageScrollManager {
  final ScrollController scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  VoidCallback? _onScrollToTopChanged;

  /// Escuta mudanças de scroll
  void addScrollListener(VoidCallback onScrollToTopChanged) {
    _onScrollToTopChanged = onScrollToTopChanged;
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final shouldShow = scrollController.offset >= 400;
    if (shouldShow != _showScrollToTopButton) {
      _showScrollToTopButton = shouldShow;
      _onScrollToTopChanged?.call();
    }
  }

  /// Faz scroll para uma seção específica
  void scrollToSection(GlobalKey? key) {
    final context = key?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
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

  /// Retorna se deve mostrar botão de scroll to top
  bool get showScrollToTopButton => _showScrollToTopButton;

  /// Dispose
  void dispose() {
    scrollController.dispose();
  }
}
