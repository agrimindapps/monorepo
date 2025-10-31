import 'package:core/core.dart' show GetIt;

import '../../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../../features/expenses/data/datasources/expense_remote_datasource.dart';
import '../../../features/expenses/data/repositories/expense_repository_hybrid_impl.dart';
import '../../../features/expenses/domain/repositories/expense_repository.dart';
import '../../../features/expenses/domain/services/expense_validation_service.dart';
import '../../../features/expenses/domain/usecases/add_expense.dart';
import '../../../features/expenses/domain/usecases/delete_expense.dart';
import '../../../features/expenses/domain/usecases/get_expense_summary.dart';
import '../../../features/expenses/domain/usecases/get_expenses.dart';
import '../../../features/expenses/domain/usecases/get_expenses_by_category.dart';
import '../../../features/expenses/domain/usecases/get_expenses_by_date_range.dart';
import '../../../features/expenses/domain/usecases/update_expense.dart';
import '../di_module.dart';

/// Expenses module responsible for expenses feature dependencies
///
/// Follows SRP: Single responsibility of expenses feature registration
/// Follows OCP: Open for extension via DI module interface
/// Follows DIP: Depends on abstractions (interfaces)
class ExpensesModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Services
    getIt.registerLazySingleton<ExpenseValidationService>(
      () => ExpenseValidationService(),
    );

    // Data Sources
    getIt.registerLazySingleton<ExpenseLocalDataSource>(
      () => ExpenseLocalDataSourceImpl(),
    );

    getIt.registerLazySingleton<ExpenseRemoteDataSource>(
      () => ExpenseRemoteDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryHybridImpl(
        localDataSource: getIt<ExpenseLocalDataSource>(),
        remoteDataSource: getIt<ExpenseRemoteDataSource>(),
        connectivity: getIt(),
      ),
    );

    // Use Cases (Read)
    getIt.registerLazySingleton<GetExpenses>(
      () => GetExpenses(getIt<ExpenseRepository>()),
    );

    getIt.registerLazySingleton<GetExpensesByDateRange>(
      () => GetExpensesByDateRange(getIt<ExpenseRepository>()),
    );

    getIt.registerLazySingleton<GetExpensesByCategory>(
      () => GetExpensesByCategory(getIt<ExpenseRepository>()),
    );

    getIt.registerLazySingleton<GetExpenseSummary>(
      () => GetExpenseSummary(getIt<ExpenseRepository>()),
    );

    // Use Cases (Write)
    getIt.registerLazySingleton<AddExpense>(
      () => AddExpense(
        getIt<ExpenseRepository>(),
        getIt<ExpenseValidationService>(),
      ),
    );

    getIt.registerLazySingleton<UpdateExpense>(
      () => UpdateExpense(
        getIt<ExpenseRepository>(),
        getIt<ExpenseValidationService>(),
      ),
    );

    getIt.registerLazySingleton<DeleteExpense>(
      () => DeleteExpense(
        getIt<ExpenseRepository>(),
        getIt<ExpenseValidationService>(),
      ),
    );
  }
}
