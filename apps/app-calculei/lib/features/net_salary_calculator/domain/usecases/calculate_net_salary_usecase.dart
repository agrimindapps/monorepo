import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../constants/calculation_constants.dart';
import '../entities/net_salary_calculation.dart';

class CalculateNetSalaryParams {
  final double grossSalary;
  final int dependents;
  final double transportationVoucher;
  final double healthInsurance;
  final double otherDiscounts;

  const CalculateNetSalaryParams({
    required this.grossSalary,
    this.dependents = 0,
    this.transportationVoucher = 0.0,
    this.healthInsurance = 0.0,
    this.otherDiscounts = 0.0,
  });
}

class CalculateNetSalaryUseCase {
  Future<Either<Failure, NetSalaryCalculation>> call(
      CalculateNetSalaryParams params) async {
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      final calculation = _performCalculation(params);
      return Right(calculation);
    } catch (e) {
      return Left(ValidationFailure('Erro no cálculo: $e'));
    }
  }

  ValidationFailure? _validate(CalculateNetSalaryParams params) {
    if (params.grossSalary <= 0) {
      return const ValidationFailure('Salário bruto deve ser maior que zero');
    }

    if (params.grossSalary > CalculationConstants.tetoInss * 10) {
      return ValidationFailure(
        'Salário bruto não pode exceder R\$ ${(CalculationConstants.tetoInss * 10).toStringAsFixed(2)}',
      );
    }

    if (params.dependents < 0) {
      return const ValidationFailure(
          'Número de dependentes não pode ser negativo');
    }

    if (params.dependents > CalculationConstants.maxDependentes) {
      return ValidationFailure(
        'Número de dependentes não pode exceder ${CalculationConstants.maxDependentes}',
      );
    }

    if (params.transportationVoucher < 0) {
      return const ValidationFailure(
          'Valor do vale transporte não pode ser negativo');
    }

    if (params.healthInsurance < 0) {
      return const ValidationFailure(
          'Valor do plano de saúde não pode ser negativo');
    }

    if (params.otherDiscounts < 0) {
      return const ValidationFailure(
          'Outros descontos não podem ser negativos');
    }

    final totalVoluntaryDiscounts = params.transportationVoucher +
        params.healthInsurance +
        params.otherDiscounts;
    if (totalVoluntaryDiscounts >= params.grossSalary) {
      return const ValidationFailure(
          'Total de descontos voluntários não pode ser maior ou igual ao salário bruto');
    }

    return null;
  }

  NetSalaryCalculation _performCalculation(CalculateNetSalaryParams params) {
    // 1. Calculate INSS
    final inssResult = _calculateInss(params.grossSalary);
    final inssDiscount = inssResult['discount']!;
    final inssRate = inssResult['rate']!;

    // 2. Calculate IRRF base (gross salary - INSS)
    final irrfCalculationBase = params.grossSalary - inssDiscount;

    // 3. Calculate IRRF
    final irrfResult = _calculateIrrf(irrfCalculationBase, params.dependents);
    final irrfDiscount = irrfResult['discount']!;
    final irrfRate = irrfResult['rate']!;

    // 4. Calculate transportation voucher discount
    final transportationVoucherDiscount =
        _calculateTransportationVoucherDiscount(
      params.grossSalary,
      params.transportationVoucher,
    );

    // 5. Calculate total discounts
    final totalDiscounts = inssDiscount +
        irrfDiscount +
        transportationVoucherDiscount +
        params.healthInsurance +
        params.otherDiscounts;

    // 6. Calculate net salary
    final netSalary = params.grossSalary - totalDiscounts;

    return NetSalaryCalculation(
      id: const Uuid().v4(),
      grossSalary: params.grossSalary,
      dependents: params.dependents,
      transportationVoucher: params.transportationVoucher,
      healthInsurance: params.healthInsurance,
      otherDiscounts: params.otherDiscounts,
      inssDiscount: inssDiscount,
      irrfDiscount: irrfDiscount,
      transportationVoucherDiscount: transportationVoucherDiscount,
      totalDiscounts: totalDiscounts,
      netSalary: netSalary,
      inssRate: inssRate,
      irrfRate: irrfRate,
      irrfCalculationBase: irrfCalculationBase,
      calculatedAt: DateTime.now(),
    );
  }

  Map<String, double> _calculateInss(double grossSalary) {
    double discount = 0.0;
    double rate = 0.0;

    for (final bracket in CalculationConstants.faixasInss) {
      final min = bracket['min']!;
      final max = bracket['max']!;
      final bracketRate = bracket['aliquota']!;

      if (grossSalary > min) {
        final calculationBase = grossSalary > max ? max : grossSalary;
        final bracketValue = calculationBase - min;
        discount += bracketValue * bracketRate;
        rate = bracketRate;
      }
    }

    // Apply INSS ceiling
    final maxInssDiscount = CalculationConstants.tetoInss * 0.14;
    if (discount > maxInssDiscount) {
      discount = maxInssDiscount;
    }

    return {'discount': discount, 'rate': rate};
  }

  Map<String, double> _calculateIrrf(double calculationBase, int dependents) {
    // Apply dependent deduction
    final baseWithDependents = calculationBase -
        (dependents * CalculationConstants.deducaoDependenteIrrf);

    if (baseWithDependents <= 0) {
      return {'discount': 0.0, 'rate': 0.0};
    }

    for (final bracket in CalculationConstants.faixasIrrf) {
      final min = bracket['min']!;
      final max = bracket['max']!;
      final rate = bracket['aliquota']!;
      final deduction = bracket['deducao']!;

      if (baseWithDependents >= min && baseWithDependents <= max) {
        final discount = (baseWithDependents * rate) - deduction;
        return {
          'discount': discount > 0 ? discount : 0.0,
          'rate': rate,
        };
      }
    }

    return {'discount': 0.0, 'rate': 0.0};
  }

  double _calculateTransportationVoucherDiscount(
    double grossSalary,
    double transportationVoucher,
  ) {
    if (transportationVoucher <= 0) {
      return 0.0;
    }

    final maxDiscount =
        grossSalary * CalculationConstants.percentualValeTransporte;
    return transportationVoucher > maxDiscount
        ? maxDiscount
        : transportationVoucher;
  }
}
