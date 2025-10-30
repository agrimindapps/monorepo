import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';
import '../services/expense_error_handling_service.dart';

@LazySingleton(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseErrorHandlingService errorHandlingService;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.errorHandlingService,
  });

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String userId) async {
    return errorHandlingService.executeListOperation(
      operation: () => localDataSource.getExpenses(userId),
      operationName: 'buscar despesas',
    );
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByAnimal(
      String animalId) async {
    return errorHandlingService.executeListOperation(
      operation: () => localDataSource.getExpensesByAnimal(animalId),
      operationName: 'buscar despesas do animal',
    );
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    return errorHandlingService.executeListOperation(
      operation: () =>
          localDataSource.getExpensesByDateRange(userId, startDate, endDate),
      operationName: 'buscar despesas por período',
    );
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(
      String userId, ExpenseCategory category) async {
    return errorHandlingService.executeListOperation(
      operation: () => localDataSource.getExpensesByCategory(userId, category),
      operationName: 'buscar despesas por categoria',
    );
  }

  @override
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary(
      String userId) async {
    return errorHandlingService.executeSummaryOperation(
      operation: () async {
        final expenses = await localDataSource.getExpenses(userId);
        return ExpenseSummary.fromExpenses(expenses);
      },
      operationName: 'gerar resumo de despesas',
    );
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    return errorHandlingService.executeVoidOperation(
      operation: () async {
        final expenseModel = ExpenseModel.fromEntity(expense);
        await localDataSource.addExpense(expenseModel);
      },
      operationName: 'adicionar despesa',
    );
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    return errorHandlingService.executeVoidOperation(
      operation: () async {
        final expenseModel = ExpenseModel.fromEntity(expense);
        await localDataSource.updateExpense(expenseModel);
      },
      operationName: 'atualizar despesa',
    );
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    return errorHandlingService.executeVoidOperation(
      operation: () => localDataSource.deleteExpense(expenseId),
      operationName: 'deletar despesa',
    );
  }

  @override
  Stream<Either<Failure, List<Expense>>> watchExpenses(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getExpenses(userId);
    }).asyncMap((future) => future);
  }

  @override
  Stream<Either<Failure, ExpenseSummary>> watchExpenseSummary(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getExpenseSummary(userId);
    }).asyncMap((future) => future);
  }
}
