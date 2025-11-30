import 'package:flutter/material.dart';

/// Service responsible for managing scroll behavior in legal pages
/// Follows SRP by handling only scroll-related logic
class LegalScrollControllerManager {

  LegalScrollControllerManager({
    required VoidCallback onScrollThresholdReached,
    double scrollThreshold = 400.0,
  }) : _onScrollThresholdReached = onScrollThresholdReached,
       _scrollThreshold = scrollThreshold;
  final ScrollController _scrollController = ScrollController();
  final VoidCallback _onScrollThresholdReached;
  final double _scrollThreshold;

  bool _isListening = false;

  /// Get the scroll controller instance
  ScrollController get controller => _scrollController;

  /// Initialize scroll listener
  void startListening() {
    if (!_isListening) {
      _scrollController.addListener(_handleScroll);
      _isListening = true;
    }
  }

  /// Remove scroll listener
  void stopListening() {
    if (_isListening) {
      _scrollController.removeListener(_handleScroll);
      _isListening = false;
    }
  }

  /// Dispose the scroll controller
  void dispose() {
    stopListening();
    _scrollController.dispose();
  }

  /// Check if scroll position exceeds threshold
  bool shouldShowScrollButton() {
    return _scrollController.hasClients &&
        _scrollController.offset >= _scrollThreshold;
  }

  /// Animate scroll to top
  Future<void> scrollToTop({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(0, duration: duration, curve: curve);
    }
  }

  /// Animate scroll to bottom
  Future<void> scrollToBottom({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// Scroll to a specific offset
  Future<void> scrollToOffset(
    double offset, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        offset,
        duration: duration,
        curve: curve,
      );
    }
  }

  void _handleScroll() {
    if (shouldShowScrollButton()) {
      _onScrollThresholdReached();
    }
  }

  /// Get current scroll position
  double get currentOffset =>
      _scrollController.hasClients ? _scrollController.offset : 0.0;

  /// Check if at the top of the scroll view
  bool get isAtTop => currentOffset == 0.0;

  /// Check if at the bottom of the scroll view
  bool get isAtBottom {
    if (!_scrollController.hasClients) return false;
    return _scrollController.offset >=
        _scrollController.position.maxScrollExtent;
  }
}
