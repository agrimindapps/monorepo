import 'package:app_calculei/features/agriculture_calculator/domain/entities/nozzle_flow_calculation.dart';
import 'package:app_calculei/features/agriculture_calculator/domain/usecases/calculate_nozzle_flow_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculateNozzleFlowUseCase useCase;

  setUp(() {
    useCase = CalculateNozzleFlowUseCase();
  });

  group('CalculateNozzleFlowUseCase', () {
    test('should calculate nozzle flow successfully with valid parameters', () async {
      // Arrange
      const params = CalculateNozzleFlowParams(
        applicationRate: 200, // L/ha
        workingSpeed: 6, // km/h
        nozzleSpacing: 50, // cm
        pressure: 3, // bar
        nozzleType: NozzleType.fanJet,
        numberOfNozzles: 24,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Flow formula: (200 × 6 × 50) / 60000 = 1.0 L/min
          expect(calculation.requiredFlow, closeTo(1.0, 0.01));
          expect(calculation.recommendedNozzle, NozzleColorCode.yellow);
          expect(calculation.totalFlow, closeTo(24.0, 0.1));
          expect(calculation.workingWidth, closeTo(12.0, 0.1)); // 50cm × 24 / 100
          expect(calculation.calibrationTips.isNotEmpty, true);
        },
      );
    });

    test('should return ValidationFailure when application rate is zero', () async {
      // Arrange
      const params = CalculateNozzleFlowParams(
        applicationRate: 0,
        workingSpeed: 6,
        nozzleSpacing: 50,
        pressure: 3,
        nozzleType: NozzleType.fanJet,
        numberOfNozzles: 24,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, 'Taxa de aplicação deve ser maior que zero');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when working speed exceeds limit', () async {
      // Arrange
      const params = CalculateNozzleFlowParams(
        applicationRate: 200,
        workingSpeed: 35, // Above max
        nozzleSpacing: 50,
        pressure: 3,
        nozzleType: NozzleType.fanJet,
        numberOfNozzles: 24,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('30 km/h'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when nozzle spacing is invalid', () async {
      // Arrange
      const params = CalculateNozzleFlowParams(
        applicationRate: 200,
        workingSpeed: 6,
        nozzleSpacing: 0,
        pressure: 3,
        nozzleType: NozzleType.fanJet,
        numberOfNozzles: 24,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, 'Espaçamento entre bicos deve ser maior que zero');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should calculate correct color code for different flow rates', () async {
      // Arrange - High flow rate
      const paramsHighFlow = CalculateNozzleFlowParams(
        applicationRate: 400, // Higher rate
        workingSpeed: 8,
        nozzleSpacing: 50,
        pressure: 4,
        nozzleType: NozzleType.fullCone,
        numberOfNozzles: 20,
      );

      // Act
      final resultHighFlow = await useCase(paramsHighFlow);

      // Assert
      resultHighFlow.fold(
        (_) => fail('Should not fail'),
        (calculation) {
          // Flow: (400 × 8 × 50) / 60000 ≈ 2.67 L/min
          expect(calculation.requiredFlow, greaterThan(2.0));
          expect(calculation.recommendedNozzle, isNotNull);
        },
      );
    });

    test('should include calibration tips in result', () async {
      // Arrange
      const params = CalculateNozzleFlowParams(
        applicationRate: 150,
        workingSpeed: 5,
        nozzleSpacing: 50,
        pressure: 2.5,
        nozzleType: NozzleType.flatJet,
        numberOfNozzles: 20,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (_) => fail('Should not fail'),
        (calculation) {
          expect(calculation.calibrationTips.length, greaterThan(0));
          // Should have tip about nozzle color
          final hasTipWithColor = calculation.calibrationTips
              .any((tip) => tip.toLowerCase().contains('utilize bico'));
          expect(hasTipWithColor, true);
        },
      );
    });

    test('should calculate confirmed application rate correctly', () async {
      // Arrange
      const params = CalculateNozzleFlowParams(
        applicationRate: 200,
        workingSpeed: 6,
        nozzleSpacing: 50,
        pressure: 3,
        nozzleType: NozzleType.fanJet,
        numberOfNozzles: 24,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (_) => fail('Should not fail'),
        (calculation) {
          // Confirmed rate should be close to input rate
          expect(
            calculation.confirmedApplicationRate,
            closeTo(params.applicationRate, 10),
          );
        },
      );
    });
  });

  group('NozzleColorCode', () {
    test('should return correct color code for flow rate', () {
      expect(NozzleColorCode.fromFlow(0.7), NozzleColorCode.green);
      expect(NozzleColorCode.fromFlow(1.0), NozzleColorCode.yellow);
      expect(NozzleColorCode.fromFlow(1.4), NozzleColorCode.blue);
      expect(NozzleColorCode.fromFlow(1.8), NozzleColorCode.red);
      expect(NozzleColorCode.fromFlow(2.2), NozzleColorCode.brown);
    });

    test('should return null for out of range flow rate', () {
      expect(NozzleColorCode.fromFlow(0.3), isNull); // Below minimum
      expect(NozzleColorCode.fromFlow(10.0), isNull); // Above maximum
    });
  });
}
