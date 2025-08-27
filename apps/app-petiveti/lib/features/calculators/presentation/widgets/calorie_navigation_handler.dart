import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calorie_provider.dart';

/// Navigation handler for Calorie Calculator
/// 
/// Responsibilities:
/// - Handle step navigation logic
/// - Manage page controller transitions  
/// - Coordinate with provider state changes
/// - Enhanced loading states during transitions
class CalorieNavigationHandler {
  final PageController pageController;
  final WidgetRef ref;
  final VoidCallback? onTransition;
  bool _isTransitioning = false;

  CalorieNavigationHandler({
    required this.pageController,
    required this.ref,
    this.onTransition,
  });

  /// Navigate to the next step or calculate if last step
  Future<void> goToNextStep(bool isLastStep) async {
    if (_isTransitioning) return;
    
    try {
      _isTransitioning = true;
      
      if (isLastStep) {
        // Show loading state for calculation
        ref.read(calorieProvider.notifier).setTransitionLoading(true);
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Execute calculation
        ref.read(calorieProvider.notifier).calculate();
      } else {
        // Show loading state for step transition
        ref.read(calorieProvider.notifier).setTransitionLoading(true);
        
        // Move to next step
        ref.read(calorieProvider.notifier).nextStep();
        final currentStep = ref.read(calorieProvider).currentStep;
        
        // Animate to next page with loading feedback
        await _animateToPageWithLoading(currentStep);
      }
    } finally {
      _isTransitioning = false;
      ref.read(calorieProvider.notifier).setTransitionLoading(false);
    }
  }

  /// Navigate to the previous step
  Future<void> goToPreviousStep() async {
    if (_isTransitioning) return;
    
    try {
      _isTransitioning = true;
      
      // Show loading state for step transition
      ref.read(calorieProvider.notifier).setTransitionLoading(true);
      
      ref.read(calorieProvider.notifier).previousStep();
      final currentStep = ref.read(calorieProvider).currentStep;
      
      await _animateToPageWithLoading(currentStep);
    } finally {
      _isTransitioning = false;
      ref.read(calorieProvider.notifier).setTransitionLoading(false);
    }
  }

  /// Navigate directly to a specific page
  void goToPage(int page) {
    _animateToPage(page);
  }

  /// Reset navigation to first step
  void resetToFirstStep() {
    ref.read(calorieProvider.notifier).resetSteps();
    _animateToPage(0);
  }

  /// Handle page change from PageView
  void onPageChanged(int index) {
    ref.read(calorieProvider.notifier).goToStep(index);
    onTransition?.call();
  }

  /// Private method to handle page animation
  void _animateToPage(int page) {
    if (!pageController.hasClients) return;
    
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    onTransition?.call();
  }

  /// Enhanced page animation with loading feedback
  Future<void> _animateToPageWithLoading(int page) async {
    if (!pageController.hasClients) return;
    
    // Add a small delay to show loading state
    await Future<void>.delayed(const Duration(milliseconds: 150));
    
    await pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
    
    onTransition?.call();
    
    // Brief pause after transition for visual feedback
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Getter for transition state
  bool get isTransitioning => _isTransitioning;

  /// Check if can navigate to specific step
  bool canNavigateToStep(int step) {
    // Add validation logic here if needed
    return step >= 0 && step < 5; // 5 steps total
  }

  /// Dispose of resources
  void dispose() {
    // Navigation handler doesn't need disposal,
    // but can be extended if needed
  }
}