// Package imports:
// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/thirteenth_salary_calculation.dart';

/// Parameters for calculating 13th salary
class CalculateThirteenthSalaryParams {
  final double grossSalary;
  final int monthsWorked;
  final DateTime admissionDate;
  final DateTime calculationDate;
  final int unjustifiedAbsences;
  final bool isAdvancePayment;
  final int dependents;

  const CalculateThirteenthSalaryParams({
    required this.grossSalary,
    required this.monthsWorked,
    required this.admissionDate,
    required this.calculationDate,
    this.unjustifiedAbsences = 0,
    this.isAdvancePayment = false,
    this.dependents = 0,
  });
}

/// Use case for calculating 13th salary (Décimo Terceiro)
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for 13th salary calculation logic and validation
///
/// Business Rules:
/// 1. Pro-rata calculation: (salary / 12) × months worked
/// 2. Absences: Every 15 unjustified absences = 1 month discount
/// 3. INSS: Progressive tax with ceiling
/// 4. IRRF: Progressive tax with dependent deductions
/// 5. Advance payment: 1st = 50% gross, 2nd = net - 1st
class CalculateThirteenthSalaryUseCase {
  static const _uuid = Uuid();

  /// Calculates 13th salary based on parameters
  ///
  /// Returns:
  /// - Right(ThirteenthSalaryCalculation) if calculation succeeds
  /// - Left(ValidationFailure) if validation fails
  Future<Either<Failure, ThirteenthSalaryCalculation>> call(
    CalculateThirteenthSalaryParams params,
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
      return Left(ValidationFailure('Erro no cálculo do 13º salário: $e'));
    }
  }

  /// Validates input parameters
  ValidationFailure? _validate(CalculateThirteenthSalaryParams params) {
    // Salary validation
    if (params.grossSalary <= 0) {
      return const ValidationFailure('Salário bruto deve ser maior que zero');
    }

    if (params.grossSalary > CalculationConstants.maxSalario) {
      return ValidationFailure(
        'Salário bruto não pode exceder R\$ ${CalculationConstants.maxSalario.toStringAsFixed(2)}',
      );
    }

    // Months validation
    if (params.monthsWorked < 1 || params.monthsWorked > 12) {
      return const ValidationFailure(
        'Meses trabalhados devem estar entre 1 e 12',
      );
    }

    // Absences validation
    if (params.unjustifiedAbsences < 0) {
      return const ValidationFailure(
        'Faltas não justificadas não podem ser negativas',
      );
    }

    if (params.unjustifiedAbsences > 365) {
      return const ValidationFailure(
        'Faltas não justificadas não podem exceder 365',
      );
    }

    // Dependents validation
    if (params.dependents < 0) {
      return const ValidationFailure(
          'Número de dependentes não pode ser negativo');
    }

    if (params.dependents > 20) {
      return const ValidationFailure(
          'Número de dependentes não pode exceder 20');
    }

    // Date validation
    if (params.calculationDate.isBefore(params.admissionDate)) {
      return const ValidationFailure(
        'Data de cálculo não pode ser anterior à data de admissão',
      );
    }

    // Future date validation
    final now = DateTime.now();
    if (params.calculationDate.isAfter(now.add(const Duration(days: 365)))) {
      return const ValidationFailure(
        'Data de cálculo não pode ser mais de 1 ano no futuro',
      );
    }

    return null;
  }

  /// Performs the 13th salary calculation
  ThirteenthSalaryCalculation _performCalculation(
    CalculateThirteenthSalaryParams params,
  ) {
    // 1. Calculate considered months (after absence discounts)
    final consideredMonths = _calculateConsideredMonths(
      params.monthsWorked,
      params.unjustifiedAbsences,
    );

    // 2. Calculate value per month
    final valuePerMonth = params.grossSalary / CalculationConstants.mesesAno;

    // 3. Calculate gross 13th salary
    final grossThirteenthSalary = valuePerMonth * consideredMonths;

    // 4. Calculate INSS
    final inssResult = _calculateInss(grossThirteenthSalary);
    final inssDiscount = inssResult['desconto']!;
    final inssRate = inssResult['aliquota']!;

    // 5. Calculate IRRF base (gross - INSS)
    final irrfBaseCalculation = grossThirteenthSalary - inssDiscount;

    // 6. Calculate IRRF
    final irrfResult = _calculateIrrf(irrfBaseCalculation, params.dependents);
    final irrfDiscount = irrfResult['desconto']!;
    final irrfRate = irrfResult['aliquota']!;

    // 7. Calculate net 13th salary
    final netThirteenthSalary =
        grossThirteenthSalary - inssDiscount - irrfDiscount;

    // 8. Calculate installments if advance payment
    final firstInstallment = params.isAdvancePayment
        ? grossThirteenthSalary * CalculationConstants.percentualPrimeiraParcela
        : 0.0;

    final secondInstallment = params.isAdvancePayment
        ? netThirteenthSalary - firstInstallment
        : netThirteenthSalary;

    return ThirteenthSalaryCalculation(
      // Inputs
      grossSalary: params.grossSalary,
      monthsWorked: params.monthsWorked,
      admissionDate: params.admissionDate,
      calculationDate: params.calculationDate,
      unjustifiedAbsences: params.unjustifiedAbsences,
      isAdvancePayment: params.isAdvancePayment,
      dependents: params.dependents,
      // Results
      consideredMonths: consideredMonths,
      valuePerMonth: valuePerMonth,
      grossThirteenthSalary: grossThirteenthSalary,
      inssDiscount: inssDiscount,
      inssRate: inssRate,
      irrfDiscount: irrfDiscount,
      irrfRate: irrfRate,
      irrfBaseCalculation: irrfBaseCalculation,
      netThirteenthSalary: netThirteenthSalary,
      firstInstallment: firstInstallment,
      secondInstallment: secondInstallment,
      // Metadata
      id: _uuid.v4(),
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculates months considered after absence discounts
  ///
  /// Rule: Every 15 unjustified absences = 1 month discount
  int _calculateConsideredMonths(int monthsWorked, int unjustifiedAbsences) {
    final monthsDiscount =
        unjustifiedAbsences ~/ CalculationConstants.diasFaltaDesconto;
    final consideredMonths = monthsWorked - monthsDiscount;

    return consideredMonths > 0 ? consideredMonths : 0;
  }

  /// Calculates INSS (progressive tax with ceiling)
  Map<String, double> _calculateInss(double grossThirteenthSalary) {
    var desconto = 0.0;
    var aliquota = 0.0;

    for (final faixa in CalculationConstants.faixasInss) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquotaFaixa = faixa['aliquota']!;

      if (grossThirteenthSalary > min) {
        final baseCalculo =
            grossThirteenthSalary > max ? max : grossThirteenthSalary;
        final valorFaixa = baseCalculo - min;
        desconto += valorFaixa * aliquotaFaixa;
        aliquota = aliquotaFaixa;
      }
    }

    // Apply INSS ceiling
    const tetoInss = CalculationConstants.tetoInss * 0.14;
    if (desconto > tetoInss) {
      desconto = tetoInss;
    }

    return {'desconto': desconto, 'aliquota': aliquota};
  }

  /// Calculates IRRF (progressive tax with dependent deductions)
  Map<String, double> _calculateIrrf(double baseCalculo, int dependents) {
    // Apply dependent deductions
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
