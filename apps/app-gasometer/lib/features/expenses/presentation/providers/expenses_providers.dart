import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/providers/database_providers.dart' as db;
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_all_expenses.dart';
import '../../domain/usecases/get_expenses_by_vehicle.dart';
import '../../domain/usecases/update_expense.dart';

part 'expenses_providers.g.dart';

@riverpod
AddExpenseUseCase addExpense(Ref ref) {
  return AddExpenseUseCase(ref.watch(db.expensesDomainRepositoryProvider));
}

@riverpod
UpdateExpenseUseCase updateExpense(Ref ref) {
  return UpdateExpenseUseCase(ref.watch(db.expensesDomainRepositoryProvider));
}

@riverpod
DeleteExpenseUseCase deleteExpense(Ref ref) {
  return DeleteExpenseUseCase(ref.watch(db.expensesDomainRepositoryProvider));
}

@riverpod
GetAllExpensesUseCase getAllExpenses(Ref ref) {
  return GetAllExpensesUseCase(ref.watch(db.expensesDomainRepositoryProvider));
}

@riverpod
GetExpensesByVehicleUseCase getExpensesByVehicle(Ref ref) {
  return GetExpensesByVehicleUseCase(ref.watch(db.expensesDomainRepositoryProvider));
}
