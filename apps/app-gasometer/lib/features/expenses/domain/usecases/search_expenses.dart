import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../entities/expense_entity.dart';

/// UseCase para buscar despesas por texto
///
/// Responsável por:
/// - Buscar em múltiplos campos (descrição, notas, location)
/// - Retornar resultados ordenados por relevância
@injectable
class SearchExpensesUseCase implements UseCase<List<ExpenseEntity>, String> {
  const SearchExpensesUseCase(this._repository);

  final IExpensesRepository _repository;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final expenses = await _repository.searchExpenses(query);

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
