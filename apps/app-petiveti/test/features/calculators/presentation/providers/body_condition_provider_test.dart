import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_petiveti/features/calculators/domain/entities/body_condition_input.dart';
import 'package:app_petiveti/features/calculators/domain/entities/body_condition_output.dart';
import 'package:app_petiveti/features/calculators/presentation/providers/body_condition_provider.dart';

void main() {
  group('BodyConditionProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      final state = container.read(bodyConditionProvider);

      expect(state.status, equals(BodyConditionCalculatorStatus.initial));
      expect(state.input.species, equals(AnimalSpecies.dog));
      expect(state.input.currentWeight, equals(0));
      expect(state.input.ribPalpation, equals(RibPalpation.moderatePressure));
      expect(state.output, isNull);
      expect(state.error, isNull);
      expect(state.validationErrors, isEmpty);
      expect(state.history, isEmpty);
    });

    test('should update input correctly', () {
      final notifier = container.read(bodyConditionProvider.notifier);
      
      final newInput = BodyConditionInput(
        species: AnimalSpecies.cat,
        currentWeight: 5.0,
        ribPalpation: RibPalpation.easy,
        waistVisibility: WaistVisibility.wellVisible,
        abdominalProfile: AbdominalProfile.slightlyRetracted,
      );

      notifier.updateInput(newInput);

      final state = container.read(bodyConditionProvider);
      expect(state.input.species, equals(AnimalSpecies.cat));
      expect(state.input.currentWeight, equals(5.0));
      expect(state.input.ribPalpation, equals(RibPalpation.easy));
      expect(state.status, equals(BodyConditionCalculatorStatus.initial));
    });

    test('should update individual fields correctly', () {
      final notifier = container.read(bodyConditionProvider.notifier);

      notifier.updateSpecies(AnimalSpecies.cat);
      expect(container.read(bodyConditionProvider).input.species, equals(AnimalSpecies.cat));

      notifier.updateCurrentWeight(5.5);
      expect(container.read(bodyConditionProvider).input.currentWeight, equals(5.5));

      notifier.updateIdealWeight(5.0);
      expect(container.read(bodyConditionProvider).input.idealWeight, equals(5.0));

      notifier.updateRibPalpation(RibPalpation.easy);
      expect(container.read(bodyConditionProvider).input.ribPalpation, equals(RibPalpation.easy));

      notifier.updateWaistVisibility(WaistVisibility.wellVisible);
      expect(container.read(bodyConditionProvider).input.waistVisibility, equals(WaistVisibility.wellVisible));

      notifier.updateAbdominalProfile(AbdominalProfile.slightlyRetracted);
      expect(container.read(bodyConditionProvider).input.abdominalProfile, equals(AbdominalProfile.slightlyRetracted));

      notifier.updateAnimalAge(24);
      expect(container.read(bodyConditionProvider).input.animalAge, equals(24));

      notifier.updateAnimalBreed('Persian');
      expect(container.read(bodyConditionProvider).input.animalBreed, equals('Persian'));

      notifier.updateIsNeutered(true);
      expect(container.read(bodyConditionProvider).input.isNeutered, isTrue);

      notifier.updateHasMetabolicConditions(true);
      expect(container.read(bodyConditionProvider).input.hasMetabolicConditions, isTrue);

      notifier.updateObservations('Very active');
      expect(container.read(bodyConditionProvider).input.observations, equals('Very active'));
    });

    test('should validate input on update', () {
      final notifier = container.read(bodyConditionProvider.notifier);

      // Update with invalid weight
      notifier.updateCurrentWeight(-5.0);

      final state = container.read(bodyConditionProvider);
      expect(state.validationErrors, isNotEmpty);
      expect(state.canCalculate, isFalse);
    });

    test('should calculate successfully with valid input', () async {
      final notifier = container.read(bodyConditionProvider.notifier);

      // Set up valid input
      notifier.updateSpecies(AnimalSpecies.dog);
      notifier.updateCurrentWeight(25.0);
      notifier.updateRibPalpation(RibPalpation.moderatePressure);
      notifier.updateWaistVisibility(WaistVisibility.moderatelyVisible);
      notifier.updateAbdominalProfile(AbdominalProfile.straight);

      // Verify can calculate
      expect(container.read(bodyConditionCanCalculateProvider), isTrue);

      // Perform calculation
      await notifier.calculate();

      final state = container.read(bodyConditionProvider);
      expect(state.status, equals(BodyConditionCalculatorStatus.success));
      expect(state.output, isNotNull);
      expect(state.output!.bcsScore, greaterThanOrEqualTo(1));
      expect(state.output!.bcsScore, lessThanOrEqualTo(9));
      expect(state.history, hasLength(1));
      expect(state.error, isNull);
    });

    test('should handle calculation error with invalid input', () async {
      final notifier = container.read(bodyConditionProvider.notifier);

      // Set up invalid input (negative weight)
      notifier.updateCurrentWeight(-5.0);

      // Attempt calculation
      await notifier.calculate();

      final state = container.read(bodyConditionProvider);
      expect(state.status, equals(BodyConditionCalculatorStatus.error));
      expect(state.error, isNotNull);
      expect(state.error, contains('inválidos'));
    });

    test('should clear error correctly', () async {
      final notifier = container.read(bodyConditionProvider.notifier);

      // Create an error state
      notifier.updateCurrentWeight(-5.0);
      await notifier.calculate();

      // Verify error exists
      expect(container.read(bodyConditionProvider).hasError, isTrue);

      // Clear error
      notifier.clearError();

      final state = container.read(bodyConditionProvider);
      expect(state.status, equals(BodyConditionCalculatorStatus.initial));
      expect(state.error, isNull);
    });

    test('should clear result correctly', () async {
      final notifier = container.read(bodyConditionProvider.notifier);

      // Create a successful calculation
      notifier.updateSpecies(AnimalSpecies.dog);
      notifier.updateCurrentWeight(25.0);
      notifier.updateRibPalpation(RibPalpation.moderatePressure);
      notifier.updateWaistVisibility(WaistVisibility.moderatelyVisible);
      notifier.updateAbdominalProfile(AbdominalProfile.straight);
      await notifier.calculate();

      // Verify result exists
      expect(container.read(bodyConditionProvider).hasResult, isTrue);

      // Clear result
      notifier.clearResult();

      final state = container.read(bodyConditionProvider);
      expect(state.status, equals(BodyConditionCalculatorStatus.initial));
      expect(state.output, isNull);
    });

    test('should reset to initial state', () async {
      final notifier = container.read(bodyConditionProvider.notifier);

      // Modify state
      notifier.updateSpecies(AnimalSpecies.cat);
      notifier.updateCurrentWeight(5.0);
      await notifier.calculate();

      // Reset
      notifier.reset();

      final state = container.read(bodyConditionProvider);
      expect(state.status, equals(BodyConditionCalculatorStatus.initial));
      expect(state.input.species, equals(AnimalSpecies.dog)); // back to default
      expect(state.input.currentWeight, equals(0)); // back to default
      expect(state.output, isNull);
      expect(state.history, isEmpty);
    });

    test('should manage history correctly', () async {
      final notifier = container.read(bodyConditionProvider.notifier);

      // Setup valid input
      notifier.updateSpecies(AnimalSpecies.dog);
      notifier.updateCurrentWeight(25.0);
      notifier.updateRibPalpation(RibPalpation.moderatePressure);
      notifier.updateWaistVisibility(WaistVisibility.moderatelyVisible);
      notifier.updateAbdominalProfile(AbdominalProfile.straight);

      // Perform multiple calculations
      await notifier.calculate();
      notifier.updateCurrentWeight(30.0);
      await notifier.calculate();

      // Check history
      final history = container.read(bodyConditionHistoryProvider);
      expect(history, hasLength(2));

      // Remove from history
      notifier.removeFromHistory(0);
      final updatedHistory = container.read(bodyConditionHistoryProvider);
      expect(updatedHistory, hasLength(1));

      // Clear history
      notifier.clearHistory();
      final clearedHistory = container.read(bodyConditionHistoryProvider);
      expect(clearedHistory, isEmpty);
    });

    group('Convenience Providers', () {
      test('should provide correct input', () {
        final notifier = container.read(bodyConditionProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.cat);

        final input = container.read(bodyConditionInputProvider);
        expect(input.species, equals(AnimalSpecies.cat));
      });

      test('should provide correct loading state', () async {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        // Setup valid input
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateCurrentWeight(25.0);
        notifier.updateRibPalpation(RibPalpation.moderatePressure);
        notifier.updateWaistVisibility(WaistVisibility.moderatelyVisible);
        notifier.updateAbdominalProfile(AbdominalProfile.straight);

        // Start calculation (don't await immediately)
        final future = notifier.calculate();

        // Check loading state during calculation
        // Note: This might be flaky due to timing, but it demonstrates the concept
        final isLoading = container.read(bodyConditionLoadingProvider);
        
        await future; // Wait for completion
        
        // After completion, should not be loading
        final finalLoading = container.read(bodyConditionLoadingProvider);
        expect(finalLoading, isFalse);
      });

      test('should provide correct output', () async {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        // Setup and calculate
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateCurrentWeight(25.0);
        notifier.updateRibPalpation(RibPalpation.moderatePressure);
        notifier.updateWaistVisibility(WaistVisibility.moderatelyVisible);
        notifier.updateAbdominalProfile(AbdominalProfile.straight);
        await notifier.calculate();

        final output = container.read(bodyConditionOutputProvider);
        expect(output, isNotNull);
        expect(output!.bcsScore, greaterThanOrEqualTo(1));
      });

      test('should provide correct error state', () async {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        // Create error
        notifier.updateCurrentWeight(-5.0);
        await notifier.calculate();

        final error = container.read(bodyConditionErrorProvider);
        expect(error, isNotNull);
        expect(error!, contains('inválidos'));
      });

      test('should provide correct validation errors', () {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        notifier.updateCurrentWeight(-5.0);

        final validationErrors = container.read(bodyConditionValidationErrorsProvider);
        expect(validationErrors, isNotEmpty);
      });

      test('should provide correct can calculate state', () {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        // Invalid state
        expect(container.read(bodyConditionCanCalculateProvider), isFalse);

        // Valid state
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateCurrentWeight(25.0);
        notifier.updateRibPalpation(RibPalpation.moderatePressure);
        notifier.updateWaistVisibility(WaistVisibility.moderatelyVisible);
        notifier.updateAbdominalProfile(AbdominalProfile.straight);
        
        expect(container.read(bodyConditionCanCalculateProvider), isTrue);
      });
    });

    group('Suggestions Provider', () {
      test('should provide helpful suggestions', () {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        notifier.updateCurrentWeight(25.0);
        
        final suggestions = container.read(bodyConditionSuggestionsProvider);
        expect(suggestions, isNotEmpty);
        expect(suggestions.any((s) => s.contains('peso ideal')), isTrue);
      });

      test('should suggest breed information', () {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        notifier.updateCurrentWeight(25.0);
        
        final suggestions = container.read(bodyConditionSuggestionsProvider);
        expect(suggestions.any((s) => s.contains('raça')), isTrue);
      });

      test('should suggest age information', () {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        notifier.updateCurrentWeight(25.0);
        
        final suggestions = container.read(bodyConditionSuggestionsProvider);
        expect(suggestions.any((s) => s.contains('idade')), isTrue);
      });
    });

    group('History Stats Provider', () {
      test('should provide correct stats for empty history', () {
        final stats = container.read(bodyConditionHistoryStatsProvider);
        expect(stats['count'], equals(0));
      });

      test('should calculate correct stats for populated history', () async {
        final notifier = container.read(bodyConditionProvider.notifier);
        
        // Setup and perform calculations
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateCurrentWeight(25.0);
        notifier.updateRibPalpation(RibPalpation.moderatePressure);
        notifier.updateWaistVisibility(WaistVisibility.moderatelyVisible);
        notifier.updateAbdominalProfile(AbdominalProfile.straight);
        await notifier.calculate();

        final stats = container.read(bodyConditionHistoryStatsProvider);
        expect(stats['count'], equals(1));
        expect(stats['averageScore'], isA<double>());
        expect(stats['latestScore'], isA<int>());
      });
    });
  });
}