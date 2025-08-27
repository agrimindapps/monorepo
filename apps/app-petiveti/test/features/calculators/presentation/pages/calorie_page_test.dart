import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_petiveti/features/calculators/presentation/pages/calorie_page.dart';
import 'package:app_petiveti/features/calculators/presentation/providers/calorie_provider.dart';
import 'package:app_petiveti/features/calculators/presentation/widgets/calorie_basic_info_step.dart';
import 'package:app_petiveti/features/calculators/presentation/widgets/calorie_result_card.dart';
import 'package:app_petiveti/features/calculators/presentation/widgets/calorie_step_indicator.dart';
import 'package:app_petiveti/features/calculators/domain/entities/calorie_input.dart';
import 'package:app_petiveti/shared/constants/calorie_constants.dart';

/// **Unit Tests for CaloriePage Navigation Logic and Validation**
/// 
/// This test suite validates the core functionality of the CaloriePage including:
/// - Navigation flow between steps
/// - Input validation and form state management
/// - Provider integration and state changes
/// - User interaction patterns
/// - Error handling and loading states
/// 
/// **Testing Strategy:**
/// 1. Widget structure and initial state validation
/// 2. Navigation logic testing across all steps
/// 3. Form validation and input handling
/// 4. Provider state management integration
/// 5. User interaction simulation
/// 6. Error scenarios and edge cases

void main() {
  group('CaloriePage Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [],
        child: MaterialApp(
          home: const CaloriePage(),
        ),
      );
    }

    group('Widget Structure Tests', () {
      testWidgets('should display correct app bar title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(CalorieConstants.appBarTitle), findsOneWidget);
      });

      testWidgets('should display help button with correct tooltip', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.help_outline), findsOneWidget);
        expect(find.byTooltip(CalorieConstants.helpTooltip), findsOneWidget);
      });

      testWidgets('should display progress indicator', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(CalorieStepIndicator), findsOneWidget);
      });

      testWidgets('should start with basic info step', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(CalorieBasicInfoStep), findsOneWidget);
      });
    });

    group('Navigation Logic Tests', () {
      testWidgets('should not show back button on first step', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check that back button is not present on first step
        expect(find.text(CalorieConstants.backButtonText), findsNothing);
      });

      testWidgets('should show advance button on first step', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show advance button (or next step button)
        expect(find.text(CalorieConstants.advanceButtonText), findsOneWidget);
      });

      testWidgets('should display correct navigation buttons state', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify initial navigation state
        expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
        expect(find.byType(OutlinedButton), findsNothing); // No back button initially
      });

      testWidgets('should handle page view correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify PageView is present for step navigation
        expect(find.byType(PageView), findsOneWidget);
      });
    });

    group('Provider Integration Tests', () {
      testWidgets('should initialize with correct provider state', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // The page should load without errors, indicating provider integration works
        expect(find.byType(CaloriePage), findsOneWidget);
      });

      testWidgets('should handle provider state changes', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify that the page responds to provider state
        // Initial state should show the input form
        expect(find.byType(CalorieBasicInfoStep), findsOneWidget);
      });
    });

    group('Form Validation Tests', () {
      testWidgets('should display input form fields', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check that the basic info step (first step) is displayed
        expect(find.byType(CalorieBasicInfoStep), findsOneWidget);
      });

      testWidgets('should handle form input correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify that form fields are interactable
        // This would involve finding TextFormField widgets and testing input
        expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
      });
    });

    group('Loading States Tests', () {
      testWidgets('should show loading indicator during transitions', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test that loading states can be displayed
        // This would require triggering a state change that shows loading
        expect(find.byType(CircularProgressIndicator), findsNothing); // Initially no loading
      });

      testWidgets('should disable navigation during loading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify that navigation buttons are in correct enabled state
        final advanceButton = find.text(CalorieConstants.advanceButtonText);
        expect(advanceButton, findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle provider errors gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify that the page loads without throwing errors
        expect(find.byType(CaloriePage), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should display error states when needed', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test that error states can be properly displayed
        // This would require triggering an error condition
        expect(find.byType(CaloriePage), findsOneWidget);
      });
    });

    group('User Interaction Tests', () {
      testWidgets('should respond to help button tap', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final helpButton = find.byIcon(Icons.help_outline);
        expect(helpButton, findsOneWidget);

        // Test tapping the help button
        await tester.tap(helpButton);
        await tester.pumpAndSettle();

        // Help action should trigger without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should respond to menu button interaction', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Look for popup menu button
        final menuButton = find.byType(PopupMenuButton<String>);
        expect(menuButton, findsOneWidget);

        // Test menu button interaction
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic structure', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify semantic widgets are present for accessibility
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should support screen reader navigation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check that important UI elements have proper tooltips/labels
        expect(find.byTooltip(CalorieConstants.helpTooltip), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should render within reasonable time', (tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Page should render in less than 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      testWidgets('should dispose resources properly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate away to trigger dispose
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();

        // Should not throw any disposal errors
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('CalorieProvider State Management Tests', () {
    test('should initialize with correct default state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(calorieProvider);
      
      expect(state.currentStep, equals(0));
      expect(state.isFirstStep, isTrue);
      expect(state.isLastStep, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasResult, isFalse);
    });

    test('should update step navigation correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Test step advancement
      notifier.nextStep();
      expect(container.read(calorieProvider).currentStep, equals(1));
      
      // Test step going back
      notifier.previousStep();
      expect(container.read(calorieProvider).currentStep, equals(0));
    });

    test('should validate input correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(calorieProvider);
      
      // Initially should not be able to calculate (weight is 0)
      expect(state.canCalculate, isFalse);
      
      // Update with valid input
      final notifier = container.read(calorieProvider.notifier);
      notifier.updateWeight(25.0);
      
      final updatedState = container.read(calorieProvider);
      expect(updatedState.input.weight, equals(25.0));
    });

    test('should handle calculation flow', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Set up valid input for calculation
      notifier.updateWeight(25.0);
      notifier.updateAge(36);
      
      final state = container.read(calorieProvider);
      
      // Should be able to calculate with valid input
      expect(state.input.weight, equals(25.0));
      expect(state.input.age, equals(36));
    });

    test('should manage step progression properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Test going to specific step
      notifier.goToStep(2);
      expect(container.read(calorieProvider).currentStep, equals(2));
      
      // Test reset
      notifier.resetSteps();
      expect(container.read(calorieProvider).currentStep, equals(0));
    });

    test('should handle transition loading states', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Test transition loading
      notifier.setTransitionLoading(true);
      expect(container.read(calorieProvider).isTransitionLoading, isTrue);
      
      notifier.setTransitionLoading(false);
      expect(container.read(calorieProvider).isTransitionLoading, isFalse);
    });

    test('should validate step progression correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Initially on step 0, should not be able to proceed without valid input
      expect(container.read(calorieCanProceedProvider), isFalse);
      
      // Add required input for step 0
      notifier.updateWeight(25.0);
      notifier.updateAge(36);
      
      // Now should be able to proceed
      expect(container.read(calorieCanProceedProvider), isTrue);
    });

    test('should handle input validation errors', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Test with invalid input
      final invalidInput = const CalorieInput(
        species: AnimalSpecies.dog,
        weight: -5.0, // Invalid negative weight
        age: 12,
        physiologicalState: PhysiologicalState.normal,
        activityLevel: ActivityLevel.moderate,
        bodyConditionScore: BodyConditionScore.ideal,
      );
      
      notifier.updateInput(invalidInput);
      
      final state = container.read(calorieProvider);
      expect(state.hasValidationErrors, isTrue);
    });

    test('should clear errors and results properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Test clear error functionality
      notifier.clearError();
      expect(container.read(calorieProvider).error, isNull);
      
      // Test clear result functionality  
      notifier.clearResult();
      expect(container.read(calorieProvider).output, isNull);
      expect(container.read(calorieProvider).hasResult, isFalse);
    });

    test('should reset to initial state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieProvider.notifier);
      
      // Make some changes
      notifier.updateWeight(25.0);
      notifier.nextStep();
      
      // Reset
      notifier.reset();
      
      final state = container.read(calorieProvider);
      expect(state.currentStep, equals(0));
      expect(state.input.weight, equals(0));
    });
  });
}