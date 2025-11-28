import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/services/expense_error_handling_service.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/services/expense_processing_service.dart';
import '../../domain/services/expense_validation_service.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expense_summary.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_category.dart';
import '../../domain/usecases/get_expenses_by_date_range.dart';
import '../../domain/usecases/update_expense.dart';

part 'expenses_providers.g.dart';

@riverpod
ExpenseLocalDataSource expenseLocalDataSource(Ref ref) {
  final database = ref.watch(petivetiDatabaseProvider);
  return ExpenseLocalDataSourceImpl(database);
}

@riverpod
ExpenseErrorHandlingService expenseErrorHandlingService(Ref ref) {
  return ExpenseErrorHandlingService();
}

@riverpod
ExpenseValidationService expenseValidationService(Ref ref) {
  return ExpenseValidationService();
}

@riverpod
ExpenseRepository expenseRepository(Ref ref) {
  final localDataSource = ref.watch(expenseLocalDataSourceProvider);
  final errorHandlingService = ref.watch(expenseErrorHandlingServiceProvider);
  return ExpenseRepositoryImpl(
    localDataSource: localDataSource,
    errorHandlingService: errorHandlingService,
  );
}

@riverpod
ExpenseProcessingService expenseProcessingService(Ref ref) {
  return ExpenseProcessingService();
}

@riverpod
GetExpenses getExpenses(Ref ref) {
  return GetExpenses(ref.watch(expenseRepositoryProvider));
}

@riverpod
GetExpensesByDateRange getExpensesByDateRange(Ref ref) {
  return GetExpensesByDateRange(ref.watch(expenseRepositoryProvider));
}

@riverpod
GetExpensesByCategory getExpensesByCategory(Ref ref) {
  return GetExpensesByCategory(ref.watch(expenseRepositoryProvider));
}

@riverpod
GetExpenseSummary getExpenseSummary(Ref ref) {
  return GetExpenseSummary(ref.watch(expenseRepositoryProvider));
}

@riverpod
AddExpense addExpense(Ref ref) {
  return AddExpense(
    ref.watch(expenseRepositoryProvider),
    ref.watch(expenseValidationServiceProvider),
  );
}

@riverpod
UpdateExpense updateExpense(Ref ref) {
  return UpdateExpense(
    ref.watch(expenseRepositoryProvider),
    ref.watch(expenseValidationServiceProvider),
  );
}

@riverpod
DeleteExpense deleteExpense(Ref ref) {
  return DeleteExpense(
    ref.watch(expenseRepositoryProvider),
    ref.watch(expenseValidationServiceProvider),
  );
}
