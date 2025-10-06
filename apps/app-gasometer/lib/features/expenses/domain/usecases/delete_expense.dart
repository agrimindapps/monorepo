import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';

/// UseCase para deletar uma despesa
///
/// Responsável por:
/// - Soft delete (marca isDeleted=true)
/// - Preservar dados para sync multi-dispositivo
/// - Sincronizar deleção com Firebase
@injectable
class DeleteExpenseUseCase implements UseCase<bool, String> {
  const DeleteExpenseUseCase(this._repository);

  final IExpensesRepository _repository;

  @override
  Future<Either<Failure, bool>> call(String expenseId) async {
    try {
      if (expenseId.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da despesa é obrigatório'),
        );
      }
      final expense = await _repository.getExpenseById(expenseId);
      if (expense == null) {
        return const Left(
          ValidationFailure('Despesa não encontrada'),
        );
      }
      final result = await _repository.deleteExpense(expenseId);

      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao deletar despesa: ${e.toString()}'),
      );
    }
  }
}
