import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_petiveti/features/calculators/domain/entities/calorie_input.dart';
import 'package:app_petiveti/features/calculators/presentation/providers/calorie_provider.dart';

void main() {
  group('Calorie Calculator Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Real-world Scenarios', () {
      test('should calculate correctly for typical house dog', () async {
        // Arrange - Golden Retriever, adult, moderately active
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(30.0);
        notifier.updateAge(48); // 4 years
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.restingEnergyRequirement, inInclusiveRange(1100, 1300));
        expect(result.dailyEnergyRequirement, inInclusiveRange(1700, 2100));
        expect(result.proteinRequirement, inInclusiveRange(100, 140));
        expect(result.fatRequirement, inInclusiveRange(25, 40));
        expect(result.waterRequirement, inInclusiveRange(1500, 2200));
        expect(result.feedingRecommendations.mealsPerDay, 2);
        expect(result.feedingRecommendations.gramsPerMeal, inInclusiveRange(200, 350));
      });

      test('should calculate correctly for indoor cat', () async {
        // Arrange - Typical indoor cat, neutered, light activity
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.cat);
        notifier.updateWeight(4.5);
        notifier.updateAge(36); // 3 years
        notifier.updatePhysiologicalState(PhysiologicalState.neutered);
        notifier.updateActivityLevel(ActivityLevel.light);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.restingEnergyRequirement, inInclusiveRange(180, 220));
        expect(result.dailyEnergyRequirement, inInclusiveRange(200, 280));
        expect(result.proteinRequirement, inInclusiveRange(22, 32));
        expect(result.fatRequirement, inInclusiveRange(4, 8));
        expect(result.waterRequirement, inInclusiveRange(250, 350));
        expect(result.feedingRecommendations.mealsPerDay, 2);
      });

      test('should calculate correctly for growing puppy', () async {
        // Arrange - 6-month old Lab puppy
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(15.0);
        notifier.updateAge(6);
        notifier.updatePhysiologicalState(PhysiologicalState.juvenile);
        notifier.updateActivityLevel(ActivityLevel.active);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.restingEnergyRequirement, inInclusiveRange(600, 800));
        expect(result.dailyEnergyRequirement, inInclusiveRange(1800, 2800));
        expect(result.feedingRecommendations.mealsPerDay, 3);
        expect(result.specialConsiderations, 
               anyElement(contains('CRESCIMENTO')));
      });

      test('should calculate correctly for lactating mother dog', () async {
        // Arrange - Lactating female with 6 puppies
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(25.0);
        notifier.updateAge(36);
        notifier.updatePhysiologicalState(PhysiologicalState.lactating);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);
        notifier.updateNumberOfOffspring(6);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.restingEnergyRequirement, inInclusiveRange(900, 1100));
        expect(result.dailyEnergyRequirement, inInclusiveRange(3500, 5000));
        expect(result.waterRequirement, inInclusiveRange(3500, 5500));
        expect(result.specialConsiderations, 
               anyElement(contains('LACTAÇÃO')));
        expect(result.feedingRecommendations.treatAllowance, 5.0);
      });

      test('should calculate correctly for overweight senior dog', () async {
        // Arrange - 10-year old overweight Golden Retriever
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(35.0);
        notifier.updateIdealWeight(28.0);
        notifier.updateAge(120); // 10 years
        notifier.updatePhysiologicalState(PhysiologicalState.senior);
        notifier.updateActivityLevel(ActivityLevel.light);
        notifier.updateBodyConditionScore(BodyConditionScore.overweight);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.dailyEnergyRequirement, 
               lessThan(result.restingEnergyRequirement * 1.5)); // Reduced for weight loss
        expect(result.weightManagementAdvice.weightGoal, contains('Perder peso'));
        expect(result.weightManagementAdvice.targetWeight, 28.0);
        expect(result.weightManagementAdvice.weeklyWeightChange, isNegative);
        expect(result.feedingRecommendations.mealsPerDay, 3);
      });

      test('should calculate correctly for working dog', () async {
        // Arrange - Active working/competition dog
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(25.0);
        notifier.updateAge(36);
        notifier.updatePhysiologicalState(PhysiologicalState.working);
        notifier.updateActivityLevel(ActivityLevel.extreme);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.dailyEnergyRequirement, 
               greaterThan(result.restingEnergyRequirement * 4));
        expect(result.specialConsiderations, 
               anyElement(contains('ATIVIDADE EXTREMA')));
        expect(result.waterRequirement, greaterThan(1500));
      });

      test('should calculate correctly for diabetic cat', () async {
        // Arrange - Diabetic cat with special dietary needs
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.cat);
        notifier.updateWeight(5.5);
        notifier.updateAge(84); // 7 years
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        notifier.updateActivityLevel(ActivityLevel.light);
        notifier.updateBodyConditionScore(BodyConditionScore.overweight);
        notifier.updateMedicalCondition(MedicalCondition.diabetes);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.calculationDetails.medicalFactor, 0.95);
        expect(result.nutritionalAdjustments.restrictedIngredients,
               anyElement(contains('Açúcares')));
        expect(result.recommendations,
               anyElement((r) => r.title.contains('Dieta Terapêutica')));
        expect(result.waterRequirement, 
               greaterThan(5.5 * 60 * 1.3)); // Increased for diabetes
      });
    });

    group('Edge Cases and Stress Tests', () {
      test('should handle very small animals correctly', () async {
        // Arrange - Very small kitten
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.cat);
        notifier.updateWeight(0.5);
        notifier.updateAge(2);
        notifier.updatePhysiologicalState(PhysiologicalState.growth);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.restingEnergyRequirement, inInclusiveRange(80, 120));
        expect(result.dailyEnergyRequirement, greaterThan(150));
        expect(result.feedingRecommendations.mealsPerDay, 4);
      });

      test('should handle very large animals correctly', () async {
        // Arrange - Giant breed dog
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(80.0);
        notifier.updateAge(48);
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.restingEnergyRequirement, greaterThan(2000));
        expect(result.dailyEnergyRequirement, greaterThan(3000));
        expect(result.feedingRecommendations.gramsPerMeal, greaterThan(500));
      });

      test('should handle extreme environmental conditions', () async {
        // Arrange - Dog in extreme cold
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(25.0);
        notifier.updateAge(36);
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);
        notifier.updateEnvironmentalCondition(EnvironmentalCondition.cold);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.calculationDetails.environmentalFactor, 1.25);
        expect(result.dailyEnergyRequirement, 
               greaterThan(result.restingEnergyRequirement * 2.0));
      });

      test('should handle multiple special conditions', () async {
        // Arrange - Senior diabetic dog in cold environment
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(20.0);
        notifier.updateAge(120);
        notifier.updatePhysiologicalState(PhysiologicalState.senior);
        notifier.updateActivityLevel(ActivityLevel.light);
        notifier.updateBodyConditionScore(BodyConditionScore.overweight);
        notifier.updateEnvironmentalCondition(EnvironmentalCondition.cold);
        notifier.updateMedicalCondition(MedicalCondition.diabetes);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.calculationDetails.totalMultiplier, lessThan(2.0));
        expect(result.recommendations, isNotEmpty);
        expect(result.specialConsiderations, 
               anyElement(contains('CONDIÇÃO MÉDICA')));
      });
    });

    group('Complete User Journey', () {
      test('should complete full calculation journey with step validation', () async {
        final notifier = container.read(calorieProvider.notifier);

        // Step 0: Basic Info
        expect(notifier.canProceedToNextStep(), false);
        
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(25.0);
        notifier.updateAge(36);
        expect(notifier.canProceedToNextStep(), true);
        
        notifier.nextStep();
        expect(container.read(calorieProvider).currentStep, 1);

        // Step 1: Physiological State
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        expect(notifier.canProceedToNextStep(), true);
        
        notifier.nextStep();
        expect(container.read(calorieProvider).currentStep, 2);

        // Step 2: Activity & BCS
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);
        expect(notifier.canProceedToNextStep(), true);
        
        notifier.nextStep();
        expect(container.read(calorieProvider).currentStep, 3);

        // Step 3: Special Conditions (optional)
        notifier.updateEnvironmentalCondition(EnvironmentalCondition.normal);
        notifier.updateMedicalCondition(MedicalCondition.none);
        expect(notifier.canProceedToNextStep(), true);
        
        notifier.nextStep();
        expect(container.read(calorieProvider).currentStep, 4);

        // Step 4: Review & Calculate
        expect(container.read(calorieProvider).canCalculate, true);
        
        await notifier.calculate();
        final state = container.read(calorieProvider);
        
        expect(state.hasResult, true);
        expect(state.output, isNotNull);
        expect(state.history, hasLength(1));
      });

      test('should handle preset loading and modification', () async {
        final notifier = container.read(calorieProvider.notifier);

        // Load preset
        notifier.loadPreset(CaloriePreset.adultDogNormal);
        var state = container.read(calorieProvider);
        expect(state.input.species, AnimalSpecies.dog);
        expect(state.input.weight, 25.0);

        // Modify preset
        notifier.updateWeight(30.0);
        notifier.updateActivityLevel(ActivityLevel.active);
        
        // Calculate
        await notifier.calculate();
        state = container.read(calorieProvider);
        
        expect(state.hasResult, true);
        expect(state.output!.input.weight, 30.0);
        expect(state.output!.input.activityLevel, ActivityLevel.active);
      });
    });

    group('Data Consistency', () {
      test('should maintain input-output consistency', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        const originalInput = CalorieInput(
          species: AnimalSpecies.cat,
          weight: 4.5,
          age: 24,
          physiologicalState: PhysiologicalState.lactating,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
          numberOfOffspring: 3,
        );
        
        notifier.updateInput(originalInput);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert
        expect(result.input, equals(originalInput));
        expect(result.calculatedAt, isNotNull);
        expect(result.calculatorId, isNotEmpty);
      });

      test('should validate calculation formula transparency', () async {
        // Arrange
        final notifier = container.read(calorieProvider.notifier);
        notifier.updateSpecies(AnimalSpecies.dog);
        notifier.updateWeight(20.0);
        notifier.updateAge(36);
        notifier.updatePhysiologicalState(PhysiologicalState.normal);
        notifier.updateActivityLevel(ActivityLevel.moderate);
        notifier.updateBodyConditionScore(BodyConditionScore.ideal);

        // Act
        await notifier.calculate();
        final result = container.read(calorieProvider).output!;

        // Assert - Verify calculation transparency
        expect(result.calculationDetails.rerFormula, contains('70 × 20.0^0.75'));
        expect(result.calculationDetails.physiologicalFactor, 1.6);
        expect(result.calculationDetails.activityFactor, 1.2);
        expect(result.calculationDetails.bodyConditionFactor, 1.0);
        expect(result.calculationDetails.adjustmentsApplied, isNotEmpty);
        
        // Verify manual calculation
        final expectedRer = 70 * (20.0 * 0.75); // Approximation
        expect(result.restingEnergyRequirement, 
               inInclusiveRange(expectedRer * 0.8, expectedRer * 1.2));
      });
    });
  });
}

/// Custom matcher for inclusive ranges
Matcher inInclusiveRange(num min, num max) {
  return predicate<num>((value) => value >= min && value <= max,
      'is in range [$min, $max]');
}