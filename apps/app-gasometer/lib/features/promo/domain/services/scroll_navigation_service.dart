import 'package:flutter/material.dart';

/// Service responsible for smooth scrolling to sections
/// Follows SRP by handling only scroll navigation logic

class ScrollNavigationService {
  /// Scroll to a specific section identified by GlobalKey
  void scrollToSection(
    GlobalKey key, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOut,
  }) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: duration, curve: curve);
    }
  }

  /// Scroll to a specific offset
  void scrollToOffset(
    ScrollController controller,
    double offset, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOut,
  }) {
    controller.animateTo(offset, duration: duration, curve: curve);
  }

  /// Scroll to top
  void scrollToTop(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOut,
  }) {
    scrollToOffset(controller, 0, duration: duration, curve: curve);
  }

  /// Scroll to bottom
  void scrollToBottom(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOut,
  }) {
    scrollToOffset(
      controller,
      controller.position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }

  /// Check if controller is at top
  bool isAtTop(ScrollController controller) {
    return controller.hasClients && controller.offset <= 0;
  }

  /// Check if controller is at bottom
  bool isAtBottom(ScrollController controller) {
    return controller.hasClients &&
        controller.offset >= controller.position.maxScrollExtent;
  }

  /// Get scroll percentage (0.0 to 1.0)
  double getScrollPercentage(ScrollController controller) {
    if (!controller.hasClients) return 0.0;

    final max = controller.position.maxScrollExtent;
    if (max == 0) return 0.0;

    return (controller.offset / max).clamp(0.0, 1.0);
  }
}
