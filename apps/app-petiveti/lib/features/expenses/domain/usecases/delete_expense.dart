import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/expense_repository.dart';

class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(String expenseId) async {
    if (expenseId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID da despesa é obrigatório'));
    }

    return await repository.deleteExpense(expenseId);
  }
}
