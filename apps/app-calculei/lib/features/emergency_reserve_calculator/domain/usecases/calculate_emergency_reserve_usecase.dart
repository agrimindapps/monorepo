import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../entities/emergency_reserve_calculation.dart';

class CalculateEmergencyReserveParams {
  final double monthlyExpenses;
  final double extraExpenses;
  final int desiredMonths;
  final double monthlySavings;

  const CalculateEmergencyReserveParams({
    required this.monthlyExpenses,
    this.extraExpenses = 0.0,
    required this.desiredMonths,
    this.monthlySavings = 0.0,
  });
}

@injectable
class CalculateEmergencyReserveUseCase {
  Future<Either<Failure, EmergencyReserveCalculation>> call(CalculateEmergencyReserveParams params) async {
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

  ValidationFailure? _validate(CalculateEmergencyReserveParams params) {
    if (params.monthlyExpenses <= 0) {
      return const ValidationFailure('Despesas mensais devem ser maiores que zero');
    }

    if (params.monthlyExpenses > 1000000) {
      return const ValidationFailure('Despesas mensais não podem exceder R\$ 1.000.000,00');
    }

    if (params.extraExpenses < 0) {
      return const ValidationFailure('Despesas extras não podem ser negativas');
    }

    if (params.extraExpenses > 1000000) {
      return const ValidationFailure('Despesas extras não podem exceder R\$ 1.000.000,00');
    }

    if (params.desiredMonths <= 0) {
      return const ValidationFailure('Número de meses deve ser maior que zero');
    }

    if (params.desiredMonths > 120) {
      return const ValidationFailure('Número de meses não pode exceder 120 (10 anos)');
    }

    if (params.monthlySavings < 0) {
      return const ValidationFailure('Valor poupado mensalmente não pode ser negativo');
    }

    if (params.monthlySavings > 1000000) {
      return const ValidationFailure('Valor poupado mensalmente não pode exceder R\$ 1.000.000,00');
    }

    return null;
  }

  EmergencyReserveCalculation _performCalculation(CalculateEmergencyReserveParams params) {
    // 1. Calculate total monthly expenses
    final totalMonthlyExpenses = params.monthlyExpenses + params.extraExpenses;

    // 2. Calculate total reserve amount
    final totalReserveAmount = totalMonthlyExpenses * params.desiredMonths;

    // 3. Calculate construction time if monthly savings is provided
    int constructionYears = 0;
    int constructionMonths = 0;

    if (params.monthlySavings > 0 && params.monthlySavings >= (totalReserveAmount * 0.01)) {
      final totalMonthsToConstruct = totalReserveAmount / params.monthlySavings;
      constructionYears = (totalMonthsToConstruct / 12).floor();
      constructionMonths = (totalMonthsToConstruct % 12).round();
    }

    // 4. Determine category and description
    final categoryData = _determineCategory(params.desiredMonths);

    return EmergencyReserveCalculation(
      id: const Uuid().v4(),
      monthlyExpenses: params.monthlyExpenses,
      extraExpenses: params.extraExpenses,
      desiredMonths: params.desiredMonths,
      monthlySavings: params.monthlySavings,
      totalMonthlyExpenses: totalMonthlyExpenses,
      totalReserveAmount: totalReserveAmount,
      constructionYears: constructionYears,
      constructionMonths: constructionMonths,
      category: categoryData['category']!,
      categoryDescription: categoryData['description']!,
      calculatedAt: DateTime.now(),
    );
  }

  Map<String, String> _determineCategory(int months) {
    if (months < 3) {
      return {
        'category': 'Mínima',
        'description': 'Cobertura apenas para emergências imediatas e muito básicas.',
      };
    } else if (months >= 3 && months < 6) {
      return {
        'category': 'Básica',
        'description': 'Nível recomendado para pessoas com emprego estável e sem dependentes.',
      };
    } else if (months >= 6 && months < 12) {
      return {
        'category': 'Confortável',
        'description': 'Ideal para quem tem família ou trabalha como autônomo/freelancer.',
      };
    } else {
      return {
        'category': 'Robusta',
        'description': 'Reserva sólida para longos períodos ou grandes imprevistos.',
      };
    }
  }
}
