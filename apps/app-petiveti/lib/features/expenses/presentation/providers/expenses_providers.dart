import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/services/expense_processing_service.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expense_summary.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_category.dart';
import '../../domain/usecases/get_expenses_by_date_range.dart';
import '../../domain/usecases/update_expense.dart';

part 'expenses_providers.g.dart';

@riverpod
ExpenseLocalDataSource expenseLocalDataSource(ExpenseLocalDataSourceRef ref) {
  final database = ref.watch(petivetiDatabaseProvider);
  return ExpenseLocalDataSourceImpl(database);
}

@riverpod
ExpenseRepository expenseRepository(ExpenseRepositoryRef ref) {
  final localDataSource = ref.watch(expenseLocalDataSourceProvider);
  return ExpenseRepositoryImpl(localDataSource);
}

@riverpod
ExpenseProcessingService expenseProcessingService(ExpenseProcessingServiceRef ref) {
  return ExpenseProcessingService();
}

@riverpod
GetExpenses getExpenses(GetExpensesRef ref) {
  return GetExpenses(ref.watch(expenseRepositoryProvider));
}

@riverpod
GetExpensesByDateRange getExpensesByDateRange(GetExpensesByDateRangeRef ref) {
  return GetExpensesByDateRange(ref.watch(expenseRepositoryProvider));
}

@riverpod
GetExpensesByCategory getExpensesByCategory(GetExpensesByCategoryRef ref) {
  return GetExpensesByCategory(ref.watch(expenseRepositoryProvider));
}

@riverpod
GetExpenseSummary getExpenseSummary(GetExpenseSummaryRef ref) {
  return GetExpenseSummary(ref.watch(expenseRepositoryProvider));
}

@riverpod
AddExpense addExpense(AddExpenseRef ref) {
  return AddExpense(ref.watch(expenseRepositoryProvider));
}

@riverpod
UpdateExpense updateExpense(UpdateExpenseRef ref) {
  return UpdateExpense(ref.watch(expenseRepositoryProvider));
}

@riverpod
DeleteExpense deleteExpense(DeleteExpenseRef ref) {
  return DeleteExpense(ref.watch(expenseRepositoryProvider));
}
