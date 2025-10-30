import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesByCategoryParams {
  final String userId;
  final ExpenseCategory category;

  GetExpensesByCategoryParams({
    required this.userId,
    required this.category,
  });
}

@lazySingleton
class GetExpensesByCategory
    implements UseCase<List<Expense>, GetExpensesByCategoryParams> {
  final ExpenseRepository repository;

  GetExpensesByCategory(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(
      GetExpensesByCategoryParams params) async {
    return repository.getExpensesByCategory(params.userId, params.category);
  }
}
