import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calorie_provider.dart';
import 'calorie_navigation_handler.dart';
import '../../../../shared/constants/calorie_constants.dart';

/// **Calorie Navigation Bar Widget**
/// 
/// A specialized navigation bar for the calorie calculation flow that provides
/// step navigation controls with proper validation and loading states.
/// 
/// ## Key Features:
/// - **Contextual Navigation**: Shows appropriate buttons based on current step
/// - **Validation Integration**: Prevents navigation without valid input
/// - **Loading States**: Visual feedback during transitions
/// - **Accessibility**: Full semantic support and keyboard navigation
/// 
/// ## Navigation Logic:
/// - **Back Button**: Available on all steps except first
/// - **Next/Calculate Button**: Available when step validation passes
/// - **Loading States**: Disables buttons during transitions
/// - **Button Animation**: Smooth transitions between states
/// 
/// ## Accessibility Features:
/// - Semantic labels for all navigation controls
/// - Loading state announcements
/// - Keyboard navigation support
/// - High contrast mode compatibility
/// 
/// @author PetiVeti Development Team
/// @since 1.1.0
class CalorieNavigationBar extends ConsumerWidget {
  /// Creates a calorie navigation bar widget.
  /// 
  /// **Parameters:**
  /// - [state]: Current calorie calculation state
  /// - [navigationHandler]: Handler for navigation actions
  const CalorieNavigationBar({
    super.key,
    required this.state,
    required this.navigationHandler,
  });

  /// Current state of the calorie calculation process
  final CalorieState state;
  
  /// Handler for navigation actions and transitions
  final CalorieNavigationHandler navigationHandler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Don't show navigation bar when results are displayed
    if (state.hasResult) return const SizedBox.shrink();
    
    return Container(
      padding: CalorieConstants.navigationBarPadding,
      decoration: _buildBarDecoration(context),
      child: Semantics(
        label: 'Barra de navegação do cálculo calórico',
        hint: 'Use os botões para navegar entre as etapas do cálculo',
        child: Row(
          children: [
            if (!state.isFirstStep) ...[
              _buildBackButton(context),
              const SizedBox(width: CalorieConstants.navigationButtonSpacing),
            ],
            const Spacer(),
            _buildNextButton(context, ref),
          ],
        ),
      ),
    );
  }

  /// **Navigation Bar Decoration**
  /// 
  /// Creates the visual styling for the navigation bar container.
  BoxDecoration _buildBarDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      border: Border(
        top: BorderSide(
          color: Colors.grey.withValues(
              alpha: CalorieConstants.navigationBorderOpacity),
        ),
      ),
    );
  }

  /// **Back Button Builder**
  /// 
  /// Creates the back navigation button with loading state handling.
  Widget _buildBackButton(BuildContext context) {
    return Semantics(
      label: 'Voltar para a etapa anterior',
      hint: 'Retorna para a etapa anterior do cálculo',
      button: true,
      child: OutlinedButton.icon(
        onPressed: state.isTransitionLoading 
            ? null 
            : navigationHandler.goToPreviousStep,
        icon: state.isTransitionLoading 
            ? _buildButtonLoadingIndicator()
            : const Icon(Icons.arrow_back),
        label: const Text(CalorieConstants.backButtonText),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// **Next/Calculate Button Builder**
  /// 
  /// Creates the primary action button (Next or Calculate) with
  /// validation state and loading animations.
  Widget _buildNextButton(BuildContext context, WidgetRef ref) {
    final canProceed = ref.watch(calorieCanProceedProvider);
    final isLastStep = state.isLastStep;
    final isTransitionLoading = state.isTransitionLoading;
    
    return Semantics(
      label: isLastStep 
          ? 'Executar cálculo calórico'
          : 'Avançar para próxima etapa',
      hint: isLastStep 
          ? 'Inicia o cálculo com as informações fornecidas'
          : 'Prossegue para a próxima etapa do formulário',
      button: true,
      child: AnimatedContainer(
        duration: CalorieConstants.navigationButtonAnimationDuration,
        child: ElevatedButton.icon(
          onPressed: (canProceed && !isTransitionLoading) 
              ? () => navigationHandler.goToNextStep(isLastStep)
              : null,
          icon: _buildNextButtonIcon(isLastStep, isTransitionLoading),
          label: _buildNextButtonLabel(isLastStep, isTransitionLoading),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// **Next Button Icon Builder**
  /// 
  /// Creates the appropriate icon for the next button based on state.
  Widget _buildNextButtonIcon(bool isLastStep, bool isTransitionLoading) {
    if (isTransitionLoading) {
      return SizedBox(
        width: CalorieConstants.loadingIndicatorSize,
        height: CalorieConstants.loadingIndicatorSize,
        child: const CircularProgressIndicator(
          strokeWidth: CalorieConstants.loadingIndicatorStrokeWidth,
          color: Colors.white,
        ),
      );
    }
    
    return Icon(isLastStep ? Icons.calculate : Icons.arrow_forward);
  }

  /// **Next Button Label Builder**
  /// 
  /// Creates the appropriate label text for the next button with animations.
  Widget _buildNextButtonLabel(bool isLastStep, bool isTransitionLoading) {
    return AnimatedSwitcher(
      duration: CalorieConstants.animatedSwitcherDuration,
      child: Text(
        _getButtonLabelText(isLastStep, isTransitionLoading),
        key: ValueKey(_getButtonLabelKey(isTransitionLoading)),
      ),
    );
  }

  /// **Button Loading Indicator**
  /// 
  /// Creates a small loading indicator for buttons.
  Widget _buildButtonLoadingIndicator() {
    return const SizedBox(
      width: CalorieConstants.loadingIndicatorSize,
      height: CalorieConstants.loadingIndicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: CalorieConstants.loadingIndicatorStrokeWidth,
      ),
    );
  }

  /// **Get Button Label Text**
  /// 
  /// Determines the appropriate text for the button based on state.
  String _getButtonLabelText(bool isLastStep, bool isTransitionLoading) {
    if (isTransitionLoading) {
      return isLastStep 
          ? CalorieConstants.calculatingText 
          : CalorieConstants.loadingText;
    }
    
    return isLastStep 
        ? CalorieConstants.calculateButtonText 
        : CalorieConstants.advanceButtonText;
  }

  /// **Get Button Label Key**
  /// 
  /// Provides the animation key for the button label.
  String _getButtonLabelKey(bool isTransitionLoading) {
    return isTransitionLoading 
        ? CalorieConstants.loadingAnimationKey 
        : CalorieConstants.normalAnimationKey;
  }
}