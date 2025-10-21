import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/features/net_salary_calculator/domain/usecases/calculate_net_salary_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculateNetSalaryUseCase useCase;

  setUp(() {
    useCase = CalculateNetSalaryUseCase();
  });

  group('CalculateNetSalaryUseCase - Success Cases', () {
    test('should calculate net salary successfully with minimum wage', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 1412.00, // Minimum wage 2024
        dependents: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.grossSalary, 1412.00);
          expect(calculation.dependents, 0);
          expect(calculation.inssDiscount, greaterThan(0));
          expect(calculation.netSalary, lessThan(calculation.grossSalary));
          expect(calculation.netSalary, greaterThan(0));
        },
      );
    });

    test('should calculate net salary with dependents and discounts', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 5000.00,
        dependents: 2,
        transportationVoucher: 200.00,
        healthInsurance: 150.00,
        otherDiscounts: 50.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.grossSalary, 5000.00);
          expect(calculation.dependents, 2);
          expect(calculation.transportationVoucher, 200.00);
          expect(calculation.healthInsurance, 150.00);
          expect(calculation.otherDiscounts, 50.00);
          expect(calculation.inssDiscount, greaterThan(0));
          expect(calculation.totalDiscounts, greaterThan(0));
          expect(calculation.netSalary, lessThan(calculation.grossSalary));
        },
      );
    });

    test('should calculate net salary above INSS ceiling', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 10000.00, // Above INSS ceiling
        dependents: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final maxInssDiscount = CalculationConstants.tetoInss * 0.14;
          expect(calculation.inssDiscount, lessThanOrEqualTo(maxInssDiscount));
          expect(calculation.irrfDiscount, greaterThan(0)); // Should have IRRF
        },
      );
    });
  });

  group('CalculateNetSalaryUseCase - Validation Failures', () {
    test('should return failure when gross salary is zero', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 0.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when gross salary is negative', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: -1000.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when dependents is negative', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        dependents: -1,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when dependents exceeds maximum', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        dependents: CalculationConstants.maxDependentes + 1,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when transportation voucher is negative', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        transportationVoucher: -50.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when health insurance is negative', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        healthInsurance: -100.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when other discounts is negative', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        otherDiscounts: -25.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when voluntary discounts exceed gross salary', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        transportationVoucher: 1500.00,
        healthInsurance: 1000.00,
        otherDiscounts: 500.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('CalculateNetSalaryUseCase - Calculation Verifications', () {
    test('should apply INSS progressive rates correctly', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.inssDiscount, greaterThan(0));
          expect(calculation.inssRate, greaterThan(0));
          expect(calculation.inssRate, lessThanOrEqualTo(0.14));
        },
      );
    });

    test('should reduce IRRF with dependents deduction', () async {
      // Arrange
      final paramsWithoutDependents = CalculateNetSalaryParams(
        grossSalary: 5000.00,
        dependents: 0,
      );
      final paramsWithDependents = CalculateNetSalaryParams(
        grossSalary: 5000.00,
        dependents: 2,
      );

      // Act
      final resultWithout = await useCase(paramsWithoutDependents);
      final resultWith = await useCase(paramsWithDependents);

      // Assert
      expect(resultWithout.isRight(), true);
      expect(resultWith.isRight(), true);

      final calculationWithout = resultWithout.getOrElse(() => throw Exception());
      final calculationWith = resultWith.getOrElse(() => throw Exception());

      // IRRF should be lower with dependents
      expect(
        calculationWith.irrfDiscount,
        lessThanOrEqualTo(calculationWithout.irrfDiscount),
      );
    });

    test('should limit transportation voucher to 6% of gross salary', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        transportationVoucher: 500.00, // Above 6% limit (180)
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final maxDiscount = 3000.00 * CalculationConstants.percentualValeTransporte;
          expect(calculation.transportationVoucherDiscount, equals(maxDiscount));
          expect(calculation.transportationVoucherDiscount, lessThan(500.00));
        },
      );
    });

    test('should not discount transportation voucher if not provided', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 3000.00,
        transportationVoucher: 0.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.transportationVoucherDiscount, equals(0.0));
        },
      );
    });

    test('should include all discounts in total', () async {
      // Arrange
      final params = CalculateNetSalaryParams(
        grossSalary: 5000.00,
        dependents: 1,
        transportationVoucher: 200.00,
        healthInsurance: 150.00,
        otherDiscounts: 50.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final calculatedTotal = calculation.inssDiscount +
                                 calculation.irrfDiscount +
                                 calculation.transportationVoucherDiscount +
                                 calculation.healthInsurance +
                                 calculation.otherDiscounts;
          expect(calculation.totalDiscounts, equals(calculatedTotal));
        },
      );
    });
  });

  group('CalculateNetSalaryUseCase - Metadata', () {
    test('should generate unique IDs for different calculations', () async {
      // Arrange
      final params1 = CalculateNetSalaryParams(grossSalary: 3000.00);
      final params2 = CalculateNetSalaryParams(grossSalary: 3000.00);

      // Act
      final result1 = await useCase(params1);
      final result2 = await useCase(params2);

      // Assert
      final calc1 = result1.getOrElse(() => throw Exception());
      final calc2 = result2.getOrElse(() => throw Exception());
      expect(calc1.id, isNot(equals(calc2.id)));
    });

    test('should set calculation timestamp', () async {
      // Arrange
      final before = DateTime.now();
      final params = CalculateNetSalaryParams(grossSalary: 3000.00);

      // Act
      final result = await useCase(params);
      final after = DateTime.now();

      // Assert
      final calculation = result.getOrElse(() => throw Exception());
      expect(calculation.calculatedAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(calculation.calculatedAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });
  });
}
