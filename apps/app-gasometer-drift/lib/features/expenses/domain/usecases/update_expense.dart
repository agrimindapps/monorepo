import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../entities/expense_entity.dart';

/// UseCase para atualizar uma despesa existente
///
/// Responsável por:
/// - Validar alterações
/// - Marcar como dirty para sync
/// - Atualizar localmente
/// - Sincronizar com Firebase em background
@injectable
class UpdateExpenseUseCase implements UseCase<ExpenseEntity?, ExpenseEntity> {
  const UpdateExpenseUseCase(this._repository);

  final IExpensesRepository _repository;

  @override
  Future<Either<Failure, ExpenseEntity?>> call(ExpenseEntity params) async {
    try {
      final validation = _validateExpense(params);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }
      final existing = await _repository.getExpenseById(params.id);
      if (existing == null) {
        return const Left(
          ValidationFailure('Despesa não encontrada'),
        );
      }
      final updatedExpense = params.copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

      final result = await _repository.updateExpense(updatedExpense);

      if (result == null) {
        return const Left(
          CacheFailure('Falha ao atualizar despesa'),
        );
      }

      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao atualizar despesa: ${e.toString()}'),
      );
    }
  }

  String? _validateExpense(ExpenseEntity expense) {
    if (expense.id.trim().isEmpty) {
      return 'ID da despesa é obrigatório';
    }

    if (expense.vehicleId.trim().isEmpty) {
      return 'Veículo é obrigatório';
    }

    if (expense.description.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }

    if (expense.amount <= 0) {
      return 'Valor deve ser positivo';
    }

    if (expense.odometer < 0) {
      return 'Odômetro não pode ser negativo';
    }

    return null;
  }
}
