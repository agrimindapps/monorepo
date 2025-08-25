import 'package:app_petiveti/features/calculators/domain/entities/body_condition_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BodyConditionInput', () {
    test('should create valid input with required parameters', () {
      const input = BodyConditionInput(
        species: AnimalSpecies.dog,
        currentWeight: 25.0,
        ribPalpation: RibPalpation.moderatePressure,
        waistVisibility: WaistVisibility.moderatelyVisible,
        abdominalProfile: AbdominalProfile.straight,
      );

      expect(input.species, equals(AnimalSpecies.dog));
      expect(input.currentWeight, equals(25.0));
      expect(input.ribPalpation, equals(RibPalpation.moderatePressure));
      expect(input.waistVisibility, equals(WaistVisibility.moderatelyVisible));
      expect(input.abdominalProfile, equals(AbdominalProfile.straight));
      expect(input.bcsScale, equals(BcsScale.ninelevel)); // default
      expect(input.isNeutered, equals(false)); // default
      expect(input.hasMetabolicConditions, equals(false)); // default
    });

    test('should create input with optional parameters', () {
      const input = BodyConditionInput(
        species: AnimalSpecies.cat,
        currentWeight: 4.5,
        ribPalpation: RibPalpation.easy,
        waistVisibility: WaistVisibility.wellVisible,
        abdominalProfile: AbdominalProfile.slightlyRetracted,
        idealWeight: 4.2,
        bcsScale: BcsScale.fivelevel,
        observations: 'Very active cat',
        animalAge: 36,
        animalBreed: 'Siamese',
        isNeutered: true,
        hasMetabolicConditions: true,
        metabolicConditions: ['diabetes', 'hyperthyroidism'],
      );

      expect(input.species, equals(AnimalSpecies.cat));
      expect(input.idealWeight, equals(4.2));
      expect(input.bcsScale, equals(BcsScale.fivelevel));
      expect(input.observations, equals('Very active cat'));
      expect(input.animalAge, equals(36));
      expect(input.animalBreed, equals('Siamese'));
      expect(input.isNeutered, equals(true));
      expect(input.hasMetabolicConditions, equals(true));
      expect(input.metabolicConditions, contains('diabetes'));
      expect(input.metabolicConditions, contains('hyperthyroidism'));
    });

    group('Validation', () {
      test('should be valid with positive weight', () {
        const input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input.isValid, isTrue);
        expect(input.validationErrors, isEmpty);
      });

      test('should be invalid with zero weight', () {
        const input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 0.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input.isValid, isFalse);
        expect(input.validationErrors, isNotEmpty);
        expect(input.validationErrors.first, contains('maior que zero'));
      });

      test('should be invalid with negative weight', () {
        const input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: -5.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input.isValid, isFalse);
        expect(input.validationErrors, contains('Peso atual deve ser maior que zero'));
      });

      test('should be invalid with excessively high weight', () {
        const input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 250.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input.isValid, isFalse);
        expect(input.validationErrors, contains(contains('excessivamente alto')));
      });

      test('should be invalid with zero ideal weight', () {
        const input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          idealWeight: 0.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input.isValid, isFalse);
        expect(input.validationErrors, contains('Peso ideal deve ser maior que zero'));
      });

      test('should be invalid with excessive weight difference', () {
        const input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 10.0,
          idealWeight: 50.0, // 5x difference
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input.isValid, isFalse);
        expect(
          input.validationErrors,
          contains(contains('Diferença entre peso atual e ideal parece excessiva')),
        );
      });

      test('should be valid with reasonable weight difference', () {
        const input = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 20.0,
          idealWeight: 25.0, // 25% difference - reasonable
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input.isValid, isTrue);
        expect(input.validationErrors, isEmpty);
      });
    });

    group('CopyWith', () {
      test('should create copy with updated species', () {
        const originalInput = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final updatedInput = originalInput.copyWith(species: AnimalSpecies.cat);

        expect(updatedInput.species, equals(AnimalSpecies.cat));
        expect(updatedInput.currentWeight, equals(25.0)); // unchanged
        expect(updatedInput.ribPalpation, equals(RibPalpation.moderatePressure)); // unchanged
      });

      test('should create copy with updated weight', () {
        const originalInput = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final updatedInput = originalInput.copyWith(currentWeight: 30.0);

        expect(updatedInput.currentWeight, equals(30.0));
        expect(updatedInput.species, equals(AnimalSpecies.dog)); // unchanged
      });

      test('should create copy with updated optional parameters', () {
        const originalInput = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        final updatedInput = originalInput.copyWith(
          idealWeight: 23.0,
          animalAge: 48,
          isNeutered: true,
          observations: 'Updated observations',
        );

        expect(updatedInput.idealWeight, equals(23.0));
        expect(updatedInput.animalAge, equals(48));
        expect(updatedInput.isNeutered, equals(true));
        expect(updatedInput.observations, equals('Updated observations'));
        // Original values should remain
        expect(updatedInput.species, equals(AnimalSpecies.dog));
        expect(updatedInput.currentWeight, equals(25.0));
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        const input1 = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          idealWeight: 23.0,
          animalAge: 36,
        );

        const input2 = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
          idealWeight: 23.0,
          animalAge: 36,
        );

        expect(input1, equals(input2));
        expect(input1.hashCode, equals(input2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const input1 = BodyConditionInput(
          species: AnimalSpecies.dog,
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        const input2 = BodyConditionInput(
          species: AnimalSpecies.cat, // Different species
          currentWeight: 25.0,
          ribPalpation: RibPalpation.moderatePressure,
          waistVisibility: WaistVisibility.moderatelyVisible,
          abdominalProfile: AbdominalProfile.straight,
        );

        expect(input1, isNot(equals(input2)));
      });
    });

    group('Enums', () {
      test('AnimalSpecies should have correct values', () {
        expect(AnimalSpecies.dog.code, equals('dog'));
        expect(AnimalSpecies.dog.displayName, equals('Cão'));
        expect(AnimalSpecies.cat.code, equals('cat'));
        expect(AnimalSpecies.cat.displayName, equals('Gato'));
      });

      test('RibPalpation should have correct scores', () {
        expect(RibPalpation.veryDifficult.score, equals(1));
        expect(RibPalpation.difficult.score, equals(2));
        expect(RibPalpation.moderatePressure.score, equals(3));
        expect(RibPalpation.easy.score, equals(4));
        expect(RibPalpation.veryEasy.score, equals(5));
      });

      test('WaistVisibility should have correct scores', () {
        expect(WaistVisibility.notVisible.score, equals(1));
        expect(WaistVisibility.barelyVisible.score, equals(2));
        expect(WaistVisibility.moderatelyVisible.score, equals(3));
        expect(WaistVisibility.wellVisible.score, equals(4));
        expect(WaistVisibility.veryPronounced.score, equals(5));
      });

      test('AbdominalProfile should have correct scores', () {
        expect(AbdominalProfile.pendular.score, equals(1));
        expect(AbdominalProfile.slightlyBulging.score, equals(2));
        expect(AbdominalProfile.straight.score, equals(3));
        expect(AbdominalProfile.slightlyRetracted.score, equals(4));
        expect(AbdominalProfile.veryRetracted.score, equals(5));
      });

      test('BcsScale should have correct values', () {
        expect(BcsScale.ninelevel.code, equals('9level'));
        expect(BcsScale.ninelevel.displayName, contains('1-9'));
        expect(BcsScale.fivelevel.code, equals('5level'));
        expect(BcsScale.fivelevel.displayName, contains('1-5'));
      });
    });
  });
}