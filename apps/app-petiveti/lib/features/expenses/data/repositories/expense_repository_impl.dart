import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String userId) async {
    try {
      final expenses = await localDataSource.getExpenses(userId);
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar despesas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByAnimal(String animalId) async {
    try {
      final expenses = await localDataSource.getExpensesByAnimal(animalId);
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar despesas do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final expenses = await localDataSource.getExpensesByDateRange(userId, startDate, endDate);
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar despesas por período: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(
    String userId, 
    ExpenseCategory category
  ) async {
    try {
      final expenses = await localDataSource.getExpensesByCategory(userId, category);
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar despesas por categoria: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary(String userId) async {
    try {
      final expenses = await localDataSource.getExpenses(userId);
      final summary = ExpenseSummary.fromExpenses(expenses);
      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('Erro ao gerar resumo de despesas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await localDataSource.addExpense(expenseModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar despesa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await localDataSource.updateExpense(expenseModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar despesa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await localDataSource.deleteExpense(expenseId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar despesa: ${e.toString()}'));
    }
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