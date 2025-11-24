import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/expense_repository.dart';
import '../services/expense_validation_service.dart';

class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository repository;
  final ExpenseValidationService validationService;

  DeleteExpense(this.repository, this.validationService);

  @override
  Future<Either<Failure, void>> call(String expenseId) async {
    final validation = validationService.validateId(expenseId);

    return validation.fold(
      (failure) => Left(failure),
      (validId) => repository.deleteExpense(validId),
    );
  }
}
