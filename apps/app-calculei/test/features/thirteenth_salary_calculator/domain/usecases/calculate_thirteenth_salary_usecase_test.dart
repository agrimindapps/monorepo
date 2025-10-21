// Package imports:
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:app_calculei/features/thirteenth_salary_calculator/domain/entities/thirteenth_salary_calculation.dart';
import 'package:app_calculei/features/thirteenth_salary_calculator/domain/usecases/calculate_thirteenth_salary_usecase.dart';

void main() {
  late CalculateThirteenthSalaryUseCase useCase;

  setUp(() {
    useCase = CalculateThirteenthSalaryUseCase();
  });

  group('CalculateThirteenthSalaryUseCase -', () {
    // ==================== SUCCESS SCENARIOS ====================

    test('should calculate 13th salary successfully with valid data', () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
        unjustifiedAbsences: 0,
        isAdvancePayment: false,
        dependents: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.grossSalary, 3000.00);
          expect(calculation.monthsWorked, 12);
          expect(calculation.consideredMonths, 12);
          expect(calculation.valuePerMonth, 250.00); // 3000 / 12
          expect(calculation.grossThirteenthSalary, 3000.00); // 250 * 12
          expect(calculation.netThirteenthSalary, greaterThan(0));
          expect(calculation.id, isNotEmpty);
          expect(calculation.calculatedAt, isNotNull);
        },
      );
    });

    test('should calculate correctly with 6 months worked (mid-year hiring)',
        () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 2400.00,
        monthsWorked: 6,
        admissionDate: DateTime(2023, 7, 1),
        calculationDate: DateTime(2023, 12, 1),
        unjustifiedAbsences: 0,
        isAdvancePayment: false,
        dependents: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.monthsWorked, 6);
          expect(calculation.consideredMonths, 6);
          expect(calculation.valuePerMonth, 200.00); // 2400 / 12
          expect(calculation.grossThirteenthSalary, 1200.00); // 200 * 6
        },
      );
    });

    test(
        'should calculate correctly with advance payment (2 installments)',
        () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 4000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
        unjustifiedAbsences: 0,
        isAdvancePayment: true,
        dependents: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.isAdvancePayment, true);
          expect(calculation.firstInstallment, 2000.00); // 50% of gross (4000)
          expect(calculation.secondInstallment, greaterThan(0));
          expect(
            calculation.firstInstallment + calculation.secondInstallment,
            greaterThan(calculation.netThirteenthSalary - 100),
          ); // Allow small margin
        },
      );
    });

    // ==================== VALIDATION FAILURES ====================

    test('should return ValidationFailure when salary is zero', () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 0,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('maior que zero'));
        },
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when salary is negative', () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: -1500.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('maior que zero'));
        },
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when months worked is zero',
        () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 0,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('entre 1 e 12'));
        },
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when months worked exceeds 12',
        () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 13,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('entre 1 e 12'));
        },
        (calculation) => fail('Should return failure'),
      );
    });

    test(
        'should return ValidationFailure when unjustified absences is negative',
        () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
        unjustifiedAbsences: -5,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('não podem ser negativas'));
        },
        (calculation) => fail('Should return failure'),
      );
    });

    test(
        'should return ValidationFailure when calculation date is before admission date',
        () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 12, 1),
        calculationDate: DateTime(2023, 1, 1), // Before admission!
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('anterior à data de admissão'));
        },
        (calculation) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when dependents is negative',
        () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
        dependents: -2,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('não pode ser negativo'));
        },
        (calculation) => fail('Should return failure'),
      );
    });

    // ==================== ABSENCE DISCOUNTS ====================

    test('should discount 1 month for 15 unjustified absences', () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
        unjustifiedAbsences: 15,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.monthsWorked, 12);
          expect(calculation.consideredMonths, 11); // 12 - 1 (15 absences)
          expect(calculation.unjustifiedAbsences, 15);
        },
      );
    });

    test('should discount 2 months for 30 unjustified absences', () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
        unjustifiedAbsences: 30,
      );

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.monthsWorked, 12);
          expect(calculation.consideredMonths, 10); // 12 - 2 (30 absences)
        },
      );
    });

    // ==================== DEPENDENT DEDUCTIONS ====================

    test('should reduce IRRF with dependents', () async {
      // Arrange
      final paramsWithoutDependents = CalculateThirteenthSalaryParams(
        grossSalary: 5000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
        dependents: 0,
      );

      final paramsWithDependents = CalculateThirteenthSalaryParams(
        grossSalary: 5000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
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

      // IRRF with dependents should be lower
      expect(irrfWith, lessThan(irrfWithout));
    });

    // ==================== METADATA ====================

    test('should generate unique ID for each calculation', () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
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
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
    });

    test('should set calculatedAt timestamp', () async {
      // Arrange
      final params = CalculateThirteenthSalaryParams(
        grossSalary: 3000.00,
        monthsWorked: 12,
        admissionDate: DateTime(2023, 1, 1),
        calculationDate: DateTime(2023, 12, 1),
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
