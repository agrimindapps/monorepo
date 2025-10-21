// Package imports:
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:app_calculei/features/overtime_calculator/domain/usecases/calculate_overtime_usecase.dart';

void main() {
  late CalculateOvertimeUseCase useCase;

  setUp(() {
    useCase = CalculateOvertimeUseCase();
  });

  group('CalculateOvertimeUseCase -', () {
    // ========== SUCCESS SCENARIOS ==========

    test('should calculate overtime successfully with only 50% hours', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 20.0,
        workDaysMonth: 22,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.grossSalary, 3000.00);
          expect(calculation.hours50, 20.0);
          expect(calculation.totalOvertimeHours, 20.0);
          expect(calculation.normalHourValue, greaterThan(0));
          expect(calculation.hour50Value, greaterThan(calculation.normalHourValue));
          expect(calculation.netTotal, greaterThan(calculation.grossSalary));
        },
      );
    });

    test('should calculate correctly with mixed overtime types', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 4000.00,
        weeklyHours: 44,
        hours50: 10.0,
        hours100: 5.0,
        nightHours: 8.0,
        sundayHolidayHours: 4.0,
        workDaysMonth: 22,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.total50, greaterThan(0));
          expect(calculation.total100, greaterThan(0));
          expect(calculation.totalNightAdditional, greaterThan(0));
          expect(calculation.totalSundayHoliday, greaterThan(0));
          expect(calculation.dsrOvertime, greaterThan(0));
          expect(calculation.vacationReflection, greaterThan(0));
          expect(calculation.thirteenthReflection, greaterThan(0));
        },
      );
    });

    test('should calculate DSR correctly (1/6 of overtime)', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 12.0,
        workDaysMonth: 22,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final expectedDsr = calculation.totalOvertime / 6;
          expect(calculation.dsrOvertime, closeTo(expectedDsr, 0.01));
        },
      );
    });

    // ========== VALIDATION FAILURES ==========

    test('should return ValidationFailure when salary is zero', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 0,
        weeklyHours: 44,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('maior que zero')),
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when weekly hours is zero', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('maior que zero')),
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when overtime hours exceed limit', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 60.0,
        hours100: 50.0, // Total = 110 (exceeds limit of 100)
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('não pode exceder')),
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when overtime hours are negative', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: -10.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('não podem ser negativas')),
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when night hours are negative', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        nightHours: -5.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('não podem ser negativas')),
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when night percentage exceeds 100', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        nightAdditionalPercentage: 150.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('entre 0% e 100%')),
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when work days exceed 31', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        workDaysMonth: 32,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('entre 1 e 31')),
        (calculation) => fail('Should return failure'),
      );
    });

    // ========== CALCULATION TESTS ==========

    test('should calculate 50% overtime correctly (1.5x normal hour)', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 10.0,
        workDaysMonth: 22,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.hour50Value, calculation.normalHourValue * 1.5);
        },
      );
    });

    test('should calculate 100% overtime correctly (2x normal hour)', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours100: 10.0,
        workDaysMonth: 22,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.hour100Value, calculation.normalHourValue * 2.0);
        },
      );
    });

    test('should calculate vacation reflection correctly (1/3)', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 12.0,
        workDaysMonth: 22,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final expected = calculation.totalOvertime / 3;
          expect(calculation.vacationReflection, closeTo(expected, 0.01));
        },
      );
    });

    test('should calculate 13th reflection correctly (1/12)', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 12.0,
        workDaysMonth: 22,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final expected = calculation.totalOvertime / 12;
          expect(calculation.thirteenthReflection, closeTo(expected, 0.01));
        },
      );
    });

    test('should reduce IRRF with dependents', () async {
      // Arrange
      final paramsWithoutDependents = CalculateOvertimeParams(
        grossSalary: 5000.00,
        weeklyHours: 44,
        hours50: 20.0,
        dependents: 0,
      );

      final paramsWithDependents = CalculateOvertimeParams(
        grossSalary: 5000.00,
        weeklyHours: 44,
        hours50: 20.0,
        dependents: 2,
      );

      // Act
      final resultWithout = await useCase(paramsWithoutDependents);
      final resultWith = await useCase(paramsWithDependents);

      // Assert
      late double irrfWithout;
      late double irrfWith;

      resultWithout.fold(
        (failure) => fail('Should not return failure'),
        (calculation) => irrfWithout = calculation.irrfDiscount,
      );

      resultWith.fold(
        (failure) => fail('Should not return failure'),
        (calculation) => irrfWith = calculation.irrfDiscount,
      );

      expect(irrfWith, lessThan(irrfWithout));
    });

    // ========== METADATA ==========

    test('should generate unique ID for each calculation', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 10.0,
      );

      // Act
      final result1 = await useCase(params);
      final result2 = await useCase(params);

      // Assert
      late String id1;
      late String id2;

      result1.fold(
        (failure) => fail('Should not return failure'),
        (calculation) => id1 = calculation.id,
      );

      result2.fold(
        (failure) => fail('Should not return failure'),
        (calculation) => id2 = calculation.id,
      );

      expect(id1, isNot(equals(id2)));
    });

    test('should set calculatedAt timestamp', () async {
      // Arrange
      final params = CalculateOvertimeParams(
        grossSalary: 3000.00,
        weeklyHours: 44,
        hours50: 10.0,
      );

      final beforeCalculation = DateTime.now();

      // Act
      final result = await useCase(params);

      final afterCalculation = DateTime.now();

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.calculatedAt, isNotNull);
          expect(
            calculation.calculatedAt.isAfter(beforeCalculation) ||
                calculation.calculatedAt.isAtSameMomentAs(beforeCalculation),
            true,
          );
          expect(
            calculation.calculatedAt.isBefore(afterCalculation) ||
                calculation.calculatedAt.isAtSameMomentAs(afterCalculation),
            true,
          );
        },
      );
    });
  });
}
