import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/mixins/loggable_repository_mixin.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryHybridImpl with LoggableRepositoryMixin implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  ExpenseRepositoryHybridImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String userId) async {
    try {
      final localExpenses = await localDataSource.getExpenses(userId);
      
      if (await isConnected) {
        try {
          final remoteExpenses = await remoteDataSource.getExpenses(userId);
          for (final remoteExpense in remoteExpenses) {
            final localExpense = localExpenses.firstWhere(
              (local) => local.id == remoteExpense.id,
              orElse: () => remoteExpense,
            );
            
            if (remoteExpense.updatedAt.isAfter(localExpense.updatedAt)) {
              await localDataSource.updateExpense(remoteExpense);
            }
          }
          
          final updatedLocalExpenses = await localDataSource.getExpenses(userId);
          return Right(updatedLocalExpenses);
          
        } catch (e) {
          return Right(localExpenses);
        }
      }
      
      return Right(localExpenses);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByAnimal(String animalId) async {
    try {
      final localExpenses = await localDataSource.getExpensesByAnimal(animalId);
      
      if (await isConnected) {
        try {
          final remoteExpenses = await remoteDataSource.getExpensesByAnimal('default_user', animalId);
          for (final remoteExpense in remoteExpenses) {
            final localExpense = localExpenses.firstWhere(
              (local) => local.id == remoteExpense.id,
              orElse: () => remoteExpense,
            );
            
            if (remoteExpense.updatedAt.isAfter(localExpense.updatedAt)) {
              await localDataSource.updateExpense(remoteExpense);
            }
          }
          
          final updatedExpenses = await localDataSource.getExpensesByAnimal(animalId);
          return Right(updatedExpenses);
          
        } catch (e) {
          return Right(localExpenses);
        }
      }
      
      return Right(localExpenses);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao buscar despesas do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final localExpenses = await localDataSource.getExpensesByDateRange(userId, startDate, endDate);
      
      if (await isConnected) {
        try {
          final remoteExpenses = await remoteDataSource.getExpensesByDateRange(userId, startDate, endDate);
          for (final remoteExpense in remoteExpenses) {
            final localExpense = localExpenses.firstWhere(
              (local) => local.id == remoteExpense.id,
              orElse: () => remoteExpense,
            );
            
            if (remoteExpense.updatedAt.isAfter(localExpense.updatedAt)) {
              await localDataSource.updateExpense(remoteExpense);
            }
          }
          
          final updatedExpenses = await localDataSource.getExpensesByDateRange(userId, startDate, endDate);
          return Right(updatedExpenses);
          
        } catch (e) {
          return Right(localExpenses);
        }
      }
      
      return Right(localExpenses);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao buscar despesas por período: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String userId, ExpenseCategory category) async {
    try {
      final localExpenses = await localDataSource.getExpensesByCategory(userId, category);
      
      if (await isConnected) {
        try {
          final remoteExpenses = await remoteDataSource.getExpensesByCategory(userId, category);
          for (final remoteExpense in remoteExpenses) {
            final localExpense = localExpenses.firstWhere(
              (local) => local.id == remoteExpense.id,
              orElse: () => remoteExpense,
            );
            
            if (remoteExpense.updatedAt.isAfter(localExpense.updatedAt)) {
              await localDataSource.updateExpense(remoteExpense);
            }
          }
          
          final updatedExpenses = await localDataSource.getExpensesByCategory(userId, category);
          return Right(updatedExpenses);
          
        } catch (e) {
          return Right(localExpenses);
        }
      }
      
      return Right(localExpenses);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao buscar despesas por categoria: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary(String userId) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);
      
      final expenses = await localDataSource.getExpensesByDateRange(userId, startDate, endDate);
      final summary = ExpenseSummary.fromExpenses(expenses);
      return Right(summary);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao calcular resumo de despesas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await localDataSource.addExpense(expenseModel);
      
      if (await isConnected) {
        try {
          final remoteId = await remoteDataSource.addExpense(expenseModel, expense.userId);
          if (remoteId != expenseModel.id) {
            final updatedModel = expenseModel.copyWith(id: remoteId);
            await localDataSource.updateExpense(updatedModel);
          }
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao adicionar despesa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await localDataSource.updateExpense(expenseModel);
      
      if (await isConnected) {
        try {
          await remoteDataSource.updateExpense(expenseModel);
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao atualizar despesa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await localDataSource.deleteExpense(expenseId);
      
      if (await isConnected) {
        try {
          await remoteDataSource.deleteExpense(expenseId);
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao deletar despesa: ${e.toString()}'));
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