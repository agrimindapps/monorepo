// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import '../entities/overtime_calculation.dart';

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
    this.nightAdditionalPercentage = 20.0,
    this.sundayHolidayHours = 0,
    this.workDaysMonth = 22,
    this.dependents = 0,
  });
}

class CalculateOvertimeUseCase {
  static const _uuid = Uuid();

  Future<Either<Failure, OvertimeCalculation>> call(
    CalculateOvertimeParams params,
  ) async {
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      final calculation = _performCalculation(params);
      return Right(calculation);
    } catch (e) {
      return Left(ValidationFailure('Erro no cálculo de horas extras: $e'));
    }
  }

  ValidationFailure? _validate(CalculateOvertimeParams params) {
    if (params.grossSalary <= 0) {
      return const ValidationFailure('Salário bruto deve ser maior que zero');
    }
    if (params.grossSalary > CalculationConstants.maxSalario) {
      return ValidationFailure(
        'Salário bruto não pode exceder R\$ ${CalculationConstants.maxSalario.toStringAsFixed(2)}',
      );
    }
    if (params.weeklyHours <= 0) {
      return const ValidationFailure('Horas semanais devem ser maior que zero');
    }
    if (params.weeklyHours > CalculationConstants.maxHorasSemanais) {
      return ValidationFailure(
        'Horas semanais não podem exceder ${CalculationConstants.maxHorasSemanais}',
      );
    }
    if (params.hours50 < 0 || params.hours100 < 0) {
      return const ValidationFailure('Horas extras não podem ser negativas');
    }
    final totalOvertime = params.hours50 + params.hours100;
    if (totalOvertime > CalculationConstants.maxHorasExtrasMes) {
      return ValidationFailure(
        'Total de horas extras não pode exceder ${CalculationConstants.maxHorasExtrasMes} por mês',
      );
    }
    if (params.nightHours < 0) {
      return const ValidationFailure('Horas noturnas não podem ser negativas');
    }
    if (params.nightAdditionalPercentage < 0 ||
        params.nightAdditionalPercentage > 100) {
      return const ValidationFailure(
        'Percentual noturno deve estar entre 0% e 100%',
      );
    }
    if (params.sundayHolidayHours < 0) {
      return const ValidationFailure(
        'Horas de domingo/feriado não podem ser negativas',
      );
    }
    if (params.workDaysMonth <= 0 || params.workDaysMonth > 31) {
      return const ValidationFailure('Dias úteis devem estar entre 1 e 31');
    }
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

  OvertimeCalculation _performCalculation(CalculateOvertimeParams params) {
    final monthlyWorkedHours = (params.weeklyHours * params.workDaysMonth) /
        CalculationConstants.diasTrabalhoSemana;
    final normalHourValue = params.grossSalary / monthlyWorkedHours;
    final hour50Value =
        normalHourValue * (1 + CalculationConstants.percentualHorasExtras50);
    final hour100Value =
        normalHourValue * (1 + CalculationConstants.percentualHorasExtras100);
    final nightHourValue =
        normalHourValue * (1 + params.nightAdditionalPercentage / 100);
    final sundayHolidayHourValue =
        normalHourValue * (1 + CalculationConstants.percentualDomingoFeriado);
    final total50 = params.hours50 * hour50Value;
    final total100 = params.hours100 * hour100Value;
    final totalNightAdditional = params.nightHours * nightHourValue;
    final totalSundayHoliday =
        params.sundayHolidayHours * sundayHolidayHourValue;
    final totalOvertimeHours = params.hours50 + params.hours100;
    final totalOvertime = total50 + total100;
    final dsrOvertime = totalOvertime * CalculationConstants.percentualDsr;
    final vacationReflection =
        totalOvertime * CalculationConstants.percentualReflexoFerias;
    final thirteenthReflection =
        totalOvertime * CalculationConstants.percentualReflexoDecimoTerceiro;
    final grossTotal = params.grossSalary +
        totalOvertime +
        totalNightAdditional +
        totalSundayHoliday +
        dsrOvertime +
        vacationReflection +
        thirteenthReflection;
    final inssResult = _calculateInss(grossTotal);
    final inssDiscount = inssResult['desconto']!;
    final inssRate = inssResult['aliquota']!;
    final irrfBaseCalculation = grossTotal - inssDiscount;
    final irrfResult = _calculateIrrf(irrfBaseCalculation, params.dependents);
    final irrfDiscount = irrfResult['desconto']!;
    final irrfRate = irrfResult['aliquota']!;
    final netTotal = grossTotal - inssDiscount - irrfDiscount;

    return OvertimeCalculation(
      grossSalary: params.grossSalary,
      weeklyHours: params.weeklyHours,
      hours50: params.hours50,
      hours100: params.hours100,
      nightHours: params.nightHours,
      nightAdditionalPercentage: params.nightAdditionalPercentage,
      sundayHolidayHours: params.sundayHolidayHours,
      workDaysMonth: params.workDaysMonth,
      dependents: params.dependents,
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
      id: _uuid.v4(),
      calculatedAt: DateTime.now(),
    );
  }

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
    final tetoInss = CalculationConstants.tetoInss * 0.14;
    if (desconto > tetoInss) {
      desconto = tetoInss;
    }
    return {'desconto': desconto, 'aliquota': aliquota};
  }

  Map<String, double> _calculateIrrf(double baseCalculo, int dependents) {
    final baseComDependentes =
        baseCalculo - (dependents * CalculationConstants.deducaoDependenteIrrf);
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
