import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/expense_usecases.dart';

// State classes
class ExpensesState {
  final List<Expense> expenses;
  final List<Expense> monthlyExpenses;
  final Map<ExpenseCategory, List<Expense>> expensesByCategory;
  final ExpenseSummary? summary;
  final bool isLoading;
  final String? error;

  const ExpensesState({
    this.expenses = const [],
    this.monthlyExpenses = const [],
    this.expensesByCategory = const {},
    this.summary,
    this.isLoading = false,
    this.error,
  });

  ExpensesState copyWith({
    List<Expense>? expenses,
    List<Expense>? monthlyExpenses,
    Map<ExpenseCategory, List<Expense>>? expensesByCategory,
    ExpenseSummary? summary,
    bool? isLoading,
    String? error,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      expensesByCategory: expensesByCategory ?? this.expensesByCategory,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Helper getters
  double get totalAmount => summary?.totalAmount ?? 0;
  double get monthlyAmount => summary?.monthlyAmount ?? 0;
  double get yearlyAmount => summary?.yearlyAmount ?? 0;
  double get averageExpense => summary?.averageExpense ?? 0;
  
  Map<ExpenseCategory, double> get categoryAmounts {
    return summary?.categoryBreakdown ?? {};
  }
}

// State notifier
class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final GetExpenses _getExpenses;
  final GetExpensesByDateRange _getExpensesByDateRange;
  final GetExpensesByCategory _getExpensesByCategory;
  final GetExpenseSummary _getExpenseSummary;
  final AddExpense _addExpense;
  final UpdateExpense _updateExpense;
  final DeleteExpense _deleteExpense;

  ExpensesNotifier({
    required GetExpenses getExpenses,
    required GetExpensesByDateRange getExpensesByDateRange,
    required GetExpensesByCategory getExpensesByCategory,
    required GetExpenseSummary getExpenseSummary,
    required AddExpense addExpense,
    required UpdateExpense updateExpense,
    required DeleteExpense deleteExpense,
  })  : _getExpenses = getExpenses,
        _getExpensesByDateRange = getExpensesByDateRange,
        _getExpensesByCategory = getExpensesByCategory,
        _getExpenseSummary = getExpenseSummary,
        _addExpense = addExpense,
        _updateExpense = updateExpense,
        _deleteExpense = deleteExpense,
        super(const ExpensesState());

  Future<void> loadExpenses(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getExpenses(userId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (expenses) => _processExpensesData(expenses),
    );
  }

  Future<void> loadExpenseSummary(String userId) async {
    final result = await _getExpenseSummary(userId);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (summary) => state = state.copyWith(
        summary: summary,
        isLoading: false,
        error: null,
      ),
    );
  }

  void _processExpensesData(List<Expense> expenses) {
    // Filter monthly expenses
    final now = DateTime.now();
    final monthlyExpenses = expenses.where((expense) => 
        expense.expenseDate.year == now.year && 
        expense.expenseDate.month == now.month).toList();

    // Group expenses by category
    final expensesByCategory = <ExpenseCategory, List<Expense>>{};
    for (final category in ExpenseCategory.values) {
      expensesByCategory[category] = expenses.where((e) => e.category == category).toList();
    }

    // Create summary from expenses
    final summary = ExpenseSummary.fromExpenses(expenses);

    state = state.copyWith(
      expenses: expenses,
      monthlyExpenses: monthlyExpenses,
      expensesByCategory: expensesByCategory,
      summary: summary,
      isLoading: false,
      error: null,
    );
  }

  Future<void> loadExpensesByCategory(String userId, ExpenseCategory category) async {
    final params = GetExpensesByCategoryParams(userId: userId, category: category);
    final result = await _getExpensesByCategory(params);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (expenses) {
        final updatedCategoryMap = Map<ExpenseCategory, List<Expense>>.from(state.expensesByCategory);
        updatedCategoryMap[category] = expenses;
        state = state.copyWith(
          expensesByCategory: updatedCategoryMap,
          error: null,
        );
      },
    );
  }

  Future<void> loadMonthlyExpenses(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final params = GetExpensesByDateRangeParams(
      userId: userId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    final result = await _getExpensesByDateRange(params);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (expenses) => state = state.copyWith(
        monthlyExpenses: expenses,
        error: null,
      ),
    );
  }

  Future<void> addExpense(Expense expense) async {
    final result = await _addExpense(expense);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Add the expense to current state optimistically
        final updatedExpenses = [expense, ...state.expenses];
        _processExpensesData(updatedExpenses);
      },
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final result = await _updateExpense(expense);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update the expense in current state
        final updatedExpenses = state.expenses.map((e) {
          return e.id == expense.id ? expense : e;
        }).toList();
        
        _processExpensesData(updatedExpenses);
      },
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    final result = await _deleteExpense(expenseId);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Remove the expense from current state
        final updatedExpenses = state.expenses.where((e) => e.id != expenseId).toList();
        _processExpensesData(updatedExpenses);
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper methods for the UI
  List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return state.expensesByCategory[category] ?? [];
  }

  double getCategoryAmount(ExpenseCategory category) {
    return state.categoryAmounts[category] ?? 0;
  }
}

// Providers
final expensesProvider = StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
  return ExpensesNotifier(
    getExpenses: di.getIt<GetExpenses>(),
    getExpensesByDateRange: di.getIt<GetExpensesByDateRange>(),
    getExpensesByCategory: di.getIt<GetExpensesByCategory>(),
    getExpenseSummary: di.getIt<GetExpenseSummary>(),
    addExpense: di.getIt<AddExpense>(),
    updateExpense: di.getIt<UpdateExpense>(),
    deleteExpense: di.getIt<DeleteExpense>(),
  );
});

// Individual category provider
final categoryExpensesProvider = FutureProvider.family<List<Expense>, (String, ExpenseCategory)>((ref, params) async {
  final notifier = ref.read(expensesProvider.notifier);
  await notifier.loadExpensesByCategory(params.$1, params.$2);
  return notifier.getExpensesByCategory(params.$2);
});

// Stream provider for real-time updates
final expensesStreamProvider = StreamProvider.family<List<Expense>, String>((ref, userId) {
  final repository = di.getIt.get<ExpenseRepository>();
  return repository.watchExpenses(userId);
});

// Monthly expenses provider
final monthlyExpensesProvider = FutureProvider.family<List<Expense>, String>((ref, userId) async {
  final notifier = ref.read(expensesProvider.notifier);
  await notifier.loadMonthlyExpenses(userId);
  return ref.read(expensesProvider).monthlyExpenses;
});

// Summary provider
final expenseSummaryProvider = FutureProvider.family<ExpenseSummary?, String>((ref, userId) async {
  final notifier = ref.read(expensesProvider.notifier);
  await notifier.loadExpenseSummary(userId);
  return ref.read(expensesProvider).summary;
});