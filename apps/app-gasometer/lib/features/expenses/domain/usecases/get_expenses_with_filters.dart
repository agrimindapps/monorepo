import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../entities/expense_entity.dart';

/// Parâmetros para filtros avançados de despesas
class ExpensesFilterParams {
  const ExpensesFilterParams({
    this.vehicleId,
    this.type,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchText,
  });

  final String? vehicleId;
  final ExpenseType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchText;

  @override
  String toString() {
    return 'ExpensesFilterParams(vehicleId: $vehicleId, type: $type, '
        'startDate: $startDate, endDate: $endDate, '
        'minAmount: $minAmount, maxAmount: $maxAmount, searchText: $searchText)';
  }
}

/// UseCase para buscar despesas com filtros avançados
///
/// Responsável por:
/// - Aplicar múltiplos filtros simultaneamente
/// - Validar parâmetros de filtro
/// - Retornar resultados ordenados

class GetExpensesWithFiltersUseCase
    implements UseCase<List<ExpenseEntity>, ExpensesFilterParams> {
  const GetExpensesWithFiltersUseCase(this._repository);

  final IExpensesRepository _repository;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(
    ExpensesFilterParams params,
  ) async {
    try {
      final validation = _validateFilters(params);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }

      final expenses = await _repository.getExpensesWithFilters(
        vehicleId: params.vehicleId,
        type: params.type,
        startDate: params.startDate,
        endDate: params.endDate,
        minAmount: params.minAmount,
        maxAmount: params.maxAmount,
        searchText: params.searchText,
      );
      expenses.sort((a, b) => b.date.compareTo(a.date));

      return Right(expenses);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar despesas com filtros: ${e.toString()}'),
      );
    }
  }

  String? _validateFilters(ExpensesFilterParams params) {
    if (params.startDate != null && params.endDate != null) {
      if (params.endDate!.isBefore(params.startDate!)) {
        return 'Data final deve ser posterior à data inicial';
      }
    }
    if (params.minAmount != null && params.minAmount! < 0) {
      return 'Valor mínimo não pode ser negativo';
    }

    if (params.maxAmount != null && params.maxAmount! < 0) {
      return 'Valor máximo não pode ser negativo';
    }

    if (params.minAmount != null &&
        params.maxAmount != null &&
        params.maxAmount! < params.minAmount!) {
      return 'Valor máximo deve ser maior que valor mínimo';
    }

    return null;
  }
}
