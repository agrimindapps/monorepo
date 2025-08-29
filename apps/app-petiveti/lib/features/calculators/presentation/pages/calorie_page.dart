import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/calorie_provider.dart';
import '../widgets/calorie_activity_condition_step.dart';
import '../widgets/calorie_animation_manager.dart';
import '../widgets/calorie_basic_info_step.dart';
import '../widgets/calorie_dialog_manager.dart';
import '../widgets/calorie_menu_handler.dart';
import '../widgets/calorie_navigation_handler.dart';
import '../widgets/calorie_physiological_step.dart';
import '../widgets/calorie_result_card.dart';
import '../widgets/calorie_review_step.dart';
import '../widgets/calorie_special_conditions_step.dart';
import '../widgets/calorie_step_indicator.dart';
import '../widgets/calorie_progress_indicator.dart';
import '../widgets/calorie_navigation_bar.dart';
import '../../../../shared/constants/calorie_constants.dart';

/// **Refactored Calorie Calculator Page - Clean Architecture Implementation**
/// 
/// A comprehensive calorie calculation interface built with Clean Architecture
/// principles and optimized for performance and maintainability.
/// 
/// ## Responsibilities:
/// - **Page Layout**: Main structure and responsive design coordination
/// - **Handler Coordination**: Manages specialized handlers for different concerns
/// - **Widget Lifecycle**: Proper initialization and disposal of resources
/// - **Separation of Concerns**: Each handler manages a specific aspect
/// 
/// ## Architecture Components:
/// - **CalorieAnimationManager**: Handles all animation logic and transitions
/// - **CalorieNavigationHandler**: Manages step navigation and validation
/// - **CalorieDialogManager**: Handles all dialog interactions and sharing
/// - **CalorieMenuHandler**: Manages menu actions and presets
/// - **PageController**: Controls the multi-step form navigation
/// 
/// ## Unit Testing Strategy & Documentation:
/// 
/// ### **1. Widget Testing Approach:**
/// ```dart
/// testWidgets('CaloriePage navigation flow', (tester) async {
///   await tester.pumpWidget(createTestWidget(CaloriePage()));
///   
///   // Test initial state
///   expect(find.byType(CalorieBasicInfoStep), findsOneWidget);
///   
///   // Test navigation to next step
///   await tester.tap(find.text('Avançar'));
///   await tester.pumpAndSettle();
///   expect(find.byType(CaloriePhysiologicalStep), findsOneWidget);
/// });
/// ```
/// 
/// ### **2. Provider/State Testing:**
/// ```dart
/// test('calorie calculation provider state management', () {
///   final container = ProviderContainer();
///   addTearDown(container.dispose);
///   
///   // Test initial state
///   expect(container.read(calorieProvider).currentStep, equals(0));
///   
///   // Test input validation
///   container.read(calorieProvider.notifier).updateInput(testInput);
///   expect(container.read(calorieCanProceedProvider), isTrue);
/// });
/// ```
/// 
/// ### **3. Handler Integration Testing:**
/// ```dart
/// group('CalorieNavigationHandler tests', () {
///   late CalorieNavigationHandler handler;
///   late PageController pageController;
///   late ProviderContainer container;
///   
///   setUp(() {
///     pageController = PageController();
///     container = ProviderContainer();
///     handler = CalorieNavigationHandler(
///       pageController: pageController,
///       ref: container,
///       onTransition: (_) {},
///     );
///   });
///   
///   test('should advance to next step when valid', () async {
///     // Setup valid input state
///     await handler.goToNextStep(false);
///     expect(pageController.page, equals(1.0));
///   });
/// });
/// ```
/// 
/// ### **4. Animation Testing:**
/// ```dart
/// testWidgets('animation manager lifecycle', (tester) async {
///   final animationManager = CalorieAnimationManager();
///   animationManager.initialize(tester);
///   
///   // Test animation initialization
///   expect(animationManager.fadeAnimation, isNotNull);
///   
///   // Test transition animations
///   animationManager.animateTransition(() {});
///   await tester.pump();
///   
///   // Test cleanup
///   animationManager.dispose();
/// });
/// ```
/// 
/// ### **5. Dialog Testing:**
/// ```dart
/// testWidgets('dialog manager interactions', (tester) async {
///   final dialogManager = CalorieDialogManager(
///     context: tester.element(find.byType(MaterialApp)),
///     ref: container,
///   );
///   
///   // Test preset loading dialog
///   dialogManager.loadPresetsDialog();
///   await tester.pumpAndSettle();
///   expect(find.byType(Dialog), findsOneWidget);
/// });
/// ```
/// 
/// ### **6. Integration Testing Checklist:**
/// - [ ] **Complete User Flow**: From basic info to final calculation
/// - [ ] **Error State Handling**: Network failures, validation errors
/// - [ ] **Loading States**: All transition loading indicators
/// - [ ] **Accessibility**: Semantic labels and screen reader support
/// - [ ] **Responsive Design**: Different screen sizes and orientations
/// - [ ] **Performance**: Animation smoothness, memory usage
/// - [ ] **Data Persistence**: History saving and favorite management
/// 
/// ### **7. Mock Strategies:**
/// ```dart
/// class MockCalorieProvider extends StateNotifier<CalorieState> 
///     implements CalorieNotifier {
///   MockCalorieProvider() : super(const CalorieState.initial());
///   
///   @override
///   Future<void> calculate() async {
///     state = state.copyWith(isLoading: true);
///     // Mock calculation delay
///     await Future.delayed(Duration(milliseconds: 100));
///     state = state.copyWith(
///       isLoading: false,
///       output: MockCalorieOutput(),
///     );
///   }
/// }
/// ```
/// 
/// ### **8. Performance Testing:**
/// - **Navigation Performance**: Measure step transition times
/// - **Memory Management**: Monitor for handler disposal leaks
/// - **Animation Performance**: Frame rate during transitions
/// - **Provider Efficiency**: State update frequency and optimization
/// 
/// ### **9. Edge Case Testing:**
/// - **Rapid Navigation**: Fast tapping between steps
/// - **Form Validation**: Invalid input combinations
/// - **Network Conditions**: Offline/online state changes
/// - **Lifecycle Events**: App backgrounding during calculations
/// 
/// This comprehensive testing approach ensures reliability, performance,
/// and maintainability of the calorie calculation feature.
class CaloriePage extends ConsumerStatefulWidget {
  const CaloriePage({super.key});

  @override
  ConsumerState<CaloriePage> createState() => _CaloriePageState();
}

class _CaloriePageState extends ConsumerState<CaloriePage> 
    with TickerProviderStateMixin {
  
  // Specialized handlers for different concerns
  late PageController _pageController;
  late CalorieAnimationManager _animationManager;
  late CalorieNavigationHandler _navigationHandler;
  late CalorieDialogManager _dialogManager;
  late CalorieMenuHandler _menuHandler;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    // Initialize page controller
    _pageController = PageController();
    
    // Initialize animation manager
    _animationManager = CalorieAnimationManager();
    _animationManager.initialize(this);
    
    // Initialize navigation handler
    _navigationHandler = CalorieNavigationHandler(
      pageController: _pageController,
      ref: ref,
      onTransition: _animationManager.animateTransition,
    );
    
    // Initialize dialog manager
    _dialogManager = CalorieDialogManager(
      context: context,
      ref: ref,
    );
    
    // Initialize menu handler
    _menuHandler = CalorieMenuHandler(
      dialogManager: _dialogManager,
      ref: ref,
      onPresetLoaded: () => _navigationHandler.goToPage(CalorieConstants.reviewStepIndex),
      onReset: () => _navigationHandler.resetToFirstStep(),
      onHistoryItemSelected: () {
        // Navigate to results or review step after loading history
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationManager.dispose();
    _navigationHandler.dispose();
    _menuHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calorieProvider);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          CalorieProgressIndicator(state: state),
          _buildMainContent(state),
          CalorieNavigationBar(
            state: state,
            navigationHandler: _navigationHandler,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(CalorieConstants.appBarTitle),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _menuHandler.handleMenuAction('help'),
          tooltip: CalorieConstants.helpTooltip,
        ),
        PopupMenuButton<String>(
          onSelected: _menuHandler.handleMenuAction,
          itemBuilder: (context) => _menuHandler.getMenuItems(),
        ),
      ],
    );
  }


  Widget _buildMainContent(CalorieState state) {
    return Expanded(
      child: FadeTransition(
        opacity: _animationManager.fadeAnimation ?? 
          const AlwaysStoppedAnimation(CalorieConstants.defaultOpacityValue),
        child: state.hasResult 
            ? _buildResultView(state)
            : _buildStepperView(state),
      ),
    );
  }

  Widget _buildStepperView(CalorieState state) {
    return PageView(
      controller: _pageController,
      onPageChanged: _navigationHandler.onPageChanged,
      children: [
        CalorieBasicInfoStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        CaloriePhysiologicalStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        CalorieActivityConditionStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        CalorieSpecialConditionsStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        CalorieReviewStep(
          input: state.input,
          isLoading: state.isLoading,
          error: state.error,
          onCalculate: () => ref.read(calorieProvider.notifier).calculate(),
        ),
      ],
    );
  }

  Widget _buildResultView(CalorieState state) {
    return SingleChildScrollView(
      padding: CalorieConstants.mainContentPadding,
      child: Column(
        children: [
          CalorieResultCard(
            output: state.output!,
            onSaveAsFavorite: () => ref.read(calorieProvider.notifier).saveAsFavorite(),
            onRecalculate: () {
              ref.read(calorieProvider.notifier).clearResult();
              _navigationHandler.resetToFirstStep();
            },
          ),
          const SizedBox(height: CalorieConstants.actionButtonsSpacing),
          _buildActionButtons(state),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CalorieState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _dialogManager.shareResult(state.output!),
            icon: const Icon(Icons.share),
            label: const Text(CalorieConstants.shareButtonText),
          ),
        ),
        const SizedBox(width: CalorieConstants.actionButtonsSpacing),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(calorieProvider.notifier).clearResult();
              _navigationHandler.resetToFirstStep();
            },
            icon: const Icon(Icons.calculate),
            label: const Text(CalorieConstants.newCalculationButtonText),
          ),
        ),
      ],
    );
  }

}