import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../entities/expense_entity.dart';

/// UseCase para buscar todas as despesas
///
/// Responsável por:
/// - Buscar todas as despesas não-deletadas
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Utilizar cache quando disponível
@injectable
class GetAllExpensesUseCase implements UseCase<List<ExpenseEntity>, NoParams> {
  const GetAllExpensesUseCase(this._repository);

  final IExpensesRepository _repository;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(NoParams params) async {
    try {
      final expenses = await _repository.getAllExpenses();

      // Ordenar por data (mais recente primeiro)
      expenses.sort((a, b) => b.date.compareTo(a.date));

      return Right(expenses);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar despesas: ${e.toString()}'),
      );
    }
  }
}
