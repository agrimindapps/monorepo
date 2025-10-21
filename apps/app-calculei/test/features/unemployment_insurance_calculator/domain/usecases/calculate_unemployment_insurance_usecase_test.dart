import 'package:app_calculei/features/unemployment_insurance_calculator/domain/usecases/calculate_unemployment_insurance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculateUnemploymentInsuranceUseCase useCase;

  setUp(() {
    useCase = CalculateUnemploymentInsuranceUseCase();
  });

  group('CalculateUnemploymentInsuranceUseCase - Success Cases (Eligible)', () {
    test('should calculate unemployment insurance for first time receiver with 12-23 months', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 18,
        timesReceived: 0,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.eligible, true);
          expect(calculation.numberOfInstallments, 4); // 12-23 months = 4 installments
          expect(calculation.installmentValue, greaterThan(0));
          expect(calculation.totalValue, greaterThan(0));
          expect(calculation.paymentSchedule.length, 4);
          expect(calculation.ineligibilityReason, '');
        },
      );
    });

    test('should calculate unemployment insurance for first time receiver with 24+ months', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 3000.00,
        workMonths: 30,
        timesReceived: 0,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.eligible, true);
          expect(calculation.numberOfInstallments, 5); // 24+ months = 5 installments
        },
      );
    });

    test('should calculate unemployment insurance for second time receiver', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2500.00,
        workMonths: 15,
        timesReceived: 1,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.eligible, true);
          expect(calculation.numberOfInstallments, 3); // 1st time + 9-23 months = 3 installments
        },
      );
    });

    test('should calculate correct installment value for low salary', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 1500.00,
        workMonths: 12,
        timesReceived: 0,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // 1500 * 0.8 = 1200, but minimum is 1412
          expect(calculation.installmentValue, equals(1412.00));
        },
      );
    });

    test('should calculate correct installment value for medium salary', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2500.00,
        workMonths: 12,
        timesReceived: 0,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // 2500 * 0.5 + 1574.69 = 2824.69, but limited to maximum 2230.97
          expect(calculation.installmentValue, equals(2230.97));
        },
      );
    });

    test('should calculate correct installment value for high salary', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 5000.00,
        workMonths: 12,
        timesReceived: 0,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Above 3280.94 = fixed 2230.97 (maximum)
          expect(calculation.installmentValue, equals(2230.97));
        },
      );
    });

    test('should create payment schedule with correct dates', () async {
      // Arrange
      final dismissalDate = DateTime(2024, 1, 15);
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        timesReceived: 0,
        dismissalDate: dismissalDate,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.paymentSchedule.length, 4);
          // First payment should be ~30 days after dismissal
          expect(calculation.paymentStart, dismissalDate.add(const Duration(days: 30)));
          // Payments should be 30 days apart
          expect(
            calculation.paymentSchedule[1].difference(calculation.paymentSchedule[0]).inDays,
            equals(30),
          );
        },
      );
    });
  });

  group('CalculateUnemploymentInsuranceUseCase - Ineligibility Cases', () {
    test('should mark as ineligible when work months insufficient for first time', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 10, // Less than required 12 months
        timesReceived: 0,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.eligible, false);
          expect(calculation.numberOfInstallments, 0);
          expect(calculation.installmentValue, 0.0);
          expect(calculation.totalValue, 0.0);
          expect(calculation.ineligibilityReason, contains('Tempo de trabalho insuficiente'));
          expect(calculation.requiredCarencyMonths, 12);
        },
      );
    });

    test('should mark as ineligible when work months insufficient for second time', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 7, // Less than required 9 months
        timesReceived: 1,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.eligible, false);
          expect(calculation.requiredCarencyMonths, 9);
        },
      );
    });

    test('should mark as ineligible when work months insufficient for third+ time', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 4, // Less than required 6 months
        timesReceived: 2,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.eligible, false);
          expect(calculation.requiredCarencyMonths, 6);
        },
      );
    });
  });

  group('CalculateUnemploymentInsuranceUseCase - Validation Failures', () {
    test('should return failure when average salary is zero', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 0.0,
        workMonths: 12,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when average salary is negative', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: -1000.00,
        workMonths: 12,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when work months is negative', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: -12,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when times received is negative', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        timesReceived: -1,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when dismissal date is in the future', () async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        dismissalDate: futureDate,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('CalculateUnemploymentInsuranceUseCase - Calculation Verifications', () {
    test('should calculate total value correctly', () async {
      // Arrange
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        timesReceived: 0,
        dismissalDate: DateTime(2024, 1, 15),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final expectedTotal = calculation.installmentValue * calculation.numberOfInstallments;
          expect(calculation.totalValue, equals(expectedTotal));
        },
      );
    });

    test('should set deadline to request correctly (120 days from dismissal)', () async {
      // Arrange
      final dismissalDate = DateTime(2024, 1, 15);
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        dismissalDate: dismissalDate,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          final expectedDeadline = dismissalDate.add(const Duration(days: 120));
          expect(calculation.deadlineToRequest, equals(expectedDeadline));
        },
      );
    });

    test('should calculate payment end date correctly', () async {
      // Arrange
      final dismissalDate = DateTime(2024, 1, 15);
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        dismissalDate: dismissalDate,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          // Payment end should be start + (installments - 1) * 30 days
          final expectedEnd = calculation.paymentStart.add(
            Duration(days: (calculation.numberOfInstallments - 1) * 30),
          );
          expect(calculation.paymentEnd, equals(expectedEnd));
        },
      );
    });
  });

  group('CalculateUnemploymentInsuranceUseCase - Metadata', () {
    test('should generate unique IDs for different calculations', () async {
      // Arrange
      final params1 = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        dismissalDate: DateTime(2024, 1, 15),
      );
      final params2 = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        dismissalDate: DateTime(2024, 1, 15),
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
      final params = CalculateUnemploymentInsuranceParams(
        averageSalary: 2000.00,
        workMonths: 12,
        dismissalDate: DateTime(2024, 1, 15),
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
