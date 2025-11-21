import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/expenses_providers.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/services/expense_processing_service.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expense_summary.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_category.dart';
import '../../domain/usecases/get_expenses_by_date_range.dart';
import '../../domain/usecases/update_expense.dart';

part 'expenses_notifier.g.dart';

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

  double get totalAmount => summary?.totalAmount ?? 0;
  double get monthlyAmount => summary?.monthlyAmount ?? 0;
  double get yearlyAmount => summary?.yearlyAmount ?? 0;
  double get averageExpense => summary?.averageExpense ?? 0;

  Map<ExpenseCategory, double> get categoryAmounts {
    return summary?.categoryBreakdown ?? {};
  }
}

@riverpod
class ExpensesNotifier extends _$ExpensesNotifier {
  late final GetExpenses _getExpenses;
  late final GetExpensesByDateRange _getExpensesByDateRange;
  late final GetExpensesByCategory _getExpensesByCategory;
  late final GetExpenseSummary _getExpenseSummary;
  late final AddExpense _addExpense;
  late final UpdateExpense _updateExpense;
  late final DeleteExpense _deleteExpense;
  late final ExpenseProcessingService _processingService;

  @override
  ExpensesState build() {
    _getExpenses = ref.watch(getExpensesProvider);
    _getExpensesByDateRange = ref.watch(getExpensesByDateRangeProvider);
    _getExpensesByCategory = ref.watch(getExpensesByCategoryProvider);
    _getExpenseSummary = ref.watch(getExpenseSummaryProvider);
    _addExpense = ref.watch(addExpenseProvider);
    _updateExpense = ref.watch(updateExpenseProvider);
    _deleteExpense = ref.watch(deleteExpenseProvider);
    _processingService = ref.watch(expenseProcessingServiceProvider);

    return const ExpensesState();
  }

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
    final monthlyExpenses = _processingService.getMonthlyExpenses(expenses);
    final expensesByCategory = _processingService.groupByCategory(expenses);
    final summary = _processingService.calculateSummary(expenses);

    state = state.copyWith(
      expenses: expenses,
      monthlyExpenses: monthlyExpenses,
      expensesByCategory: expensesByCategory,
      summary: summary,
      isLoading: false,
      error: null,
    );
  }

  Future<void> loadExpensesByCategory(
      String userId, ExpenseCategory category) async {
    final params =
        GetExpensesByCategoryParams(userId: userId, category: category);
    final result = await _getExpensesByCategory(params);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (expenses) {
        final updatedCategoryMap =
            Map<ExpenseCategory, List<Expense>>.from(state.expensesByCategory);
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
        final updatedExpenses =
            state.expenses.where((e) => e.id != expenseId).toList();
        _processExpensesData(updatedExpenses);
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return state.expensesByCategory[category] ?? [];
  }

  double getCategoryAmount(ExpenseCategory category) {
    return state.categoryAmounts[category] ?? 0;
  }
}

// Derived providers
class CategoryExpenseParams {
  final String userId;
  final ExpenseCategory category;

  const CategoryExpenseParams(this.userId, this.category);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryExpenseParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          category == other.category;

  @override
  int get hashCode => userId.hashCode ^ category.hashCode;
}

@riverpod
Future<List<Expense>> categoryExpenses(
  CategoryExpensesRef ref,
  CategoryExpenseParams params,
) async {
  final notifier = ref.read(expensesNotifierProvider.notifier);
  await notifier.loadExpensesByCategory(params.userId, params.category);
  return notifier.getExpensesByCategory(params.category);
}

@riverpod
Stream<List<Expense>> expensesStream(ExpensesStreamRef ref, String userId) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpenses(userId).map((either) => either.fold(
        (failure) => <Expense>[],
        (expenses) => expenses,
      ));
}

@riverpod
Future<List<Expense>> monthlyExpenses(
    MonthlyExpensesRef ref, String userId) async {
  final notifier = ref.read(expensesNotifierProvider.notifier);
  await notifier.loadMonthlyExpenses(userId);
  return ref.read(expensesNotifierProvider).monthlyExpenses;
}

@riverpod
Future<ExpenseSummary?> expenseSummary(
    ExpenseSummaryRef ref, String userId) async {
  final notifier = ref.read(expensesNotifierProvider.notifier);
  await notifier.loadExpenseSummary(userId);
  return ref.read(expensesNotifierProvider).summary;
}
