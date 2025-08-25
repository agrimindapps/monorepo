import 'package:app_petiveti/features/calculators/domain/entities/calorie_input.dart';
import 'package:app_petiveti/features/calculators/presentation/providers/calorie_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalorieProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        // Act
        final state = container.read(calorieProvider);

        // Assert
        expect(state.status, CalorieCalculatorStatus.initial);
        expect(state.input.species, AnimalSpecies.dog);
        expect(state.input.weight, 0);
        expect(state.input.age, 12);
        expect(state.output, isNull);
        expect(state.error, isNull);
        expect(state.validationErrors, isEmpty);
        expect(state.history, isEmpty);
        expect(state.currentStep, 0);
      });

      test('should have correct convenience getters', () {
        // Act
        final state = container.read(calorieProvider);

        // Assert
        expect(state.isLoading, false);
        expect(state.hasResult, false);
        expect(state.hasError, false);
        expect(state.hasValidationErrors, false);
        expect(state.canCalculate, false);
        expect(state.totalSteps, 5);
        expect(state.isLastStep, false);
        expect(state.isFirstStep, true);
      });
    });

    group('Input Updates', () {
      test('should update species correctly', () {
        // Act
        container.read(calorieProvider.notifier).updateSpecies(AnimalSpecies.cat);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.species, AnimalSpecies.cat);
        expect(state.status, CalorieCalculatorStatus.initial);
      });

      test('should update weight correctly', () {
        // Act
        container.read(calorieProvider.notifier).updateWeight(25.0);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.weight, 25.0);
      });

      test('should update age correctly', () {
        // Act
        container.read(calorieProvider.notifier).updateAge(36);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.age, 36);
      });

      test('should update physiological state correctly', () {
        // Act
        container.read(calorieProvider.notifier)
            .updatePhysiologicalState(PhysiologicalState.lactating);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.physiologicalState, PhysiologicalState.lactating);
      });

      test('should update activity level correctly', () {
        // Act
        container.read(calorieProvider.notifier)
            .updateActivityLevel(ActivityLevel.active);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.activityLevel, ActivityLevel.active);
      });

      test('should update body condition score correctly', () {
        // Act
        container.read(calorieProvider.notifier)
            .updateBodyConditionScore(BodyConditionScore.overweight);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.bodyConditionScore, BodyConditionScore.overweight);
      });

      test('should update number of offspring correctly', () {
        // Act
        container.read(calorieProvider.notifier).updateNumberOfOffspring(4);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.numberOfOffspring, 4);
      });

      test('should clear validation errors when input is updated', () {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateWeight(0); // Invalid weight to trigger validation error
        
        // Act
        notifier.updateWeight(25.0); // Valid weight
        final state = container.read(calorieProvider);

        // Assert
        expect(state.validationErrors, isEmpty);
      });
    });

    group('Step Navigation', () {
      test('should navigate to next step correctly', () {
        // Act
        container.read(calorieProvider.notifier).nextStep();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.currentStep, 1);
        expect(state.isFirstStep, false);
      });

      test('should navigate to previous step correctly', () {
        // Arrange
        container.read(calorieProvider.notifier).nextStep();
        
        // Act
        container.read(calorieProvider.notifier).previousStep();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.currentStep, 0);
        expect(state.isFirstStep, true);
      });

      test('should not go beyond last step', () {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        for (int i = 0; i < 10; i++) {
          notifier.nextStep();
        }

        // Act
        final state = container.read(calorieProvider);

        // Assert
        expect(state.currentStep, lessThan(state.totalSteps));
      });

      test('should not go before first step', () {
        // Act
        container.read(calorieProvider.notifier).previousStep();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.currentStep, 0);
      });

      test('should go to specific step correctly', () {
        // Act
        container.read(calorieProvider.notifier).goToStep(3);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.currentStep, 3);
      });

      test('should reset steps correctly', () {
        // Arrange
        container.read(calorieProvider.notifier).goToStep(3);
        
        // Act
        container.read(calorieProvider.notifier).resetSteps();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.currentStep, 0);
      });
    });

    group('Calculation', () {
      test('should perform calculation successfully with valid input', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(25.0);
        notifier.updateAge(36);
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.status, CalorieCalculatorStatus.success);
        expect(state.output, isNotNull);
        expect(state.error, isNull);
        expect(state.hasResult, true);
        expect(state.history, hasLength(1));
      });

      test('should fail calculation with invalid input', () async {
        // Arrange - leaving weight as 0 (invalid)
        final notifier = container.read(calorieProvider.notifier);

        // Act
        await notifier.calculate();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.status, CalorieCalculatorStatus.error);
        expect(state.output, isNull);
        expect(state.error, isNotNull);
        expect(state.hasError, true);
      });

      test('should set loading status during calculation', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(25.0);
        notifier.updateAge(36);
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        final calculationFuture = notifier.calculate();
        
        // Check loading state immediately
        final loadingState = container.read(calorieProvider);
        expect(loadingState.status, CalorieCalculatorStatus.loading);
        expect(loadingState.isLoading, true);

        // Wait for completion
        await calculationFuture;
        final finalState = container.read(calorieProvider);
        expect(finalState.isLoading, false);
      });
    });

    group('History Management', () {
      test('should add calculation to history', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        _setupValidInput(notifier);

        // Act
        await notifier.calculate();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.history, hasLength(1));
        expect(state.history.first, equals(state.output));
      });

      test('should remove item from history correctly', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        _setupValidInput(notifier);
        await notifier.calculate();

        // Act
        notifier.removeFromHistory(0);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.history, isEmpty);
      });

      test('should clear entire history', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        _setupValidInput(notifier);
        await notifier.calculate();

        // Act
        notifier.clearHistory();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.history, isEmpty);
      });

      test('should load from history correctly', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        _setupValidInput(notifier);
        await notifier.calculate();
        final originalOutput = container.read(calorieProvider).output!;
        
        // Change input
        notifier.updateWeight(30.0);

        // Act
        notifier.loadFromHistory(0);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.weight, originalOutput.input.weight);
        expect(state.output, equals(originalOutput));
      });
    });

    group('Presets', () {
      test('should load adult dog preset correctly', () {
        // Act
        container.read(calorieProvider.notifier)
            .loadPreset(CaloriePreset.adultDogNormal);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.species, AnimalSpecies.dog);
        expect(state.input.weight, 25.0);
        expect(state.input.age, 36);
        expect(state.input.physiologicalState, PhysiologicalState.normal);
        expect(state.input.activityLevel, ActivityLevel.moderate);
        expect(state.input.bodyConditionScore, BodyConditionScore.ideal);
      });

      test('should load adult cat preset correctly', () {
        // Act
        container.read(calorieProvider.notifier)
            .loadPreset(CaloriePreset.adultCatNormal);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.species, AnimalSpecies.cat);
        expect(state.input.weight, 4.5);
        expect(state.input.age, 36);
        expect(state.input.physiologicalState, PhysiologicalState.normal);
        expect(state.input.activityLevel, ActivityLevel.light);
        expect(state.input.bodyConditionScore, BodyConditionScore.ideal);
      });

      test('should load lactating queen preset correctly', () {
        // Act
        container.read(calorieProvider.notifier)
            .loadPreset(CaloriePreset.lactatingQueen);
        final state = container.read(calorieProvider);

        // Assert
        expect(state.input.species, AnimalSpecies.cat);
        expect(state.input.physiologicalState, PhysiologicalState.lactating);
        expect(state.input.numberOfOffspring, 4);
      });
    });

    group('State Management', () {
      test('should clear error correctly', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        await notifier.calculate(); // This should fail and set error
        expect(container.read(calorieProvider).hasError, true);

        // Act
        notifier.clearError();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.hasError, false);
        expect(state.error, isNull);
      });

      test('should clear result correctly', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        _setupValidInput(notifier);
        await notifier.calculate();
        expect(container.read(calorieProvider).hasResult, true);

        // Act
        notifier.clearResult();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.hasResult, false);
        expect(state.output, isNull);
      });

      test('should reset completely', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        _setupValidInput(notifier);
        notifier.goToStep(3);
        await notifier.calculate();

        // Act
        notifier.reset();
        final state = container.read(calorieProvider);

        // Assert
        expect(state.status, CalorieCalculatorStatus.initial);
        expect(state.input.weight, 0);
        expect(state.output, isNull);
        expect(state.error, isNull);
        expect(state.currentStep, 0);
      });
    });

    group('Validation', () {
      test('should validate input when can proceed to next step', () {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        
        // Test step 0 validation
        expect(notifier.canProceedToNextStep(), false);
        
        // Add required fields for step 0
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(25.0);
        notifier.updateAge(36);
        
        // Act & Assert
        expect(notifier.canProceedToNextStep(), true);
      });

      test('should validate lactation with offspring requirement', () {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.cat);
        notifier.updateWeight(4.0);
        notifier.updateAge(24);
        notifier.goToStep(1);
        
        // Act - set lactating without offspring
        notifier.updatePhysiologicalState(PhysiologicalState.lactating);
        
        // Assert
        expect(notifier.canProceedToNextStep(), false);
        
        // Act - add offspring
        notifier.updateNumberOfOffspring(4);
        
        // Assert
        expect(notifier.canProceedToNextStep(), true);
      });
    });
  });

  group('Provider Dependencies', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should provide input correctly', () {
      // Act
      final input = container.read(calorieInputProvider);

      // Assert
      expect(input.species, AnimalSpecies.dog);
      expect(input.weight, 0);
    });

    test('should provide loading state correctly', () {
      // Act
      final isLoading = container.read(calorieLoadingProvider);

      // Assert
      expect(isLoading, false);
    });

    test('should provide can calculate state correctly', () {
      // Act
      final canCalculate = container.read(calorieCanCalculateProvider);

      // Assert
      expect(canCalculate, false);
    });

    test('should provide current step correctly', () {
      // Act
      final currentStep = container.read(calorieCurrentStepProvider);

      // Assert
      expect(currentStep, 0);
    });

    test('should provide suggestions correctly', () {
      // Arrange
      container.read(calorieProvider.notifier).updateSpecies(AnimalSpecies.cat);
      container.read(calorieProvider.notifier).updateWeight(7.0); // Heavy cat

      // Act
      final suggestions = container.read(calorieSuggestionsProvider);

      // Assert
      expect(suggestions, isNotEmpty);
      expect(suggestions.any((s) => s.contains('Peso elevado para gatos')), true);
    });
  });
}

void _setupValidInput(CalorieNotifier notifier) {
  notifier.updateSpecies(AnimalSpecies.dog);
  notifier.updateWeight(25.0);
  notifier.updateAge(36);
  notifier.updatePhysiologicalState(PhysiologicalState.normal);
  notifier.updateActivityLevel(ActivityLevel.moderate);
  notifier.updateBodyConditionScore(BodyConditionScore.ideal);
}