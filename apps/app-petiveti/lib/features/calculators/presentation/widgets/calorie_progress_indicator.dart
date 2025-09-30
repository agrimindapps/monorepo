import 'package:flutter/material.dart';

import '../../../../shared/constants/calorie_constants.dart';
import '../providers/calorie_provider.dart';
import 'calorie_step_indicator.dart';

/// **Calorie Progress Indicator Widget**
/// 
/// A specialized progress indicator for the calorie calculation flow
/// that provides visual feedback about the current step and loading states.
/// 
/// ## Key Features:
/// - **Animated Container**: Smooth transitions between normal and loading states
/// - **Loading Overlay**: Visual overlay during step transitions
/// - **Progress Visualization**: Clear step progression indicator
/// - **Responsive Design**: Adapts to different screen sizes
/// 
/// ## Visual States:
/// - **Normal State**: Standard progress indicator with step navigation
/// - **Loading State**: Animated overlay with loading spinner and message
/// - **Complete State**: Final state when calculation is finished
/// 
/// ## Accessibility:
/// - Semantic labels for screen readers
/// - High contrast support
/// - Focus management during loading states
/// 
/// @author PetiVeti Development Team
/// @since 1.1.0
class CalorieProgressIndicator extends StatelessWidget {
  /// Creates a calorie progress indicator widget.
  /// 
  /// **Parameters:**
  /// - [state]: Current calorie calculation state
  const CalorieProgressIndicator({
    super.key,
    required this.state,
  });

  /// Current state of the calorie calculation process
  final CalorieState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: CalorieConstants.progressContainerAnimationDuration,
      padding: CalorieConstants.progressIndicatorPadding,
      decoration: _buildContainerDecoration(context),
      child: Stack(
        children: [
          _buildStepIndicator(),
          if (state.isTransitionLoading) _buildLoadingOverlay(context),
        ],
      ),
    );
  }

  /// **Container Decoration Builder**
  /// 
  /// Creates the animated decoration for the progress indicator container
  /// with appropriate colors and shadows based on loading state.
  BoxDecoration _buildContainerDecoration(BuildContext context) {
    return BoxDecoration(
      color: state.isTransitionLoading 
          ? Theme.of(context).colorScheme.primaryContainer.withValues(
              alpha: CalorieColors.primaryContainerOpacity)
          : Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: state.isTransitionLoading 
                ? CalorieColors.shadowOpacityLoading 
                : CalorieColors.shadowOpacity),
          blurRadius: state.isTransitionLoading 
              ? CalorieConstants.progressShadowBlurRadiusLoading 
              : CalorieConstants.progressShadowBlurRadius,
          offset: CalorieConstants.progressShadowOffset,
        ),
      ],
    );
  }

  /// **Step Indicator Builder**
  /// 
  /// Creates the main step indicator showing current progress
  /// through the calorie calculation flow.
  Widget _buildStepIndicator() {
    return CalorieStepIndicator(
      currentStep: state.currentStep,
      totalSteps: state.totalSteps,
      isComplete: state.hasResult,
    );
  }

  /// **Loading Overlay Builder**
  /// 
  /// Creates the loading overlay displayed during step transitions
  /// with spinner and informative loading message.
  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(
              alpha: CalorieColors.surfaceOverlayOpacity),
          borderRadius: BorderRadius.circular(
              CalorieConstants.progressBorderRadius),
        ),
        child: Center(
          child: Semantics(
            label: 'Processando informações do cálculo calórico',
            hint: 'Por favor aguarde enquanto as informações são processadas',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoadingSpinner(context),
                const SizedBox(width: CalorieConstants.loadingSpacing),
                _buildLoadingText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Loading Spinner Builder**
  /// 
  /// Creates the circular progress indicator for loading state.
  Widget _buildLoadingSpinner(BuildContext context) {
    return SizedBox(
      width: CalorieConstants.loadingIndicatorSize,
      height: CalorieConstants.loadingIndicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: CalorieConstants.loadingIndicatorStrokeWidth,
        color: Theme.of(context).colorScheme.primary,
        semanticsLabel: 'Indicador de progresso do carregamento',
      ),
    );
  }

  /// **Loading Text Builder**
  /// 
  /// Creates the loading message text with appropriate styling.
  Widget _buildLoadingText(BuildContext context) {
    return Text(
      CalorieConstants.processingText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: CalorieConstants.processingTextWeight,
        fontSize: CalorieConstants.processingTextSize,
      ),
    );
  }
}