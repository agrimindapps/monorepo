import '../../features/expenses/domain/entities/expense_entity.dart';
import '../constants/ui_constants.dart';

/// Interface for expenses repository operations
/// Provides contract for different expense storage implementations
abstract class IExpensesRepository {
  /// Initialize the repository
  Future<void> initialize();

  /// Save new expense
  Future<ExpenseEntity?> saveExpense(ExpenseEntity expense);

  /// Update existing expense
  Future<ExpenseEntity?> updateExpense(ExpenseEntity expense);

  /// Delete expense by ID
  Future<bool> deleteExpense(String expenseId);

  /// Get expense by ID
  Future<ExpenseEntity?> getExpenseById(String expenseId);

  /// Get all expenses
  Future<List<ExpenseEntity>> getAllExpenses();

  /// Get expenses by vehicle
  Future<List<ExpenseEntity>> getExpensesByVehicle(String vehicleId);

  /// Get expenses by type
  Future<List<ExpenseEntity>> getExpensesByType(ExpenseType type);

  /// Get expenses by date range
  Future<List<ExpenseEntity>> getExpensesByPeriod(DateTime start, DateTime end);

  /// Search expenses by text
  Future<List<ExpenseEntity>> searchExpenses(String query);

  /// Get repository statistics
  Future<Map<String, dynamic>> getStats();

  /// Find potential duplicate expenses
  Future<List<ExpenseEntity>> findDuplicates();

  /// Clear all expenses (for testing/debugging)
  Future<void> clearAllExpenses();

  /// Close repository and cleanup resources
  Future<void> close();

  /// Batch operations
  Future<List<ExpenseEntity>> saveExpenses(List<ExpenseEntity> expenses);
  Future<bool> deleteExpenses(List<String> expenseIds);

  /// Advanced filtering
  Future<List<ExpenseEntity>> getExpensesWithFilters({
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchText,
  });

  /// Pagination support
  Future<PagedResult<ExpenseEntity>> getExpensesPaginated({
    int page = 0,
    int pageSize = AppDefaults.defaultPageSize,
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    ExpenseSortBy sortBy = ExpenseSortBy.date,
    SortOrder sortOrder = SortOrder.descending,
  });
}

/// Paged result wrapper
class PagedResult<T> {

  const PagedResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
}

/// Sort options for expenses
enum ExpenseSortBy {
  date,
  amount,
  type,
  description,
  odometer,
}

/// Sort order
enum SortOrder {
  ascending,
  descending,
}