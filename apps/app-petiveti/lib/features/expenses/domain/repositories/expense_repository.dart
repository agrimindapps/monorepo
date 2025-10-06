import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../entities/expense_summary.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses(String userId);
  Future<Either<Failure, List<Expense>>> getExpensesByAnimal(String animalId);
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  );
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(
    String userId, 
    ExpenseCategory category
  );
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary(String userId);
  Future<Either<Failure, void>> addExpense(Expense expense);
  Future<Either<Failure, void>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Stream<Either<Failure, List<Expense>>> watchExpenses(String userId);
  Stream<Either<Failure, ExpenseSummary>> watchExpenseSummary(String userId);
}
