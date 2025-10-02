import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../entities/expense_entity.dart';

/// UseCase para adicionar uma nova despesa
///
/// Responsável por:
/// - Validar dados da despesa
/// - Persistir localmente (Hive)
/// - Sincronizar com Firebase em background
/// - Invalidar caches relacionados
@injectable
class AddExpenseUseCase implements UseCase<ExpenseEntity?, ExpenseEntity> {
  const AddExpenseUseCase(this._repository);

  final IExpensesRepository _repository;

  @override
  Future<Either<Failure, ExpenseEntity?>> call(ExpenseEntity params) async {
    try {
      // Validações básicas
      final validation = _validateExpense(params);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }

      // Salvar despesa
      final result = await _repository.saveExpense(params);

      if (result == null) {
        return const Left(
          CacheFailure('Falha ao salvar despesa localmente'),
        );
      }

      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao adicionar despesa: ${e.toString()}'),
      );
    }
  }

  /// Valida dados da despesa
  String? _validateExpense(ExpenseEntity expense) {
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

    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 1));
    if (expense.date.isAfter(maxFutureDate)) {
      return 'Data não pode ser mais de 1 dia no futuro';
    }

    final minPastDate = DateTime(2000);
    if (expense.date.isBefore(minPastDate)) {
      return 'Data muito antiga (mínimo: 2000)';
    }

    return null;
  }
}
