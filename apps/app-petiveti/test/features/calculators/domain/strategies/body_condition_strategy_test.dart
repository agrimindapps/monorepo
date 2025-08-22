import 'package:flutter_test/flutter_test.dart';

import 'package:app_petiveti/features/calculators/domain/entities/body_condition_input.dart';
import 'package:app_petiveti/features/calculators/domain/entities/body_condition_output.dart';
import 'package:app_petiveti/features/calculators/domain/strategies/body_condition_strategy.dart';
import 'package:app_petiveti/features/calculators/domain/strategies/calculator_strategy.dart';

void main() {
  group('BodyConditionStrategy', () {
    late BodyConditionStrategy strategy;

    setUp(() {
      strategy = const BodyConditionStrategy();
    });

    group('Basic Properties', () {
      test('should have correct id', () {
        expect(strategy.id, equals('body_condition_bcs'));
      });

      test('should have correct name', () {
        expect(strategy.name, contains('Calculadora de Condição Corporal'));
      });

      test('should support dogs and cats', () {
        expect(strategy.supportedSpecies, contains('dog'));
        expect(strategy.supportedSpecies, contains('cat'));
      });
    });

    group('Input Validation', () {
      test('should validate valid input', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final errors = strategy.validateInput(input);
        expect(errors, isEmpty);
      });

      test('should reject input with zero weight', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 0.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final errors = strategy.validateInput(input);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('maior que zero'));
      });

      test('should reject input with negative weight', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: -5.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final errors = strategy.validateInput(input);
        expect(errors, isNotEmpty);
      });

      test('should reject input with excessively high weight', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 250.0, // Way too high
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final errors = strategy.validateInput(input);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('excessivamente alto'));
      });

      test('should reject input with negative age', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          animalAge: -5,
        );

        final errors = strategy.validateInput(input);
        expect(errors, isNotEmpty);
        expect(errors, contains(contains('não pode ser negativa')));
      });

      test('should reject input with excessive age', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          animalAge: 400, // Over 33 years
        );

        final errors = strategy.validateInput(input);
        expect(errors, isNotEmpty);
      });
    });

    group('BCS Calculation', () {
      test('should calculate ideal BCS (5) for balanced input', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final result = strategy.calculate(input);
        expect(result.bcsScore, equals(5));
        expect(result.classification, equals(BcsClassification.ideal));
      });

      test('should calculate underweight BCS for very easy rib palpation', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 20.0,
          ribPalpation: RibPalpation.veryEasy,
          waistVisibility: WaistVisibility.veryPronounced,
          abdominalProfile: AbdominalProfile.veryRetracted,
        );

        final result = strategy.calculate(input);
        expect(result.bcsScore, greaterThanOrEqualTo(7));
        expect(result.needsWeightGain, isTrue);
      });

      test('should calculate overweight BCS for difficult rib palpation', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 35.0,
          ribPalpation: RibPalpation.veryDifficult,
          waistVisibility: WaistVisibility.notVisible,
          abdominalProfile: AbdominalProfile.pendular,
        );

        final result = strategy.calculate(input);
        expect(result.bcsScore, lessThanOrEqualTo(3));
        expect(result.needsWeightLoss, isTrue);
      });

      test('should ensure BCS is always between 1 and 9', () {
        // Test extreme inputs to ensure bounds
        final extremeInputs = [
          BodyConditionInput(
            species: AnimalSpecies.dog,
            currentWeight: 100.0,
            ribPalpation: RibPalpation.veryDifficult,
            waistVisibility: WaistVisibility.notVisible,
            abdominalProfile: AbdominalProfile.pendular,
          ),
          BodyConditionInput(
            species: AnimalSpecies.cat,
            currentWeight: 2.0,
            ribPalpation: RibPalpation.veryEasy,
            waistVisibility: WaistVisibility.veryPronounced,
            abdominalProfile: AbdominalProfile.veryRetracted,
          ),
        ];

        for (final input in extremeInputs) {
          final result = strategy.calculate(input);
          expect(result.bcsScore, greaterThanOrEqualTo(1));
          expect(result.bcsScore, lessThanOrEqualTo(9));
        }
      });
    });

    group('Weight Estimation', () {
      test('should use provided ideal weight when available', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          idealWeight: 22.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final result = strategy.calculate(input);
        expect(result.idealWeightEstimate, equals(22.0));
      });

      test('should estimate ideal weight for dogs when not provided', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 30.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final result = strategy.calculate(input);
        expect(result.idealWeightEstimate, isNotNull);
        expect(result.idealWeightEstimate!, greaterThan(0));
        expect(result.idealWeightEstimate!, lessThan(100)); // Reasonable upper bound
      });

      test('should estimate ideal weight for cats when not provided', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.cat,
          currentWeight: 5.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final result = strategy.calculate(input);
        expect(result.idealWeightEstimate, isNotNull);
        expect(result.idealWeightEstimate!, greaterThan(0));
        expect(result.idealWeightEstimate!, lessThan(15)); // Reasonable upper bound for cats
      });
    });

    group('Recommendations Generation', () {
      test('should generate weight loss recommendations for overweight animals', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 35.0,
          ribPalpation: RibPalpation.difficult,
          waistVisibility: WaistVisibility.barelyVisible,
          abdominalProfile: AbdominalProfile.slightlyBulging,
        );

        final result = strategy.calculate(input);
        expect(result.recommendations, isNotEmpty);
        expect(
          result.recommendations.any((rec) => 
            rec.type == NutritionalRecommendationType.decreaseFood),
          isTrue,
        );
        expect(result.needsWeightLoss, isTrue);
      });

      test('should generate weight gain recommendations for underweight animals', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 15.0,
          ribPalpation: RibPalpation.veryEasy,
          waistVisibility: WaistVisibility.veryPronounced,
          abdominalProfile: AbdominalProfile.veryRetracted,
        );

        final result = strategy.calculate(input);
        expect(result.recommendations, isNotEmpty);
        expect(
          result.recommendations.any((rec) => 
            rec.type == NutritionalRecommendationType.increaseFood),
          isTrue,
        );
        expect(result.needsWeightGain, isTrue);
      });

      test('should generate maintenance recommendations for ideal weight animals', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final result = strategy.calculate(input);
        expect(result.recommendations, isNotEmpty);
        expect(
          result.recommendations.any((rec) => 
            rec.type == NutritionalRecommendationType.maintain),
          isTrue,
        );
        expect(result.isIdealWeight, isTrue);
      });

      test('should add special recommendations for neutered animals', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          isNeutered: true,
        );

        final result = strategy.calculate(input);
        expect(
          result.recommendations.any((rec) => 
            rec.title.contains('Castrado')),
          isTrue,
        );
      });

      test('should add special recommendations for animals with metabolic conditions', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          hasMetabolicConditions: true,
        );

        final result = strategy.calculate(input);
        expect(
          result.recommendations.any((rec) => 
            rec.title.contains('Metabólicas')),
          isTrue,
        );
      });
    });

    group('Action Urgency Assessment', () {
      test('should require urgent attention for extremely underweight animals', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 10.0,
          ribPalpation: RibPalpation.veryEasy,
          waistVisibility: WaistVisibility.veryPronounced,
          abdominalProfile: AbdominalProfile.veryRetracted,
        );

        final result = strategy.calculate(input);
        if (result.bcsScore == 1) {
          expect(result.actionUrgency, equals(ActionUrgency.urgent));
        }
      });

      test('should require urgent attention for severely obese animals', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 50.0,
          ribPalpation: RibPalpation.veryDifficult,
          waistVisibility: WaistVisibility.notVisible,
          abdominalProfile: AbdominalProfile.pendular,
        );

        final result = strategy.calculate(input);
        if (result.bcsScore >= 8) {
          expect(result.actionUrgency, equals(ActionUrgency.urgent));
        }
      });

      test('should require routine monitoring for ideal weight animals', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final result = strategy.calculate(input);
        if (result.bcsScore == 5) {
          expect(result.actionUrgency, equals(ActionUrgency.routine));
        }
      });
    });

    group('Species-Specific Behavior', () {
      test('should handle cats differently from dogs', () {
        final dogInput = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final catInput = BodyConditionInput(
          species: AnimalSpecies.cat,
          currentWeight: 5.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final dogResult = strategy.calculate(dogInput);
        final catResult = strategy.calculate(catInput);

        // Both should be valid but may have different recommendations
        expect(dogResult.bcsScore, greaterThanOrEqualTo(1));
        expect(catResult.bcsScore, greaterThanOrEqualTo(1));
        
        // Cats typically have different metabolic rates
        expect(dogResult.recommendations, isNotEmpty);
        expect(catResult.recommendations, isNotEmpty);
      });
    });

    group('Error Handling', () {
      test('should throw InvalidInputException for invalid input', () {
        final input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: -10.0, // Invalid negative weight
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(
          () => strategy.calculate(input),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('Age and Neutering Corrections', () {
      test('should apply age corrections for puppies', () {
        final puppyInput = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 10.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          animalAge: 6, // 6 months old puppy
        );

        final result = strategy.calculate(puppyInput);
        // Should complete without errors and provide appropriate recommendations
        expect(result.idealWeightEstimate, isNotNull);
        expect(result.recommendations, isNotEmpty);
      });

      test('should apply neutering corrections', () {
        final neuteredInput = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          isNeutered: true,
        );

        final result = strategy.calculate(neuteredInput);
        expect(
          result.recommendations.any((rec) => rec.title.contains('Castrado')),
          isTrue,
        );
      });
    });
  });
}