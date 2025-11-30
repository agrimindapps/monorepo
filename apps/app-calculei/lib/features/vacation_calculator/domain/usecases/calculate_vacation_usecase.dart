import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/vacation_calculation.dart';

/// Parameters for vacation calculation
class CalculateVacationParams {
  final double grossSalary;
  final int vacationDays;
  final bool sellVacationDays;

  const CalculateVacationParams({
    required this.grossSalary,
    required this.vacationDays,
    this.sellVacationDays = false,
  });
}

/// Use case for calculating vacation pay
///
/// Handles all business logic for vacation calculation including:
/// - Input validation
/// - Base value calculation
/// - Constitutional 1/3 bonus
/// - Sold vacation days (abono pecuniário)
/// - INSS and IR tax calculations
class CalculateVacationUseCase {
  const CalculateVacationUseCase();

  Future<Either<Failure, VacationCalculation>> call(
    CalculateVacationParams params,
  ) async {
    // 1. VALIDATION
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      // 2. CALCULATION
      final calculation = _performCalculation(params);

      return Right(calculation);
    } catch (e) {
      return Left(ValidationFailure('Erro no cálculo: $e'));
    }
  }

  /// Validate input parameters
  ValidationFailure? _validate(CalculateVacationParams params) {
    if (params.grossSalary <= 0) {
      return const ValidationFailure(
        'Salário bruto deve ser maior que zero',
      );
    }

    if (params.grossSalary > 1000000) {
      return const ValidationFailure(
        'Salário bruto não pode ser maior que R\$ 1.000.000',
      );
    }

    if (params.vacationDays < 1 || params.vacationDays > 30) {
      return const ValidationFailure(
        'Dias de férias devem estar entre 1 e 30',
      );
    }

    if (params.sellVacationDays && params.vacationDays < 10) {
      return const ValidationFailure(
        'Para vender dias, você precisa ter pelo menos 10 dias de férias',
      );
    }

    return null;
  }

  /// Perform the actual vacation calculation
  VacationCalculation _performCalculation(CalculateVacationParams params) {
    // Base vacation value (proportional to days)
    final baseValue = (params.grossSalary / 30) * params.vacationDays;

    // Constitutional 1/3 bonus
    final constitutionalBonus = baseValue / 3;

    // Sold vacation days value (if applicable - max 10 days)
    double soldDaysValue = 0;
    if (params.sellVacationDays) {
      final soldDays = (params.vacationDays / 3).floor().clamp(0, 10);
      soldDaysValue = (params.grossSalary / 30) * soldDays;
      soldDaysValue += soldDaysValue / 3; // +1/3 on sold days too
    }

    // Gross total
    final grossTotal = baseValue + constitutionalBonus + soldDaysValue;

    // Calculate INSS (2024 table)
    final inssDiscount = _calculateInss(grossTotal);

    // Calculate IR (2024 table) - base after INSS
    final irDiscount = _calculateIR(grossTotal - inssDiscount);

    // Net total
    final netTotal = grossTotal - inssDiscount - irDiscount;

    return VacationCalculation(
      id: const Uuid().v4(),
      grossSalary: params.grossSalary,
      vacationDays: params.vacationDays,
      sellVacationDays: params.sellVacationDays,
      baseValue: baseValue,
      constitutionalBonus: constitutionalBonus,
      soldDaysValue: soldDaysValue,
      grossTotal: grossTotal,
      inssDiscount: inssDiscount,
      irDiscount: irDiscount,
      netTotal: netTotal,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate INSS discount (2024 progressive table)
  double _calculateInss(double value) {
    // INSS 2024 brackets
    const brackets = [
      (limit: 1412.00, rate: 0.075),
      (limit: 2666.68, rate: 0.09),
      (limit: 4000.03, rate: 0.12),
      (limit: 7786.02, rate: 0.14),
    ];

    var discount = 0.0;
    var previousLimit = 0.0;

    for (final bracket in brackets) {
      if (value <= previousLimit) break;

      final taxableAmount =
          (value > bracket.limit ? bracket.limit : value) - previousLimit;
      discount += taxableAmount * bracket.rate;
      previousLimit = bracket.limit;
    }

    return discount;
  }

  /// Calculate IR discount (2024 progressive table)
  double _calculateIR(double value) {
    // IR 2024 brackets (after INSS)
    if (value <= 2259.20) return 0.0;
    if (value <= 2826.65) return value * 0.075 - 169.44;
    if (value <= 3751.05) return value * 0.15 - 381.44;
    if (value <= 4664.68) return value * 0.225 - 662.77;
    return value * 0.275 - 896.00;
  }
}
