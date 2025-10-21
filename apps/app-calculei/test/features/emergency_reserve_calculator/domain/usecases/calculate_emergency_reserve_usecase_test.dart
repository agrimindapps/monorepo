import 'package:app_calculei/features/emergency_reserve_calculator/domain/usecases/calculate_emergency_reserve_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculateEmergencyReserveUseCase useCase;

  setUp(() {
    useCase = CalculateEmergencyReserveUseCase();
  });

  group('CalculateEmergencyReserveUseCase - Success Cases', () {
    test('should calculate emergency reserve with minimum inputs', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.monthlyExpenses, 3000.00);
          expect(calculation.extraExpenses, 0.0);
          expect(calculation.desiredMonths, 6);
          expect(calculation.totalMonthlyExpenses, 3000.00);
          expect(calculation.totalReserveAmount, 18000.00); // 3000 * 6
          expect(calculation.category, 'Confortável');
        },
      );
    });

    test('should calculate emergency reserve with extra expenses', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        extraExpenses: 500.00,
        desiredMonths: 12,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.monthlyExpenses, 3000.00);
          expect(calculation.extraExpenses, 500.00);
          expect(calculation.totalMonthlyExpenses, 3500.00);
          expect(calculation.totalReserveAmount, 42000.00); // 3500 * 12
          expect(calculation.category, 'Robusta');
        },
      );
    });

    test('should calculate construction time when monthly savings provided', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
        monthlySavings: 500.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.totalReserveAmount, 18000.00);
          expect(calculation.monthlySavings, 500.00);
          // 18000 / 500 = 36 months = 3 years
          expect(calculation.constructionYears, 3);
          expect(calculation.constructionMonths, 0);
        },
      );
    });

    test('should calculate construction time with years and months', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
        monthlySavings: 400.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.totalReserveAmount, 18000.00);
          // 18000 / 400 = 45 months = 3 years and 9 months
          expect(calculation.constructionYears, 3);
          expect(calculation.constructionMonths, 9);
        },
      );
    });

    test('should not calculate construction time when monthly savings too small', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
        monthlySavings: 10.00, // Less than 1% of total reserve
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.constructionYears, 0);
          expect(calculation.constructionMonths, 0);
        },
      );
    });
  });

  group('CalculateEmergencyReserveUseCase - Category Classification', () {
    test('should classify as "Mínima" for less than 3 months', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 2,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.category, 'Mínima');
          expect(calculation.categoryDescription, contains('emergências imediatas'));
        },
      );
    });

    test('should classify as "Básica" for 3-5 months', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 4,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.category, 'Básica');
          expect(calculation.categoryDescription, contains('emprego estável'));
        },
      );
    });

    test('should classify as "Confortável" for 6-11 months', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 8,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.category, 'Confortável');
          expect(calculation.categoryDescription, contains('autônomo'));
        },
      );
    });

    test('should classify as "Robusta" for 12+ months', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 24,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.category, 'Robusta');
          expect(calculation.categoryDescription, contains('longos períodos'));
        },
      );
    });
  });

  group('CalculateEmergencyReserveUseCase - Validation Failures', () {
    test('should return failure when monthly expenses is zero', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 0.0,
        desiredMonths: 6,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when monthly expenses is negative', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: -1000.00,
        desiredMonths: 6,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when monthly expenses exceeds maximum', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 1000001.00,
        desiredMonths: 6,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when extra expenses is negative', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        extraExpenses: -500.00,
        desiredMonths: 6,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when desired months is zero', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when desired months is negative', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: -6,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when desired months exceeds maximum', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 121,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return failure when monthly savings is negative', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
        monthlySavings: -500.00,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('CalculateEmergencyReserveUseCase - Calculation Verifications', () {
    test('should correctly sum monthly and extra expenses', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 2500.00,
        extraExpenses: 750.00,
        desiredMonths: 6,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.totalMonthlyExpenses, 3250.00);
          expect(calculation.totalReserveAmount, 19500.00); // 3250 * 6
        },
      );
    });

    test('should multiply total monthly expenses by desired months', () async {
      // Arrange
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 5000.00,
        extraExpenses: 1000.00,
        desiredMonths: 3,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (calculation) {
          expect(calculation.totalReserveAmount, 18000.00); // 6000 * 3
        },
      );
    });
  });

  group('CalculateEmergencyReserveUseCase - Metadata', () {
    test('should generate unique IDs for different calculations', () async {
      // Arrange
      final params1 = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
      );
      final params2 = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
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
      final params = CalculateEmergencyReserveParams(
        monthlyExpenses: 3000.00,
        desiredMonths: 6,
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
