import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense_summary.dart';
import '../repositories/expense_repository.dart';

class GetExpenseSummary implements UseCase<ExpenseSummary, String> {
  final ExpenseRepository repository;

  GetExpenseSummary(this.repository);

  @override
  Future<Either<Failure, ExpenseSummary>> call(String userId) async {
    return await repository.getExpenseSummary(userId);
  }
}
