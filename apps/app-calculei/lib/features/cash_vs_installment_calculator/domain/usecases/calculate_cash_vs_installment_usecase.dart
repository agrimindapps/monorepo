import 'dart:math' as math;
import 'package:core/core.dart';
import 'package:uuid/uuid.dart';
import '../entities/cash_vs_installment_calculation.dart';

class CalculateCashVsInstallmentParams {
  final double cashPrice;
  final double installmentPrice;
  final int numberOfInstallments;
  final double monthlyInterestRate;

  const CalculateCashVsInstallmentParams({
    required this.cashPrice,
    required this.installmentPrice,
    required this.numberOfInstallments,
    this.monthlyInterestRate = 0.8,
  });
}

class CalculateCashVsInstallmentUseCase {
  Future<Either<Failure, CashVsInstallmentCalculation>> call(
      CalculateCashVsInstallmentParams params) async {
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

  ValidationFailure? _validate(CalculateCashVsInstallmentParams params) {
    if (params.cashPrice <= 0) {
      return const ValidationFailure('Valor à vista deve ser maior que zero');
    }

    if (params.cashPrice > 10000000) {
      return const ValidationFailure(
          'Valor à vista não pode exceder R\$ 10.000.000,00');
    }

    if (params.installmentPrice <= 0) {
      return const ValidationFailure(
          'Valor da parcela deve ser maior que zero');
    }

    if (params.installmentPrice > 10000000) {
      return const ValidationFailure(
          'Valor da parcela não pode exceder R\$ 10.000.000,00');
    }

    if (params.numberOfInstallments <= 0) {
      return const ValidationFailure(
          'Número de parcelas deve ser maior que zero');
    }

    if (params.numberOfInstallments > 360) {
      return const ValidationFailure(
          'Número de parcelas não pode exceder 360 (30 anos)');
    }

    if (params.monthlyInterestRate < 0) {
      return const ValidationFailure('Taxa de juros não pode ser negativa');
    }

    if (params.monthlyInterestRate > 20) {
      return const ValidationFailure(
          'Taxa de juros não pode exceder 20% ao mês');
    }

    return null;
  }

  CashVsInstallmentCalculation _performCalculation(
      CalculateCashVsInstallmentParams params) {
    // 1. Calculate total installment price
    final totalInstallmentPrice =
        params.installmentPrice * params.numberOfInstallments;

    // 2. Calculate implicit rate
    final implicitRate = _calculateImplicitRate(
      params.cashPrice,
      totalInstallmentPrice,
      params.numberOfInstallments,
    );

    // 3. Calculate present value of installments
    final presentValueOfInstallments = _calculatePresentValue(
      params.installmentPrice,
      params.numberOfInstallments,
      params.monthlyInterestRate,
    );

    // 4. Determine best option
    String bestOption;
    double savingsOrAdditionalCost;

    if (presentValueOfInstallments < params.cashPrice) {
      bestOption = 'Parcelado';
      savingsOrAdditionalCost = params.cashPrice - presentValueOfInstallments;
    } else {
      bestOption = 'À Vista';
      savingsOrAdditionalCost = presentValueOfInstallments - params.cashPrice;
    }

    return CashVsInstallmentCalculation(
      id: const Uuid().v4(),
      cashPrice: params.cashPrice,
      installmentPrice: params.installmentPrice,
      numberOfInstallments: params.numberOfInstallments,
      monthlyInterestRate: params.monthlyInterestRate,
      totalInstallmentPrice: totalInstallmentPrice,
      implicitRate: implicitRate,
      presentValueOfInstallments: presentValueOfInstallments,
      bestOption: bestOption,
      savingsOrAdditionalCost: savingsOrAdditionalCost,
      calculatedAt: DateTime.now(),
    );
  }

  double _calculateImplicitRate(
    double cashPrice,
    double totalInstallmentPrice,
    int numberOfInstallments,
  ) {
    try {
      // Implicit rate = (total / cash price) ^ (1/n) - 1
      final rate = (math.pow(
            totalInstallmentPrice / cashPrice,
            1 / numberOfInstallments,
          ) as double) -
          1;

      // Validate and constrain the rate
      if (rate.isNaN || rate.isInfinite) {
        return 0.0;
      }

      // Limit to reasonable bounds: -50% to +100%
      if (rate > 1.0) {
        return 1.0;
      } else if (rate < -0.5) {
        return -0.5;
      }

      return rate;
    } catch (e) {
      return 0.0;
    }
  }

  double _calculatePresentValue(
    double installmentPrice,
    int numberOfInstallments,
    double monthlyInterestRate,
  ) {
    // Convert percentage to decimal
    final rate = monthlyInterestRate / 100;

    // If rate is zero, present value equals total
    if (rate == 0) {
      return installmentPrice * numberOfInstallments;
    }

    var presentValue = 0.0;

    // Calculate present value of each installment
    for (var i = 1; i <= numberOfInstallments; i++) {
      final discountFactor = math.pow(1 + rate, i) as double;

      // Validate discount factor
      if (discountFactor.isFinite && discountFactor > 0) {
        presentValue += installmentPrice / discountFactor;
      } else {
        // If discount factor is invalid, use simple addition
        presentValue += installmentPrice;
      }
    }

    return presentValue;
  }
}
