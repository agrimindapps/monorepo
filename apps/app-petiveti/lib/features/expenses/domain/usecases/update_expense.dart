import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../services/expense_validation_service.dart';

@lazySingleton
class UpdateExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;
  final ExpenseValidationService validationService;

  UpdateExpense(this.repository, this.validationService);

  @override
  Future<Either<Failure, void>> call(Expense expense) async {
    final validation = validationService.validateForUpdate(expense);

    return validation.fold(
      (failure) => Left(failure),
      (validExpense) => repository.updateExpense(validExpense),
    );
  }
}
