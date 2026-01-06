import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/calculation_constants.dart';
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

    // Sold vacation days value (if applicable - max 1/3 of vacation days, up to 10)
    var soldDaysValue = 0.0;
    var soldDays = 0;
    if (params.sellVacationDays) {
      // Can sell up to 1/3 of vacation days, maximum 10 days
      soldDays = (params.vacationDays / 3).floor().clamp(1, 10);
      final dailyRate = params.grossSalary / 30;
      final soldDaysBase = dailyRate * soldDays;
      soldDaysValue = soldDaysBase + (soldDaysBase / 3); // Base + 1/3 constitutional bonus
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

  /// Calculate INSS discount using shared constants (2024 progressive table)
  double _calculateInss(double value) {
    var discount = 0.0;

    for (final bracket in CalculationConstants.faixasInss) {
      final min = bracket['min']!;
      final max = bracket['max']!;
      final rate = bracket['aliquota']!;

      if (value > min) {
        final calculationBase = value > max ? max : value;
        final bracketValue = calculationBase - min;
        discount += bracketValue * rate;
      }
    }

    // Apply INSS ceiling
    const maxInssDiscount = CalculationConstants.tetoInss * 0.14;
    if (discount > maxInssDiscount) {
      discount = maxInssDiscount;
    }

    return discount;
  }

  /// Calculate IR discount using shared constants (2024 progressive table)
  double _calculateIR(double value) {
    for (final bracket in CalculationConstants.faixasIrrf) {
      final min = bracket['min']!;
      final max = bracket['max']!;
      final rate = bracket['aliquota']!;
      final deduction = bracket['deducao']!;

      if (value >= min && value <= max) {
        final discount = (value * rate) - deduction;
        return discount > 0 ? discount : 0.0;
      }
    }

    return 0.0;
  }
}
