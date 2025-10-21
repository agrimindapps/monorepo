import 'package:app_calculei/features/vacation_calculator/domain/usecases/calculate_vacation_usecase.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculateVacationUseCase useCase;

  setUp(() {
    useCase = const CalculateVacationUseCase();
  });

  group('CalculateVacationUseCase -', () {
    test('should calculate vacation successfully with valid data', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000.0,
        vacationDays: 30,
        sellVacationDays: false,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.grossSalary, 3000.0);
          expect(calculation.vacationDays, 30);
          expect(calculation.sellVacationDays, false);
          expect(calculation.baseValue, 3000.0); // Full month
          expect(calculation.constitutionalBonus, 1000.0); // 1/3 of base
          expect(calculation.soldDaysValue, 0.0); // No sold days
          expect(calculation.grossTotal, 4000.0); // Base + bonus
          expect(calculation.inssDiscount, greaterThan(0));
          expect(calculation.netTotal, lessThan(calculation.grossTotal));
        },
      );
    });

    test('should calculate with sold vacation days', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000.0,
        vacationDays: 30,
        sellVacationDays: true,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.sellVacationDays, true);
          expect(calculation.soldDaysValue, greaterThan(0));
          // Sold days = 10 days (1/3 of 30) + 1/3 bonus
          // = (3000/30 * 10) + (1000/3) = 1000 + 333.33 = 1333.33
          expect(calculation.soldDaysValue, closeTo(1333.33, 0.01));
        },
      );
    });

    test('should calculate proportional vacation for partial days', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000.0,
        vacationDays: 15,
        sellVacationDays: false,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.vacationDays, 15);
          expect(calculation.baseValue, 1500.0); // (3000/30) * 15
          expect(calculation.constitutionalBonus, 500.0); // 1/3 of 1500
          expect(calculation.grossTotal, 2000.0);
        },
      );
    });

    test('should return ValidationFailure when salary is zero', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 0,
        vacationDays: 30,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Salário bruto deve ser maior que zero');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when salary is negative', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: -1000,
        vacationDays: 30,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Salário bruto deve ser maior que zero');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when salary exceeds limit', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 1500000,
        vacationDays: 30,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Salário bruto não pode ser maior que R\$ 1.000.000',
          );
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when vacation days is zero',
        () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000,
        vacationDays: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Dias de férias devem estar entre 1 e 30');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when vacation days exceeds 30',
        () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000,
        vacationDays: 31,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Dias de férias devem estar entre 1 e 30');
        },
        (_) => fail('Should not return success'),
      );
    });

    test(
        'should return ValidationFailure when selling days with less than 10 days',
        () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000,
        vacationDays: 9,
        sellVacationDays: true,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Para vender dias, você precisa ter pelo menos 10 dias de férias',
          );
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should calculate INSS correctly for low salary', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 1200.0,
        vacationDays: 30,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Gross total = 1200 + 400 (1/3) = 1600
          // INSS should be calculated on progressive table
          expect(calculation.inssDiscount, greaterThan(0));
          expect(calculation.inssDiscount, lessThan(calculation.grossTotal));
        },
      );
    });

    test('should calculate IR correctly for taxable income', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 5000.0,
        vacationDays: 30,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Higher salary should have IR discount
          expect(calculation.irDiscount, greaterThan(0));
          // Net total should equal gross - INSS - IR
          expect(
            calculation.netTotal,
            calculation.grossTotal -
                calculation.inssDiscount -
                calculation.irDiscount,
          );
        },
      );
    });

    test('should not apply IR for low taxable income', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 1000.0,
        vacationDays: 30,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Low salary should have no IR (after INSS deduction)
          expect(calculation.irDiscount, 0.0);
        },
      );
    });

    test('should generate unique ID for each calculation', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000,
        vacationDays: 30,
      );

      // Act
      final result1 = await useCase(params);
      final result2 = await useCase(params);

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      final id1 = result1.getOrElse(() => throw Exception());
      final id2 = result2.getOrElse(() => throw Exception());

      expect(id1.id, isNot(id2.id));
    });

    test('should set calculatedAt timestamp', () async {
      // Arrange
      const params = CalculateVacationParams(
        grossSalary: 3000,
        vacationDays: 30,
      );
      final beforeCalculation = DateTime.now();

      // Act
      final result = await useCase(params);
      final afterCalculation = DateTime.now();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
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
