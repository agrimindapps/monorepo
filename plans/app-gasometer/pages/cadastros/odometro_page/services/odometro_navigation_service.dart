// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../models/odometro_page_model.dart';

/// Service responsible for navigation logic in the Odometro module
class OdometroNavigationService extends GetxService {
  /// Navigate to specific page in carousel
  void animateToPage(int index, OdometroPageModel model) {
    model.animateToPage(index);
  }

  /// Set carousel index and update related state
  void setCarouselIndex(int index, OdometroPageModel model) {
    model.setCurrentCarouselIndex(index);

    // Update selected month if valid index
    if (index < model.monthsList.length) {
      model.setSelectedMonth(model.monthsList[index]);
    }
  }

  /// Navigate to next month in carousel
  void navigateToNextMonth(OdometroPageModel model) {
    final currentIndex = model.currentCarouselIndex.value;
    final maxIndex = model.monthsList.length - 1;

    if (currentIndex < maxIndex) {
      animateToPage(currentIndex + 1, model);
      setCarouselIndex(currentIndex + 1, model);
    }
  }

  /// Navigate to previous month in carousel
  void navigateToPreviousMonth(OdometroPageModel model) {
    final currentIndex = model.currentCarouselIndex.value;

    if (currentIndex > 0) {
      animateToPage(currentIndex - 1, model);
      setCarouselIndex(currentIndex - 1, model);
    }
  }

  /// Navigate to current month
  void navigateToCurrentMonth(OdometroPageModel model) {
    final now = DateTime.now();
    final currentMonthIndex = _findMonthIndex(now, model.monthsList);

    if (currentMonthIndex != -1) {
      animateToPage(currentMonthIndex, model);
      setCarouselIndex(currentMonthIndex, model);
    }
  }

  /// Navigate to specific month
  void navigateToMonth(DateTime month, OdometroPageModel model) {
    final monthIndex = _findMonthIndex(month, model.monthsList);

    if (monthIndex != -1) {
      animateToPage(monthIndex, model);
      setCarouselIndex(monthIndex, model);
    }
  }

  /// Get navigation state information
  NavigationState getNavigationState(OdometroPageModel model) {
    final currentIndex = model.currentCarouselIndex.value;
    final totalMonths = model.monthsList.length;

    return NavigationState(
      currentIndex: currentIndex,
      totalMonths: totalMonths,
      canNavigateNext: currentIndex < totalMonths - 1,
      canNavigatePrevious: currentIndex > 0,
      isFirstMonth: currentIndex == 0,
      isLastMonth: currentIndex == totalMonths - 1,
      selectedMonth: model.selectedMonth.value,
    );
  }

  /// Check if we can navigate to next month
  bool canNavigateNext(OdometroPageModel model) {
    final currentIndex = model.currentCarouselIndex.value;
    return currentIndex < model.monthsList.length - 1;
  }

  /// Check if we can navigate to previous month
  bool canNavigatePrevious(OdometroPageModel model) {
    final currentIndex = model.currentCarouselIndex.value;
    return currentIndex > 0;
  }

  /// Get the index of current month in months list
  int getCurrentMonthIndex(OdometroPageModel model) {
    final now = DateTime.now();
    return _findMonthIndex(now, model.monthsList);
  }

  /// Get months around current selection for quick navigation
  List<DateTime> getAdjacentMonths(OdometroPageModel model, {int radius = 2}) {
    final currentIndex = model.currentCarouselIndex.value;
    final monthsList = model.monthsList;

    final startIndex = (currentIndex - radius).clamp(0, monthsList.length - 1);
    final endIndex = (currentIndex + radius).clamp(0, monthsList.length - 1);

    return monthsList.sublist(startIndex, endIndex + 1);
  }

  /// Calculate carousel page position based on viewport
  double calculatePagePosition(
      int index, int totalPages, double viewportFraction) {
    return index.toDouble();
  }

  /// Get carousel options with optimized settings
  CarouselOptions getOptimizedCarouselOptions({
    required double height,
    required Function(int, CarouselPageChangedReason) onPageChanged,
    double viewportFraction = 1.0,
    bool enableInfiniteScroll = false,
    bool autoPlay = false,
    Duration autoPlayInterval = const Duration(seconds: 4),
    Duration autoPlayAnimationDuration = const Duration(milliseconds: 800),
    bool enlargeCenterPage = false,
  }) {
    return CarouselOptions(
      height: height,
      viewportFraction: viewportFraction,
      enableInfiniteScroll: enableInfiniteScroll,
      autoPlay: autoPlay,
      autoPlayInterval: autoPlayInterval,
      autoPlayAnimationDuration: autoPlayAnimationDuration,
      enlargeCenterPage: enlargeCenterPage,
      onPageChanged: onPageChanged,
      scrollDirection: Axis.horizontal,
      pageSnapping: true,
      padEnds: true,
    );
  }

  /// Handle swipe gestures for navigation
  void handleSwipeNavigation(
    String direction,
    OdometroPageModel model, {
    bool enableSwipe = true,
  }) {
    if (!enableSwipe) return;

    switch (direction.toLowerCase()) {
      case 'left':
        navigateToNextMonth(model);
        break;
      case 'right':
        navigateToPreviousMonth(model);
        break;
    }
  }

  /// Reset navigation to initial state
  void resetNavigation(OdometroPageModel model) {
    if (model.monthsList.isNotEmpty) {
      setCarouselIndex(0, model);
      model.setSelectedMonth(model.monthsList.first);
    }
  }

  /// Private helper method to find month index in list
  int _findMonthIndex(DateTime targetMonth, List<DateTime> monthsList) {
    for (int i = 0; i < monthsList.length; i++) {
      final month = monthsList[i];
      if (month.year == targetMonth.year && month.month == targetMonth.month) {
        return i;
      }
    }
    return -1;
  }

  /// Batch navigation operations
  void batchNavigationUpdate(
    OdometroPageModel model, {
    int? targetIndex,
    DateTime? targetMonth,
    bool animate = true,
  }) {
    int? finalIndex;

    if (targetIndex != null) {
      finalIndex = targetIndex.clamp(0, model.monthsList.length - 1);
    } else if (targetMonth != null) {
      finalIndex = _findMonthIndex(targetMonth, model.monthsList);
    }

    if (finalIndex != null && finalIndex != -1) {
      if (animate) {
        animateToPage(finalIndex, model);
      }
      setCarouselIndex(finalIndex, model);
    }
  }
}

/// Navigation state information class
class NavigationState {
  final int currentIndex;
  final int totalMonths;
  final bool canNavigateNext;
  final bool canNavigatePrevious;
  final bool isFirstMonth;
  final bool isLastMonth;
  final DateTime? selectedMonth;

  NavigationState({
    required this.currentIndex,
    required this.totalMonths,
    required this.canNavigateNext,
    required this.canNavigatePrevious,
    required this.isFirstMonth,
    required this.isLastMonth,
    this.selectedMonth,
  });

  @override
  String toString() {
    return 'NavigationState(currentIndex: $currentIndex, totalMonths: $totalMonths, '
        'canNavigateNext: $canNavigateNext, canNavigatePrevious: $canNavigatePrevious)';
  }
}
