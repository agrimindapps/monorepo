import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/expense.dart';
import '../entities/expense_summary.dart';
import '../repositories/expense_repository.dart';

class GetExpenses implements UseCase<List<Expense>, String> {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(String userId) async {
    return await repository.getExpenses(userId);
  }
}

class GetExpensesByAnimal implements UseCase<List<Expense>, String> {
  final ExpenseRepository repository;

  GetExpensesByAnimal(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(String animalId) async {
    return await repository.getExpensesByAnimal(animalId);
  }
}

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

class GetExpensesByCategoryParams {
  final String userId;
  final ExpenseCategory category;

  GetExpensesByCategoryParams({
    required this.userId,
    required this.category,
  });
}

class GetExpensesByCategory implements UseCase<List<Expense>, GetExpensesByCategoryParams> {
  final ExpenseRepository repository;

  GetExpensesByCategory(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesByCategoryParams params) async {
    return await repository.getExpensesByCategory(params.userId, params.category);
  }
}

class GetExpenseSummary implements UseCase<ExpenseSummary, String> {
  final ExpenseRepository repository;

  GetExpenseSummary(this.repository);

  @override
  Future<Either<Failure, ExpenseSummary>> call(String userId) async {
    return await repository.getExpenseSummary(userId);
  }
}

class AddExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense expense) async {
    if (expense.title.trim().isEmpty) {
      return Left(ValidationFailure('Título da despesa é obrigatório'));
    }

    if (expense.amount <= 0) {
      return Left(ValidationFailure('Valor da despesa deve ser maior que zero'));
    }

    if (expense.expenseDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return Left(ValidationFailure('Data da despesa não pode ser futura'));
    }

    return await repository.addExpense(expense);
  }
}

class UpdateExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense expense) async {
    if (expense.title.trim().isEmpty) {
      return Left(ValidationFailure('Título da despesa é obrigatório'));
    }

    if (expense.amount <= 0) {
      return Left(ValidationFailure('Valor da despesa deve ser maior que zero'));
    }

    return await repository.updateExpense(expense);
  }
}

class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(String expenseId) async {
    if (expenseId.trim().isEmpty) {
      return Left(ValidationFailure('ID da despesa é obrigatório'));
    }

    return await repository.deleteExpense(expenseId);
  }
}