import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesByDateRangeParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  GetExpensesByDateRangeParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
}

class GetExpensesByDateRange implements UseCase<List<Expense>, GetExpensesByDateRangeParams> {
  final ExpenseRepository repository;

  GetExpensesByDateRange(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesByDateRangeParams params) async {
    return await repository.getExpensesByDateRange(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}
