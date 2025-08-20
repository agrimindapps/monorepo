// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

class ScrollService {
  static final ScrollService _instance = ScrollService._internal();
  factory ScrollService() => _instance;
  ScrollService._internal();

  // Animation to specific offset
  Future<void> animateToOffset(
    ScrollController controller,
    double offset, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!controller.hasClients) return;

    try {
      await controller.animateTo(
        offset.clamp(0.0, controller.position.maxScrollExtent),
        duration: duration,
        curve: curve,
      );
    } catch (e) {
      debugPrint('ScrollService: Error animating to offset $offset: $e');
    }
  }

  // Jump to specific offset without animation
  void jumpToOffset(ScrollController controller, double offset) {
    if (!controller.hasClients) return;

    try {
      controller.jumpTo(
        offset.clamp(0.0, controller.position.maxScrollExtent),
      );
    } catch (e) {
      debugPrint('ScrollService: Error jumping to offset $offset: $e');
    }
  }

  // Smooth scroll to top
  Future<void> scrollToTop(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOut,
  }) async {
    await animateToOffset(controller, 0.0, duration: duration, curve: curve);
  }

  // Smooth scroll to bottom
  Future<void> scrollToBottom(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOut,
  }) async {
    if (!controller.hasClients) return;

    await animateToOffset(
      controller,
      controller.position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }

  // Scroll by specific amount
  Future<void> scrollBy(
    ScrollController controller,
    double delta, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!controller.hasClients) return;

    final currentOffset = controller.offset;
    final newOffset = currentOffset + delta;
    
    await animateToOffset(controller, newOffset, duration: duration, curve: curve);
  }

  // Scroll page up
  Future<void> scrollPageUp(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!controller.hasClients) return;

    final viewportHeight = controller.position.viewportDimension;
    await scrollBy(controller, -viewportHeight * 0.8, duration: duration, curve: curve);
  }

  // Scroll page down
  Future<void> scrollPageDown(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!controller.hasClients) return;

    final viewportHeight = controller.position.viewportDimension;
    await scrollBy(controller, viewportHeight * 0.8, duration: duration, curve: curve);
  }

  // Check if at top
  bool isAtTop(ScrollController controller) {
    if (!controller.hasClients) return true;
    return controller.offset <= 0;
  }

  // Check if at bottom
  bool isAtBottom(ScrollController controller) {
    if (!controller.hasClients) return true;
    return controller.offset >= controller.position.maxScrollExtent;
  }

  // Get scroll percentage (0.0 to 1.0)
  double getScrollPercentage(ScrollController controller) {
    if (!controller.hasClients) return 0.0;
    
    final maxScrollExtent = controller.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return 0.0;
    
    return (controller.offset / maxScrollExtent).clamp(0.0, 1.0);
  }

  // Get visible area ratio
  double getVisibleAreaRatio(ScrollController controller) {
    if (!controller.hasClients) return 1.0;
    
    final viewportDimension = controller.position.viewportDimension;
    final maxScrollExtent = controller.position.maxScrollExtent;
    final totalHeight = viewportDimension + maxScrollExtent;
    
    if (totalHeight <= 0) return 1.0;
    
    return viewportDimension / totalHeight;
  }

  // Calculate velocity
  double getScrollVelocity(ScrollController controller) {
    if (!controller.hasClients) return 0.0;
    // Using a simplified approach since activity is not accessible
    return 0.0;
  }

  // Check if scrolling
  bool isScrolling(ScrollController controller) {
    if (!controller.hasClients) return false;
    // Using a simplified approach since activity is not accessible
    return false;
  }

  // Find closest section offset
  double findClosestSectionOffset(
    ScrollController controller,
    List<double> sectionOffsets,
  ) {
    if (!controller.hasClients || sectionOffsets.isEmpty) return 0.0;

    final currentOffset = controller.offset;
    double closestOffset = sectionOffsets.first;
    double minDistance = (sectionOffsets.first - currentOffset).abs();

    for (final offset in sectionOffsets) {
      final distance = (offset - currentOffset).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestOffset = offset;
      }
    }

    return closestOffset;
  }

  // Snap to closest section
  Future<void> snapToClosestSection(
    ScrollController controller,
    List<double> sectionOffsets, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    final closestOffset = findClosestSectionOffset(controller, sectionOffsets);
    await animateToOffset(controller, closestOffset, duration: duration, curve: curve);
  }

  // Check if offset is visible
  bool isOffsetVisible(
    ScrollController controller,
    double offset, {
    double threshold = 0.0,
  }) {
    if (!controller.hasClients) return false;

    final viewportStart = controller.offset;
    final viewportEnd = viewportStart + controller.position.viewportDimension;

    return offset >= (viewportStart - threshold) && 
           offset <= (viewportEnd + threshold);
  }

  // Get visible range
  (double start, double end) getVisibleRange(ScrollController controller) {
    if (!controller.hasClients) return (0.0, 0.0);

    final start = controller.offset;
    final end = start + controller.position.viewportDimension;

    return (start, end);
  }

  // Add scroll listener with debouncing
  void addDebouncedScrollListener(
    ScrollController controller,
    VoidCallback callback, {
    Duration debounceTime = const Duration(milliseconds: 100),
  }) {
    Timer? debounceTimer;

    void debouncedCallback() {
      debounceTimer?.cancel();
      debounceTimer = Timer(debounceTime, callback);
    }

    controller.addListener(debouncedCallback);
  }

  // Create scroll physics with custom behavior
  ScrollPhysics createCustomScrollPhysics({
    bool enableBouncing = true,
    bool enableSnapping = false,
    List<double>? snapOffsets,
  }) {
    ScrollPhysics physics = const ScrollPhysics();

    if (!enableBouncing) {
      physics = const ClampingScrollPhysics();
    } else {
      physics = const BouncingScrollPhysics();
    }

    if (enableSnapping && snapOffsets != null) {
      // Custom snapping physics would be implemented here
      // For now, return basic physics
    }

    return physics;
  }

  // Scroll notification handler
  bool handleScrollNotification(
    ScrollNotification notification,
    Function(double offset) onScroll,
    Function() onScrollStart,
    Function() onScrollEnd,
  ) {
    if (notification is ScrollStartNotification) {
      onScrollStart();
    } else if (notification is ScrollUpdateNotification) {
      onScroll(notification.metrics.pixels);
    } else if (notification is ScrollEndNotification) {
      onScrollEnd();
    }

    return false; // Allow other listeners to receive the notification
  }

  // Calculate scroll momentum
  double calculateScrollMomentum(ScrollController controller) {
    if (!controller.hasClients) return 0.0;
    
    final velocity = getScrollVelocity(controller);
    return velocity.abs();
  }

  // Predict scroll destination based on current velocity
  double predictScrollDestination(
    ScrollController controller, {
    double frictionCoefficient = 0.05,
  }) {
    if (!controller.hasClients) return controller.offset;

    final velocity = getScrollVelocity(controller);
    final currentOffset = controller.offset;

    // Simple physics calculation
    final destination = currentOffset + (velocity / frictionCoefficient);
    return destination.clamp(0.0, controller.position.maxScrollExtent);
  }

  // Get scroll direction - simplified implementation
  String getScrollDirection(ScrollController controller) {
    if (!controller.hasClients) return 'idle';

    final velocity = getScrollVelocity(controller);
    if (velocity > 0) {
      return 'forward';
    } else if (velocity < 0) {
      return 'reverse';
    } else {
      return 'idle';
    }
  }

  // Batch scroll operations
  Future<void> performScrollSequence(
    ScrollController controller,
    List<ScrollOperation> operations,
  ) async {
    for (final operation in operations) {
      switch (operation.type) {
        case ScrollOperationType.animateTo:
          await animateToOffset(
            controller,
            operation.offset,
            duration: operation.duration,
            curve: operation.curve,
          );
          break;
        case ScrollOperationType.jumpTo:
          jumpToOffset(controller, operation.offset);
          break;
        case ScrollOperationType.delay:
          await Future.delayed(operation.duration);
          break;
      }
    }
  }

  // Cleanup and dispose
  void disposeController(ScrollController controller) {
    try {
      controller.dispose();
    } catch (e) {
      debugPrint('ScrollService: Error disposing controller: $e');
    }
  }
}

// Supporting classes and enums
enum ScrollOperationType {
  animateTo,
  jumpTo,
  delay,
}

class ScrollOperation {
  final ScrollOperationType type;
  final double offset;
  final Duration duration;
  final Curve curve;

  const ScrollOperation({
    required this.type,
    this.offset = 0.0,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  factory ScrollOperation.animateTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeInOut,
  }) {
    return ScrollOperation(
      type: ScrollOperationType.animateTo,
      offset: offset,
      duration: duration,
      curve: curve,
    );
  }

  factory ScrollOperation.jumpTo(double offset) {
    return ScrollOperation(
      type: ScrollOperationType.jumpTo,
      offset: offset,
    );
  }

  factory ScrollOperation.delay(Duration duration) {
    return ScrollOperation(
      type: ScrollOperationType.delay,
      duration: duration,
    );
  }
}

