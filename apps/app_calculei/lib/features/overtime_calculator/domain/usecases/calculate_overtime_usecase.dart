// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import '../entities/overtime_calculation.dart';

/// Parameters for calculating overtime
class CalculateOvertimeParams {
  final double grossSalary;
  final int weeklyHours;
  final double hours50;
  final double hours100;
  final double nightHours;
  final double nightAdditionalPercentage;
  final double sundayHolidayHours;
  final int workDaysMonth;
  final int dependents;

  const CalculateOvertimeParams({
    required this.grossSalary,
    required this.weeklyHours,
    this.hours50 = 0,
    this.hours100 = 0,
    this.nightHours = 0,
    this.nightAdditionalPercentage = 20.0, // Default 20%
    this.sundayHolidayHours = 0,
    this.workDaysMonth = 22, // Default work days
    this.dependents = 0,
  });
}

/// Use case for calculating overtime (Horas Extras)
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for overtime calculation logic and validation
///
/// Business Rules:
/// 1. Normal hour value: salary / monthly hours
/// 2. 50% overtime: normal hour × 1.5
/// 3. 100% overtime: normal hour × 2.0
/// 4. Night shift: normal hour × (1 + night%)
/// 5. Sunday/holiday: normal hour × 2.0
/// 6. DSR: overtime total × 1/6
/// 7. Vacation reflection: overtime × 1/3
/// 8. 13th reflection: overtime × 1/12
/// 9. INSS/IRRF: progressive on gross total
@injectable
class CalculateOvertimeUseCase {
  static const _uuid = Uuid();

  /// Calculates overtime based on parameters
  Future<Either<Failure, OvertimeCalculation>> call(
    CalculateOvertimeParams params,
  ) async {
    // 1. VALIDATION
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    // 2. CALCULATION
    try {
      final calculation = _performCalculation(params);
      return Right(calculation);
    } catch (e) {
      return Left(ValidationFailure('Erro no cálculo de horas extras: $e'));
    }
  }

  /// Validates input parameters
  ValidationFailure? _validate(CalculateOvertimeParams params) {
    // Salary validation
    if (params.grossSalary <= 0) {
      return const ValidationFailure('Salário bruto deve ser maior que zero');
    }

    if (params.grossSalary > CalculationConstants.maxSalario) {
      return ValidationFailure(
        'Salário bruto não pode exceder R\$ ${CalculationConstants.maxSalario.toStringAsFixed(2)}',
      );
    }

    // Weekly hours validation
    if (params.weeklyHours <= 0) {
      return const ValidationFailure(
        'Horas semanais devem ser maior que zero',
      );
    }

    if (params.weeklyHours > CalculationConstants.maxHorasSemanais) {
      return ValidationFailure(
        'Horas semanais não podem exceder ${CalculationConstants.maxHorasSemanais}',
      );
    }

    // Overtime hours validation
    if (params.hours50 < 0 || params.hours100 < 0) {
      return const ValidationFailure('Horas extras não podem ser negativas');
    }

    final totalOvertime = params.hours50 + params.hours100;
    if (totalOvertime > CalculationConstants.maxHorasExtrasMes) {
      return ValidationFailure(
        'Total de horas extras não pode exceder ${CalculationConstants.maxHorasExtrasMes} por mês',
      );
    }

    // Night hours validation
    if (params.nightHours < 0) {
      return const ValidationFailure('Horas noturnas não podem ser negativas');
    }

    if (params.nightAdditionalPercentage < 0 ||
        params.nightAdditionalPercentage > 100) {
      return const ValidationFailure(
        'Percentual noturno deve estar entre 0% e 100%',
      );
    }

    // Sunday/holiday hours validation
    if (params.sundayHolidayHours < 0) {
      return const ValidationFailure(
        'Horas de domingo/feriado não podem ser negativas',
      );
    }

    // Work days validation
    if (params.workDaysMonth <= 0 || params.workDaysMonth > 31) {
      return const ValidationFailure(
        'Dias úteis devem estar entre 1 e 31',
      );
    }

    // Dependents validation
    if (params.dependents < 0) {
      return const ValidationFailure(
        'Número de dependentes não pode ser negativo',
      );
    }

    if (params.dependents > CalculationConstants.maxDependentes) {
      return ValidationFailure(
        'Número de dependentes não pode exceder ${CalculationConstants.maxDependentes}',
      );
    }

    return null;
  }

  /// Performs the overtime calculation
  OvertimeCalculation _performCalculation(CalculateOvertimeParams params) {
    // 1. Calculate monthly worked hours
    final monthlyWorkedHours = (params.weeklyHours * params.workDaysMonth) /
        CalculationConstants.diasTrabalhoSemana;

    // 2. Calculate normal hour value
    final normalHourValue = params.grossSalary / monthlyWorkedHours;

    // 3. Calculate hour values
    final hour50Value =
        normalHourValue * (1 + CalculationConstants.percentualHorasExtras50);
    final hour100Value =
        normalHourValue * (1 + CalculationConstants.percentualHorasExtras100);
    final nightHourValue =
        normalHourValue * (1 + params.nightAdditionalPercentage / 100);
    final sundayHolidayHourValue =
        normalHourValue * (1 + CalculationConstants.percentualDomingoFeriado);

    // 4. Calculate totals
    final total50 = params.hours50 * hour50Value;
    final total100 = params.hours100 * hour100Value;
    final totalNightAdditional = params.nightHours * nightHourValue;
    final totalSundayHoliday = params.sundayHolidayHours * sundayHolidayHourValue;

    // 5. Calculate total overtime (50% + 100%)
    final totalOvertimeHours = params.hours50 + params.hours100;
    final totalOvertime = total50 + total100;

    // 6. Calculate DSR over overtime
    final dsrOvertime = totalOvertime * CalculationConstants.percentualDsr;

    // 7. Calculate reflections
    final vacationReflection =
        totalOvertime * CalculationConstants.percentualReflexoFerias;
    final thirteenthReflection =
        totalOvertime * CalculationConstants.percentualReflexoDecimoTerceiro;

    // 8. Calculate gross total
    final grossTotal = params.grossSalary +
        totalOvertime +
        totalNightAdditional +
        totalSundayHoliday +
        dsrOvertime +
        vacationReflection +
        thirteenthReflection;

    // 9. Calculate INSS
    final inssResult = _calculateInss(grossTotal);
    final inssDiscount = inssResult['desconto']!;
    final inssRate = inssResult['aliquota']!;

    // 10. Calculate IRRF
    final irrfBaseCalculation = grossTotal - inssDiscount;
    final irrfResult = _calculateIrrf(irrfBaseCalculation, params.dependents);
    final irrfDiscount = irrfResult['desconto']!;
    final irrfRate = irrfResult['aliquota']!;

    // 11. Calculate net total
    final netTotal = grossTotal - inssDiscount - irrfDiscount;

    return OvertimeCalculation(
      // Inputs
      grossSalary: params.grossSalary,
      weeklyHours: params.weeklyHours,
      hours50: params.hours50,
      hours100: params.hours100,
      nightHours: params.nightHours,
      nightAdditionalPercentage: params.nightAdditionalPercentage,
      sundayHolidayHours: params.sundayHolidayHours,
      workDaysMonth: params.workDaysMonth,
      dependents: params.dependents,
      // Results
      monthlyWorkedHours: monthlyWorkedHours,
      normalHourValue: normalHourValue,
      hour50Value: hour50Value,
      hour100Value: hour100Value,
      nightHourValue: nightHourValue,
      sundayHolidayHourValue: sundayHolidayHourValue,
      total50: total50,
      total100: total100,
      totalNightAdditional: totalNightAdditional,
      totalSundayHoliday: totalSundayHoliday,
      dsrOvertime: dsrOvertime,
      totalOvertime: totalOvertime,
      vacationReflection: vacationReflection,
      thirteenthReflection: thirteenthReflection,
      grossTotal: grossTotal,
      inssDiscount: inssDiscount,
      inssRate: inssRate,
      irrfDiscount: irrfDiscount,
      irrfRate: irrfRate,
      netTotal: netTotal,
      totalOvertimeHours: totalOvertimeHours,
      // Metadata
      id: _uuid.v4(),
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculates INSS (progressive tax with ceiling)
  Map<String, double> _calculateInss(double grossTotal) {
    double desconto = 0.0;
    double aliquota = 0.0;

    for (final faixa in CalculationConstants.faixasInss) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquotaFaixa = faixa['aliquota']!;

      if (grossTotal > min) {
        final baseCalculo = grossTotal > max ? max : grossTotal;
        final valorFaixa = baseCalculo - min;
        desconto += valorFaixa * aliquotaFaixa;
        aliquota = aliquotaFaixa;
      }
    }

    // Apply INSS ceiling
    final tetoInss = CalculationConstants.tetoInss * 0.14;
    if (desconto > tetoInss) {
      desconto = tetoInss;
    }

    return {'desconto': desconto, 'aliquota': aliquota};
  }

  /// Calculates IRRF (progressive tax with dependent deductions)
  Map<String, double> _calculateIrrf(double baseCalculo, int dependents) {
    // Apply dependent deductions
    final baseComDependentes = baseCalculo -
        (dependents * CalculationConstants.deducaoDependenteIrrf);

    if (baseComDependentes <= 0) {
      return {'desconto': 0.0, 'aliquota': 0.0};
    }

    for (final faixa in CalculationConstants.faixasIrrf) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquota = faixa['aliquota']!;
      final deducao = faixa['deducao']!;

      if (baseComDependentes >= min && baseComDependentes <= max) {
        final desconto = (baseComDependentes * aliquota) - deducao;
        return {
          'desconto': desconto > 0 ? desconto : 0.0,
          'aliquota': aliquota,
        };
      }
    }

    return {'desconto': 0.0, 'aliquota': 0.0};
  }
}
