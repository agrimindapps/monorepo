import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpdateExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense expense) async {
    if (expense.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Título da despesa é obrigatório'));
    }

    if (expense.amount <= 0) {
      return const Left(ValidationFailure(message: 'Valor da despesa deve ser maior que zero'));
    }

    return await repository.updateExpense(expense);
  }
}
