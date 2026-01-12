import 'package:flutter_test/flutter_test.dart';

import 'package:app_calculei/features/agriculture_calculator/domain/entities/harvester_setup_calculation.dart';
import 'package:app_calculei/features/agriculture_calculator/domain/usecases/calculate_harvester_setup_usecase.dart';

void main() {
  group('HarvesterSetupCalculation', () {
    test('empty factory should create valid empty instance', () {
      final calculation = HarvesterSetupCalculation.empty();

      expect(calculation.id, isEmpty);
      expect(calculation.cropType, 'Soja');
      expect(calculation.productivity, 0);
      expect(calculation.moisture, 13.0);
      expect(calculation.harvestSpeed, 5.0);
      expect(calculation.platformWidth, 6.0);
    });

    test('copyWith should update specific fields', () {
      final original = HarvesterSetupCalculation.empty();
      final updated = original.copyWith(
        cropType: 'Milho',
        productivity: 100,
      );

      expect(updated.cropType, 'Milho');
      expect(updated.productivity, 100);
      expect(updated.moisture, 13.0); // Unchanged
      expect(updated.harvestSpeed, 5.0); // Unchanged
    });
  });

  group('CalculateHarvesterSetupUseCase', () {
    late CalculateHarvesterSetupUseCase useCase;

    setUp(() {
      useCase = const CalculateHarvesterSetupUseCase();
    });

    group('Validation', () {
      test('should reject invalid crop type', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'InvalidCrop',
          productivity: 60,
          moisture: 13,
        );

        final result = await useCase(params);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('Tipo de cultura inválido')),
          (_) => fail('Should return failure'),
        );
      });

      test('should reject productivity below range', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 10, // Below 20 sc/ha minimum
          moisture: 13,
        );

        final result = await useCase(params);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('Produtividade fora da faixa')),
          (_) => fail('Should return failure'),
        );
      });

      test('should reject moisture outside safe range', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 5, // Too low
        );

        final result = await useCase(params);

        expect(result.isLeft(), true);
      });

      test('should reject harvest speed below minimum', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 13,
          harvestSpeed: 1.5, // Below 2 km/h
        );

        final result = await useCase(params);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('Velocidade de colheita')),
          (_) => fail('Should return failure'),
        );
      });

      test('should reject platform width outside range', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 13,
          platformWidth: 2, // Below 3m
        );

        final result = await useCase(params);

        expect(result.isLeft(), true);
      });
    });

    group('Calculation - Soja', () {
      test('should calculate correctly for Soja with ideal conditions', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 13, // Ideal moisture
          harvestSpeed: 5,
          platformWidth: 6,
        );

        final result = await useCase(params);

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should return success'),
          (calculation) {
            expect(calculation.cropType, 'Soja');
            expect(calculation.productivity, 60);
            expect(calculation.moisture, 13);

            // Check settings are within ranges
            expect(calculation.cylinderSpeed, greaterThanOrEqualTo(350));
            expect(calculation.cylinderSpeed, lessThanOrEqualTo(550));
            expect(calculation.concaveOpening, greaterThanOrEqualTo(12));
            expect(calculation.concaveOpening, lessThanOrEqualTo(20));

            // Check capacity calculation
            // (6m × 5 km/h × 0.75) / 10 = 2.25 ha/h
            expect(calculation.harvestCapacity, closeTo(2.25, 0.01));

            // Check ranges are populated
            expect(calculation.cylinderSpeedRange, contains('350-550 RPM'));
            expect(calculation.concaveOpeningRange, contains('12-20 mm'));
            expect(calculation.fanSpeedRange, contains('850-1100 RPM'));
            expect(calculation.sieveOpeningRange, contains('11-15 mm'));

            // Quality status
            expect(calculation.qualityStatus, isNotEmpty);
          },
        );
      });

      test('should adjust settings for high moisture', () async {
        final paramsIdeal = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 13, // Ideal
          harvestSpeed: 5,
          platformWidth: 6,
        );

        final paramsHigh = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 18, // High moisture
          harvestSpeed: 5,
          platformWidth: 6,
        );

        final resultIdeal = await useCase(paramsIdeal);
        final resultHigh = await useCase(paramsHigh);

        expect(resultIdeal.isRight(), true);
        expect(resultHigh.isRight(), true);

        resultIdeal.fold(
          (_) => fail('Should succeed'),
          (calcIdeal) {
            resultHigh.fold(
              (_) => fail('Should succeed'),
              (calcHigh) {
                // High moisture should reduce cylinder speed
                expect(
                  calcHigh.cylinderSpeed,
                  lessThan(calcIdeal.cylinderSpeed),
                );
              },
            );
          },
        );
      });

      test('should estimate higher loss at higher speed', () async {
        final paramsSlow = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 13,
          harvestSpeed: 4, // Moderate speed
          platformWidth: 6,
        );

        final paramsFast = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 13,
          harvestSpeed: 9, // High speed
          platformWidth: 6,
        );

        final resultSlow = await useCase(paramsSlow);
        final resultFast = await useCase(paramsFast);

        expect(resultSlow.isRight(), true);
        expect(resultFast.isRight(), true);

        resultSlow.fold(
          (_) => fail('Should succeed'),
          (calcSlow) {
            resultFast.fold(
              (_) => fail('Should succeed'),
              (calcFast) {
                // Fast harvest should have higher estimated loss
                expect(calcFast.estimatedLoss, greaterThan(calcSlow.estimatedLoss));
              },
            );
          },
        );
      });
    });

    group('Calculation - Other Crops', () {
      test('should calculate correctly for Milho', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Milho',
          productivity: 100,
          moisture: 15, // Ideal for Milho
          harvestSpeed: 5,
          platformWidth: 6,
        );

        final result = await useCase(params);

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should succeed'),
          (calculation) {
            expect(calculation.cropType, 'Milho');
            expect(calculation.cylinderSpeedRange, contains('280-450 RPM'));
            expect(calculation.concaveOpeningRange, contains('20-32 mm'));
          },
        );
      });

      test('should calculate correctly for Trigo', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Trigo',
          productivity: 50,
          moisture: 12.5, // Ideal for Trigo
          harvestSpeed: 5,
          platformWidth: 6,
        );

        final result = await useCase(params);

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should succeed'),
          (calculation) {
            expect(calculation.cropType, 'Trigo');
            // Trigo requires higher cylinder speed
            expect(calculation.cylinderSpeed, greaterThan(700));
            expect(calculation.cylinderSpeedRange, contains('700-950 RPM'));
          },
        );
      });

      test('should calculate correctly for Arroz', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Arroz',
          productivity: 120,
          moisture: 20, // Ideal for Arroz
          harvestSpeed: 5,
          platformWidth: 6,
        );

        final result = await useCase(params);

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should succeed'),
          (calculation) {
            expect(calculation.cropType, 'Arroz');
            expect(calculation.cylinderSpeedRange, contains('650-900 RPM'));
          },
        );
      });

      test('should calculate correctly for Feijão', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Feijão',
          productivity: 45,
          moisture: 14, // Ideal for Feijão
          harvestSpeed: 5,
          platformWidth: 6,
        );

        final result = await useCase(params);

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should succeed'),
          (calculation) {
            expect(calculation.cropType, 'Feijão');
            expect(calculation.cylinderSpeedRange, contains('320-500 RPM'));
          },
        );
      });
    });

    group('Quality Status', () {
      test('should return Excelente for optimal conditions', () async {
        final params = CalculateHarvesterSetupParams(
          cropType: 'Soja',
          productivity: 60,
          moisture: 13, // Ideal
          harvestSpeed: 4, // Moderate
          platformWidth: 6,
        );

        final result = await useCase(params);

        result.fold(
          (_) => fail('Should succeed'),
          (calculation) {
            // Should have good quality status with ideal conditions
            expect(
              ['Excelente', 'Boa'].contains(calculation.qualityStatus),
              true,
            );
          },
        );
      });
    });
  });
}
