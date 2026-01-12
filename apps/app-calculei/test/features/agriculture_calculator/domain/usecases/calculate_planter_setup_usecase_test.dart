import 'package:app_calculei/features/agriculture_calculator/domain/entities/planter_setup_calculation.dart';
import 'package:app_calculei/features/agriculture_calculator/domain/usecases/calculate_planter_setup_usecase.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculatePlanterSetupUseCase useCase;

  setUp(() {
    useCase = const CalculatePlanterSetupUseCase();
  });

  group('CalculatePlanterSetupUseCase', () {
    group('Success Cases', () {
      test('should calculate planter setup successfully for Soja with valid data', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 90,
          discHoles: 28,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            expect(calculation.cropType, 'Soja');
            expect(calculation.targetPopulation, 300000);
            expect(calculation.rowSpacing, 50);
            expect(calculation.germination, 90);
            expect(calculation.discHoles, 28);
            expect(calculation.thousandSeedWeight, 180.0); // Soja TSW
            expect(calculation.seedsPerMeter, greaterThan(0));
            expect(calculation.seedsPerHectare, greaterThan(0));
            expect(calculation.seedWeight, greaterThan(0));
            expect(calculation.wheelTurns, 10.0); // For 28-hole disc
            expect(calculation.id, isNotEmpty);
          },
        );
      });

      test('should calculate correct seeds per meter for Soja', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000, // plants/ha
          rowSpacing: 50, // cm
          germination: 90, // %
        );

        // Expected: (300000 × 50) / (10000 × 0.90) = 16.67 seeds/m

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            expect(calculation.seedsPerMeter, closeTo(16.67, 0.01));
          },
        );
      });

      test('should calculate correct seeds per hectare for Milho', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Milho',
          targetPopulation: 65000, // plants/ha
          rowSpacing: 70, // cm
          germination: 85, // %
        );

        // Seeds/m = (65000 × 70) / (10000 × 0.85) = 5.35
        // Seeds/ha = 5.35 × (10000 / 70) = 76470

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            expect(calculation.seedsPerMeter, closeTo(5.35, 0.01));
            expect(calculation.seedsPerHectare, closeTo(76470, 100));
            expect(calculation.thousandSeedWeight, 350.0); // Milho TSW
          },
        );
      });

      test('should use correct thousand seed weight for each crop type', () async {
        final cropWeights = {
          'Soja': 180.0,
          'Milho': 350.0,
          'Feijão': 250.0,
          'Algodão': 120.0,
          'Girassol': 60.0,
        };

        for (final entry in cropWeights.entries) {
          // Arrange - Use valid populations for each crop
          final params = CalculatePlanterSetupParams(
            cropType: entry.key,
            targetPopulation: entry.key == 'Milho' ? 65000 : 
                             entry.key == 'Girassol' ? 50000 :
                             entry.key == 'Algodão' ? 110000 : 250000,
            rowSpacing: 50,
            germination: 90,
          );

          // Act
          final result = await useCase(params);

          // Assert
          result.fold(
            (failure) => fail('Should not return failure for ${entry.key}: ${failure.message}'),
            (calculation) {
              expect(
                calculation.thousandSeedWeight,
                entry.value,
                reason: 'TSW for ${entry.key} should be ${entry.value}g',
              );
            },
          );
        }
      });

      test('should assign correct wheel turns based on disc holes', () async {
        final discToTurns = {
          20: 15.0,
          24: 12.0,
          28: 10.0,
          32: 8.0,
          36: 7.0,
          40: 6.0,
        };

        for (final entry in discToTurns.entries) {
          // Arrange
          final params = CalculatePlanterSetupParams(
            cropType: 'Soja',
            targetPopulation: 300000,
            rowSpacing: 50,
            germination: 90,
            discHoles: entry.key,
          );

          // Act
          final result = await useCase(params);

          // Assert
          result.fold(
            (failure) => fail('Should not return failure for ${entry.key} holes'),
            (calculation) {
              expect(
                calculation.wheelTurns,
                entry.value,
                reason: 'Wheel turns for ${entry.key} holes should be ${entry.value}',
              );
            },
          );
        }
      });

      test('should calculate seed weight correctly', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 90,
        );

        // Seeds/m = (300000 / 10000) × 0.5 / 0.9 = 16.67
        // Seeds/ha = 16.67 × (10000 / 0.5) = 333333
        // Weight = (333333 × 180) / 1000 = 60000 g / 1000 = 60 kg/ha

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            expect(calculation.seedWeight, closeTo(60, 1));
          },
        );
      });
    });

    group('Validation - Crop Type', () {
      test('should return ValidationFailure when crop type is invalid', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Trigo', // Invalid crop type
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 90,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Tipo de cultura inválido');
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('Validation - Population', () {
      test('should return ValidationFailure when population is zero', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 0,
          rowSpacing: 50,
          germination: 90,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'População alvo deve ser maior que zero');
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should return ValidationFailure when population is below minimum for crop', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 150000, // Min is 200k for Soja
          rowSpacing: 50,
          germination: 90,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('fora da faixa recomendada'));
            expect(failure.message, contains('200000'));
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should return ValidationFailure when population is above maximum for crop', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Milho',
          targetPopulation: 100000, // Max is 80k for Milho
          rowSpacing: 70,
          germination: 85,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('fora da faixa recomendada'));
            expect(failure.message, contains('80000'));
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('Validation - Row Spacing', () {
      test('should return ValidationFailure when row spacing is zero', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 0,
          germination: 90,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Espaçamento entre linhas deve ser maior que zero');
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should return ValidationFailure when row spacing is too small', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 15, // Min is 20 cm
          germination: 90,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Espaçamento entre linhas deve estar entre 20 e 100 cm');
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should return ValidationFailure when row spacing is too large', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 120, // Max is 100 cm
          germination: 90,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Espaçamento entre linhas deve estar entre 20 e 100 cm');
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('Validation - Germination', () {
      test('should return ValidationFailure when germination is zero', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 0,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Germinação deve estar entre 0 e 100%');
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should return ValidationFailure when germination is above 100', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 105,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Germinação deve estar entre 0 e 100%');
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should return ValidationFailure when germination is too low', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 65, // Min is 70%
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Germinação muito baixa'));
            expect(failure.message, contains('70'));
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('Validation - Disc Holes', () {
      test('should return ValidationFailure when disc holes is zero', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 90,
          discHoles: 0,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Número de furos do disco deve ser maior que zero');
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should return ValidationFailure when disc holes is invalid', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 90,
          discHoles: 25, // Invalid, must be 20, 24, 28, 32, 36, or 40
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Número de furos do disco inválido'));
            expect(failure.message, contains('20, 24, 28, 32, 36 ou 40'));
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle minimum valid values', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Girassol',
          targetPopulation: 40000, // Min for Girassol
          rowSpacing: 20, // Min spacing
          germination: 70, // Min germination
          discHoles: 20, // Min disc holes
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            expect(calculation.seedsPerMeter, greaterThan(0));
            expect(calculation.wheelTurns, 15.0); // For 20-hole disc
          },
        );
      });

      test('should handle maximum valid values', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 400000, // Max for Soja
          rowSpacing: 100, // Max spacing
          germination: 100, // Max germination
          discHoles: 40, // Max disc holes
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            expect(calculation.seedsPerMeter, greaterThan(0));
            expect(calculation.wheelTurns, 6.0); // For 40-hole disc
          },
        );
      });

      test('should handle decimal precision correctly', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 333333, // Odd number
          rowSpacing: 45.5, // Decimal spacing
          germination: 92.5, // Decimal germination
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            // Check values are properly rounded to 2 decimal places
            expect(calculation.seedsPerMeter.toString().split('.').length, lessThanOrEqualTo(2));
            expect(calculation.seedWeight.toString().split('.').length, lessThanOrEqualTo(2));
          },
        );
      });
    });

    group('Timestamp', () {
      test('should set calculatedAt timestamp', () async {
        // Arrange
        const params = CalculatePlanterSetupParams(
          cropType: 'Soja',
          targetPopulation: 300000,
          rowSpacing: 50,
          germination: 90,
        );

        final beforeCalculation = DateTime.now();

        // Act
        final result = await useCase(params);
        await Future.delayed(const Duration(milliseconds: 10));
        final afterCalculation = DateTime.now();

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculation) {
            expect(
              calculation.calculatedAt.isAfter(beforeCalculation.subtract(const Duration(seconds: 1))),
              true,
            );
            expect(
              calculation.calculatedAt.isBefore(afterCalculation.add(const Duration(seconds: 1))),
              true,
            );
          },
        );
      });
    });
  });
}
