import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense_summary.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class GetExpenseSummary implements UseCase<ExpenseSummary, String> {
  final ExpenseRepository repository;

  GetExpenseSummary(this.repository);

  @override
  Future<Either<Failure, ExpenseSummary>> call(String userId) async {
    return repository.getExpenseSummary(userId);
  }
}
