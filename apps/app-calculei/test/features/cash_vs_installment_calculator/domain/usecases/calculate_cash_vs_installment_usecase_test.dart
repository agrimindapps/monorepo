import 'package:app_calculei/features/cash_vs_installment_calculator/domain/usecases/calculate_cash_vs_installment_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculateCashVsInstallmentUseCase useCase;

  setUp(() {
    useCase = CalculateCashVsInstallmentUseCase();
  });

  group('CalculateCashVsInstallmentUseCase - Success Cases', () {
    test('should calculate cash vs installment with installment being better', () async {
      // Arrange - High interest rate makes cash better, but let's test vice versa
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1200.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
        monthlyInterestRate: 0.0, // No opportunity cost
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.cashPrice, 1200.00);
          expect(calculation.installmentPrice, 100.00);
          expect(calculation.numberOfInstallments, 12);
          expect(calculation.totalInstallmentPrice, 1200.00); // 100 * 12
          expect(calculation.presentValueOfInstallments, 1200.00); // No interest
          // With no interest, both options are equal
        },
      );
    });

    test('should calculate with cash being better option due to low interest rate', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
        monthlyInterestRate: 2.0, // 2% per month
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.cashPrice, 1000.00);
          expect(calculation.totalInstallmentPrice, 1200.00);
          // With 2% monthly rate, PV will be higher than cash price (making cash better)
          expect(calculation.presentValueOfInstallments, greaterThan(calculation.cashPrice));
          expect(calculation.bestOption, 'À Vista');
          expect(calculation.savingsOrAdditionalCost, greaterThan(0));
        },
      );
    });

    test('should calculate implicit rate correctly', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
        monthlyInterestRate: 1.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Total = 1200, Cash = 1000
          // Implicit rate should be positive
          expect(calculation.implicitRate, greaterThan(0));
          expect(calculation.implicitRate, lessThan(0.2)); // Reasonable rate
        },
      );
    });

    test('should handle zero interest rate correctly', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1500.00,
        installmentPrice: 125.00,
        numberOfInstallments: 12,
        monthlyInterestRate: 0.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.presentValueOfInstallments, equals(1500.00));
          expect(calculation.totalInstallmentPrice, equals(1500.00));
        },
      );
    });
  });

  group('CalculateCashVsInstallmentUseCase - Validation Failures', () {
    test('should return failure when cash price is zero', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 0.0,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when cash price is negative', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: -1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when cash price exceeds maximum', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 10000001.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when installment price is zero', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 0.0,
        numberOfInstallments: 12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when installment price is negative', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: -100.00,
        numberOfInstallments: 12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when number of installments is zero', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when number of installments is negative', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: -12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when number of installments exceeds maximum', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 361,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when interest rate is negative', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
        monthlyInterestRate: -1.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when interest rate exceeds maximum', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
        monthlyInterestRate: 21.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('CalculateCashVsInstallmentUseCase - Calculation Verifications', () {
    test('should calculate total installment price correctly', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 150.00,
        numberOfInstallments: 10,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.totalInstallmentPrice, equals(1500.00)); // 150 * 10
        },
      );
    });

    test('should calculate present value with discount factor', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
        monthlyInterestRate: 1.0, // 1% per month
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Present value should be less than total due to discounting
          expect(calculation.presentValueOfInstallments, lessThan(1200.00));
          expect(calculation.presentValueOfInstallments, greaterThan(1000.00));
        },
      );
    });

    test('should determine best option correctly when cash is better', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 900.00,
        installmentPrice: 100.00,
        numberOfInstallments: 10,
        monthlyInterestRate: 0.5,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // PV of installments should be close to 1000, cash is 900
          expect(calculation.bestOption, 'À Vista');
          expect(calculation.savingsOrAdditionalCost, greaterThan(0));
        },
      );
    });

    test('should handle implicit rate when installment is cheaper', () async {
      // Arrange
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1200.00,
        installmentPrice: 95.00,
        numberOfInstallments: 12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Total = 1140, Cash = 1200
          // Implicit rate should be negative (discount)
          expect(calculation.implicitRate, lessThan(0));
        },
      );
    });

    test('should constrain implicit rate to reasonable bounds', () async {
      // Arrange - Extreme values
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 100.00,
        installmentPrice: 10.00,
        numberOfInstallments: 24,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Total = 240, Cash = 100
          // Rate should be constrained to max 100%
          expect(calculation.implicitRate, lessThanOrEqualTo(1.0));
          expect(calculation.implicitRate, greaterThanOrEqualTo(-0.5));
        },
      );
    });
  });

  group('CalculateCashVsInstallmentUseCase - Metadata', () {
    test('should generate unique IDs for different calculations', () async {
      // Arrange
      final params1 = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
      );
      final params2 = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
      );

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
      final params = CalculateCashVsInstallmentParams(
        cashPrice: 1000.00,
        installmentPrice: 100.00,
        numberOfInstallments: 12,
      );

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
