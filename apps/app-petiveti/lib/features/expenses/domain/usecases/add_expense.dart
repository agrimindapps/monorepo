import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense expense) async {
    if (expense.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Título da despesa é obrigatório'));
    }

    if (expense.amount <= 0) {
      return const Left(ValidationFailure(message: 'Valor da despesa deve ser maior que zero'));
    }

    if (expense.expenseDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return const Left(ValidationFailure(message: 'Data da despesa não pode ser futura'));
    }

    return await repository.addExpense(expense);
  }
}
