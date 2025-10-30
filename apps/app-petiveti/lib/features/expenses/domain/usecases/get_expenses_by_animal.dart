import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class GetExpensesByAnimal implements UseCase<List<Expense>, String> {
  final ExpenseRepository repository;

  GetExpensesByAnimal(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(String animalId) async {
    return repository.getExpensesByAnimal(animalId);
  }
}
