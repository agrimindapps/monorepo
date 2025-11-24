import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../constants/calculation_constants.dart';
import '../entities/unemployment_insurance_calculation.dart';

class CalculateUnemploymentInsuranceParams {
  final double averageSalary;
  final int workMonths;
  final int timesReceived;
  final DateTime dismissalDate;

  const CalculateUnemploymentInsuranceParams({
    required this.averageSalary,
    required this.workMonths,
    this.timesReceived = 0,
    required this.dismissalDate,
  });
}

class CalculateUnemploymentInsuranceUseCase {
  Future<Either<Failure, UnemploymentInsuranceCalculation>> call(
      CalculateUnemploymentInsuranceParams params) async {
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

  ValidationFailure? _validate(CalculateUnemploymentInsuranceParams params) {
    if (params.averageSalary <= 0) {
      return const ValidationFailure('Salário médio deve ser maior que zero');
    }

    if (params.averageSalary > CalculationConstants.maxSalario) {
      return ValidationFailure(
        'Salário médio não pode exceder R\$ ${CalculationConstants.maxSalario.toStringAsFixed(2)}',
      );
    }

    if (params.workMonths < 0) {
      return const ValidationFailure('Tempo de trabalho não pode ser negativo');
    }

    if (params.workMonths >
        CalculationConstants.seguroDesempregoMaxTempoTrabalho) {
      return ValidationFailure(
        'Tempo de trabalho não pode exceder ${CalculationConstants.seguroDesempregoMaxTempoTrabalho} meses',
      );
    }

    if (params.timesReceived < 0) {
      return const ValidationFailure('Vezes recebidas não pode ser negativo');
    }

    if (params.timesReceived >
        CalculationConstants.seguroDesempregoMaxVezesRecebidas) {
      return ValidationFailure(
        'Vezes recebidas não pode exceder ${CalculationConstants.seguroDesempregoMaxVezesRecebidas}',
      );
    }

    final now = DateTime.now();
    if (params.dismissalDate.isAfter(now)) {
      return const ValidationFailure('Data de demissão não pode ser futura');
    }

    final minDate = DateTime(CalculationConstants.anoMinimoAdmissao);
    if (params.dismissalDate.isBefore(minDate)) {
      return ValidationFailure(
          'Data de demissão não pode ser anterior a ${CalculationConstants.anoMinimoAdmissao}');
    }

    return null;
  }

  UnemploymentInsuranceCalculation _performCalculation(
      CalculateUnemploymentInsuranceParams params) {
    // 1. Check eligibility
    final eligibilityCheck =
        _checkEligibility(params.workMonths, params.timesReceived);

    if (!eligibilityCheck['eligible']) {
      return _createIneligibleCalculation(params, eligibilityCheck);
    }

    // 2. Calculate installment value
    final installmentValue = _calculateInstallmentValue(params.averageSalary);

    // 3. Calculate number of installments
    final numberOfInstallments =
        _calculateNumberOfInstallments(params.workMonths, params.timesReceived);

    // 4. Calculate total value
    final totalValue = installmentValue * numberOfInstallments;

    // 5. Calculate dates
    final deadlineToRequest = params.dismissalDate.add(
      Duration(days: CalculationConstants.seguroDesempregoPrazoRequererDias),
    );
    final paymentStart =
        params.dismissalDate.add(const Duration(days: 30)); // Approx 30 days
    final paymentEnd = paymentStart.add(
      Duration(
          days: (numberOfInstallments - 1) *
              CalculationConstants.seguroDesempregoIntervaloParcelasDias),
    );

    // 6. Create payment schedule
    final paymentSchedule =
        _createPaymentSchedule(paymentStart, numberOfInstallments);

    return UnemploymentInsuranceCalculation(
      id: const Uuid().v4(),
      averageSalary: params.averageSalary,
      workMonths: params.workMonths,
      timesReceived: params.timesReceived,
      dismissalDate: params.dismissalDate,
      installmentValue: installmentValue,
      numberOfInstallments: numberOfInstallments,
      totalValue: totalValue,
      deadlineToRequest: deadlineToRequest,
      paymentStart: paymentStart,
      paymentEnd: paymentEnd,
      paymentSchedule: paymentSchedule,
      eligible: true,
      ineligibilityReason: '',
      requiredCarencyMonths: eligibilityCheck['carency'],
      calculatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _checkEligibility(int workMonths, int timesReceived) {
    int requiredCarency;

    // Determine required carency based on times received
    switch (timesReceived) {
      case 0:
        requiredCarency =
            CalculationConstants.seguroDesempregoCarenciaPrimeiraVez;
        break;
      case 1:
        requiredCarency =
            CalculationConstants.seguroDesempregoCarenciaSegundaVez;
        break;
      default:
        requiredCarency =
            CalculationConstants.seguroDesempregoCarenciaTerceiraVez;
        break;
    }

    if (workMonths < requiredCarency) {
      return {
        'eligible': false,
        'reason':
            'Tempo de trabalho insuficiente. Necessário: $requiredCarency meses.',
        'carency': requiredCarency,
      };
    }

    return {
      'eligible': true,
      'reason': '',
      'carency': requiredCarency,
    };
  }

  double _calculateInstallmentValue(double averageSalary) {
    // Salary brackets for 2024
    const salaryBrackets = [
      {'min': 0.0, 'max': 1968.36, 'multiplier': 0.8, 'fixed': 0.0},
      {'min': 1968.37, 'max': 3280.93, 'multiplier': 0.5, 'fixed': 1574.69},
      {
        'min': 3280.94,
        'max': double.infinity,
        'multiplier': 0.0,
        'fixed': 2230.97
      },
    ];

    for (final bracket in salaryBrackets) {
      final min = bracket['min'] as double;
      final max = bracket['max'] as double;
      final multiplier = bracket['multiplier'] as double;
      final fixed = bracket['fixed'] as double;

      if (averageSalary >= min && averageSalary <= max) {
        final value = (averageSalary * multiplier) + fixed;

        // Ensure minimum value
        if (value < CalculationConstants.seguroDesempregoValorMinimo) {
          return CalculationConstants.seguroDesempregoValorMinimo;
        }

        // Ensure maximum value
        if (value > CalculationConstants.seguroDesempregoValorMaximo) {
          return CalculationConstants.seguroDesempregoValorMaximo;
        }

        return value;
      }
    }

    return CalculationConstants.seguroDesempregoValorMinimo;
  }

  int _calculateNumberOfInstallments(int workMonths, int timesReceived) {
    // First time receiving
    if (timesReceived == 0) {
      const firstTimeTable = [
        {'minMonths': 12, 'maxMonths': 23, 'installments': 4},
        {'minMonths': 24, 'maxMonths': 35, 'installments': 5},
        {'minMonths': 36, 'maxMonths': 999, 'installments': 5},
      ];

      for (final bracket in firstTimeTable) {
        final min = bracket['minMonths']!;
        final max = bracket['maxMonths']!;
        final installments = bracket['installments']!;

        if (workMonths >= min && workMonths <= max) {
          return installments;
        }
      }
    } else {
      // Already received before
      const repeatedTable = [
        {'times': 1, 'minMonths': 9, 'maxMonths': 23, 'installments': 3},
        {'times': 1, 'minMonths': 24, 'maxMonths': 999, 'installments': 4},
        {'times': 2, 'minMonths': 6, 'maxMonths': 23, 'installments': 2},
        {'times': 2, 'minMonths': 24, 'maxMonths': 999, 'installments': 3},
      ];

      for (final bracket in repeatedTable) {
        final times = bracket['times'] as int;
        final min = bracket['minMonths'] as int;
        final max = bracket['maxMonths'] as int;
        final installments = bracket['installments'] as int;

        if (timesReceived == times && workMonths >= min && workMonths <= max) {
          return installments;
        }
      }

      // For 3+ times, use similar logic as 2 times
      if (timesReceived >= 3) {
        if (workMonths >= 6 && workMonths <= 23) {
          return 2;
        } else if (workMonths >= 24) {
          return 3;
        }
      }
    }

    return 0; // Not eligible
  }

  List<DateTime> _createPaymentSchedule(
      DateTime start, int numberOfInstallments) {
    final List<DateTime> schedule = [];

    for (int i = 0; i < numberOfInstallments; i++) {
      schedule.add(start.add(Duration(
          days:
              i * CalculationConstants.seguroDesempregoIntervaloParcelasDias)));
    }

    return schedule;
  }

  UnemploymentInsuranceCalculation _createIneligibleCalculation(
    CalculateUnemploymentInsuranceParams params,
    Map<String, dynamic> eligibilityCheck,
  ) {
    return UnemploymentInsuranceCalculation(
      id: const Uuid().v4(),
      averageSalary: params.averageSalary,
      workMonths: params.workMonths,
      timesReceived: params.timesReceived,
      dismissalDate: params.dismissalDate,
      installmentValue: 0.0,
      numberOfInstallments: 0,
      totalValue: 0.0,
      deadlineToRequest: params.dismissalDate,
      paymentStart: params.dismissalDate,
      paymentEnd: params.dismissalDate,
      paymentSchedule: [],
      eligible: false,
      ineligibilityReason: eligibilityCheck['reason'],
      requiredCarencyMonths: eligibilityCheck['carency'],
      calculatedAt: DateTime.now(),
    );
  }
}
