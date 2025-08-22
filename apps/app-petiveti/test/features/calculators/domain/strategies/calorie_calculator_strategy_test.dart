import 'package:flutter_test/flutter_test.dart';
import 'package:app_petiveti/features/calculators/domain/entities/calorie_input.dart';
import 'package:app_petiveti/features/calculators/domain/strategies/calorie_calculator_strategy.dart';
import 'package:app_petiveti/features/calculators/domain/strategies/calculator_strategy.dart';

void main() {
  group('CalorieCalculatorStrategy', () {
    late CalorieCalculatorStrategy strategy;

    setUp(() {
      strategy = CalorieCalculatorStrategy();
    });

    group('Validation', () {
      test('should return no errors for valid input', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final errors = strategy.validateInput(input);

        // Assert
        expect(errors, isEmpty);
      });

      test('should return error for zero weight', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 0.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final errors = strategy.validateInput(input);

        // Assert
        expect(errors, contains('Peso deve ser maior que zero'));
      });

      test('should return error for excessive weight', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 200.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final errors = strategy.validateInput(input);

        // Assert
        expect(errors, contains('Peso muito alto (máximo 150kg)'));
      });

      test('should return error for negative age', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: -5,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final errors = strategy.validateInput(input);

        // Assert
        expect(errors, contains('Idade não pode ser negativa'));
      });

      test('should return error for lactating animal without offspring count', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.cat,
          weight: 4.0,
          age: 24,
          physiologicalState: PhysiologicalState.lactating,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final errors = strategy.validateInput(input);

        // Assert
        expect(errors, contains('Número de filhotes deve ser informado para animais em lactação'));
      });

      test('should return error for inconsistent age and growth state', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 24, // 2 anos
          physiologicalState: PhysiologicalState.growth,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final errors = strategy.validateInput(input);

        // Assert
        expect(errors, contains('Estado de crescimento inconsistente com idade acima de 12 meses'));
      });
    });

    group('RER Calculation', () {
      test('should calculate RER correctly for large dogs (>2kg)', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // RER = 70 × 25^0.75 ≈ 70 × 13.75 ≈ 962.5
        expect(result.restingEnergyRequirement, closeTo(962.5, 50));
      });

      test('should calculate RER correctly for small animals (≤2kg)', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.cat,
          weight: 1.5,
          age: 12,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.light,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // RER = (30 × 1.5) + 70 = 45 + 70 = 115
        expect(result.restingEnergyRequirement, closeTo(115, 5));
      });
    });

    group('DER Calculation', () {
      test('should calculate DER correctly for normal adult dog', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // RER ≈ 962.5, DER = RER × 1.6 (normal) × 1.2 (moderate) × 1.0 (ideal) × 1.0 (normal env) × 1.0 (no medical) × 1.0 (age) × 1.0 (species)
        final expectedDer = result.restingEnergyRequirement * 1.6 * 1.2;
        expect(result.dailyEnergyRequirement, closeTo(expectedDer, 50));
      });

      test('should calculate DER correctly for lactating cat with offspring', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.cat,
          weight: 4.0,
          age: 24,
          physiologicalState: PhysiologicalState.lactating,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
          numberOfOffspring: 4,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Para lactação: DER = RER × base_factor + RER × (0.25 × number_of_offspring)
        // Lactating base factor = 2.0, bonus = 0.25 × 4 = 1.0
        final expectedMultiplier = 2.0 + 1.0; // 3.0 total
        final expectedDer = result.restingEnergyRequirement * expectedMultiplier * 1.2 * 1.0; // moderate activity, ideal BCS
        expect(result.dailyEnergyRequirement, closeTo(expectedDer, 100));
      });

      test('should calculate DER correctly for growing puppy', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 8.0,
          age: 6,
          physiologicalState: PhysiologicalState.growth,
          activityLevel: ActivityLevel.active,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Growth factor = 3.0, active = 1.6
        final expectedMultiplier = 3.0 * 1.6 * 1.1; // age adjustment for young
        expect(result.dailyEnergyRequirement, greaterThan(result.restingEnergyRequirement * 4));
      });

      test('should calculate DER correctly for overweight senior dog', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 30.0,
          age: 108, // 9 anos
          physiologicalState: PhysiologicalState.senior,
          activityLevel: ActivityLevel.light,
          bodyConditionScore: BodyConditionScore.overweight,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Senior factor = 1.2, light activity = 1.0, overweight = 0.8, senior age adjustment = 0.95
        final expectedMultiplier = 1.2 * 1.0 * 0.8 * 0.95;
        expect(result.dailyEnergyRequirement, closeTo(result.restingEnergyRequirement * expectedMultiplier, 100));
      });
    });

    group('Macronutrient Calculation', () {
      test('should calculate macronutrients correctly for dogs', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Protein should be approximately 25% of total calories / 4 kcal/g
        final expectedProtein = result.dailyEnergyRequirement * 0.25 / 4;
        expect(result.proteinRequirement, closeTo(expectedProtein, 20));
        
        // Fat should be approximately 15% of total calories / 9 kcal/g
        final expectedFat = result.dailyEnergyRequirement * 0.15 / 9;
        expect(result.fatRequirement, closeTo(expectedFat, 10));
      });

      test('should calculate macronutrients correctly for cats', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.cat,
          weight: 4.5,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.light,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Cats need more protein (45%) and fat (20%)
        final expectedProtein = result.dailyEnergyRequirement * 0.45 / 4;
        expect(result.proteinRequirement, closeTo(expectedProtein, 15));
        
        final expectedFat = result.dailyEnergyRequirement * 0.20 / 9;
        expect(result.fatRequirement, closeTo(expectedFat, 10));
      });
    });

    group('Water Requirement Calculation', () {
      test('should calculate water requirement correctly for normal conditions', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Base water need: 60ml/kg/day = 25 × 60 = 1500ml
        expect(result.waterRequirement, closeTo(1500, 200));
      });

      test('should increase water requirement for lactating animals', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.cat,
          weight: 4.0,
          age: 24,
          physiologicalState: PhysiologicalState.lactating,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
          numberOfOffspring: 4,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Lactating animals need 2.5x more water
        final expectedWater = 4.0 * 60 * 2.5; // 600ml
        expect(result.waterRequirement, closeTo(expectedWater, 100));
      });
    });

    group('Feeding Recommendations', () {
      test('should recommend correct meal frequency for puppies', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 5.0,
          age: 3, // Very young puppy
          physiologicalState: PhysiologicalState.growth,
          activityLevel: ActivityLevel.active,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.feedingRecommendations.mealsPerDay, equals(4));
      });

      test('should recommend correct meal frequency for adult dogs', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.feedingRecommendations.mealsPerDay, equals(2));
      });

      test('should recommend correct meal frequency for senior dogs', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 20.0,
          age: 108, // 9 years old
          physiologicalState: PhysiologicalState.senior,
          activityLevel: ActivityLevel.light,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.feedingRecommendations.mealsPerDay, equals(3));
      });
    });

    group('Special Conditions', () {
      test('should apply medical condition adjustments correctly', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
          medicalCondition: MedicalCondition.diabetes,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Diabetes factor = 0.95
        expect(result.calculationDetails.medicalFactor, equals(0.95));
      });

      test('should apply environmental condition adjustments correctly', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
          environmentalCondition: EnvironmentalCondition.cold,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        // Cold factor = 1.25
        expect(result.calculationDetails.environmentalFactor, equals(1.25));
      });
    });

    group('Weight Management', () {
      test('should recommend weight loss for overweight animals', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 30.0,
          idealWeight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.overweight,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.weightManagementAdvice.weightGoal, contains('Perder peso'));
        expect(result.weightManagementAdvice.targetWeight, equals(25.0));
        expect(result.weightManagementAdvice.weeklyWeightChange, isNegative);
      });

      test('should recommend weight gain for underweight animals', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 20.0,
          idealWeight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.underweight,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.weightManagementAdvice.weightGoal, contains('Ganhar peso'));
        expect(result.weightManagementAdvice.targetWeight, equals(25.0));
        expect(result.weightManagementAdvice.weeklyWeightChange, isPositive);
      });
    });

    group('Calculation Details', () {
      test('should provide correct calculation details', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.calculationDetails.rerFormula, contains('70 × 25.0^0.75'));
        expect(result.calculationDetails.physiologicalFactor, equals(1.6));
        expect(result.calculationDetails.activityFactor, equals(1.2));
        expect(result.calculationDetails.bodyConditionFactor, equals(1.0));
        expect(result.calculationDetails.adjustmentsApplied, isNotEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle minimum weight correctly', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.cat,
          weight: 0.5, // Very small kitten
          age: 2,
          physiologicalState: PhysiologicalState.growth,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.restingEnergyRequirement, greaterThan(0));
        expect(result.dailyEnergyRequirement, greaterThan(result.restingEnergyRequirement));
      });

      test('should handle maximum offspring count', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: 30.0,
          age: 24,
          physiologicalState: PhysiologicalState.lactating,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
          numberOfOffspring: 12, // Large litter
        );

        // Act
        final result = strategy.calculate(input);

        // Assert
        expect(result.dailyEnergyRequirement, greaterThan(result.restingEnergyRequirement * 4));
        expect(result.waterRequirement, greaterThan(1000)); // Should be significantly elevated
      });
    });

    group('Error Handling', () {
      test('should throw InvalidInputException for invalid input', () {
        // Arrange
        const input = CalorieInput(
          species: AnimalSpecies.dog,
          weight: -5.0, // Invalid weight
          age: 36,
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );

        // Act & Assert
        expect(
          () => strategy.calculate(input),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });
  });
}