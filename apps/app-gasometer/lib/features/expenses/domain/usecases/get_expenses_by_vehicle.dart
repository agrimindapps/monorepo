import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../entities/expense_entity.dart';

/// UseCase para buscar despesas de um veículo específico
///
/// Responsável por:
/// - Buscar despesas filtradas por veículo
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Utilizar cache quando disponível

class GetExpensesByVehicleUseCase implements UseCase<List<ExpenseEntity>, String> {
  const GetExpensesByVehicleUseCase(this._repository);

  final IExpensesRepository _repository;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do veículo é obrigatório'),
        );
      }

      final expenses = await _repository.getExpensesByVehicle(vehicleId);
      expenses.sort((a, b) => b.date.compareTo(a.date));

      return Right(expenses);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar despesas do veículo: ${e.toString()}'),
      );
    }
  }
}
