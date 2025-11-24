
import '../entities/expense.dart';
import '../entities/expense_summary.dart';

/// Service responsible for processing and organizing expense data
/// Follows Single Responsibility Principle - only handles data processing
class ExpenseProcessingService {
  const ExpenseProcessingService();

  /// Filters expenses for the current month
  List<Expense> getMonthlyExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
            expense.expenseDate.year == now.year &&
            expense.expenseDate.month == now.month)
        .toList();
  }

  /// Filters expenses for a specific year
  List<Expense> getYearlyExpenses(List<Expense> expenses, int year) {
    return expenses
        .where((expense) => expense.expenseDate.year == year)
        .toList();
  }

  /// Groups expenses by category
  Map<ExpenseCategory, List<Expense>> groupByCategory(List<Expense> expenses) {
    final expensesByCategory = <ExpenseCategory, List<Expense>>{};

    for (final category in ExpenseCategory.values) {
      expensesByCategory[category] =
          expenses.where((expense) => expense.category == category).toList();
    }

    return expensesByCategory;
  }

  /// Groups expenses by animal
  Map<String, List<Expense>> groupByAnimal(List<Expense> expenses) {
    final expensesByAnimal = <String, List<Expense>>{};

    for (final expense in expenses) {
      expensesByAnimal.putIfAbsent(expense.animalId, () => []);
      expensesByAnimal[expense.animalId]!.add(expense);
    }

    return expensesByAnimal;
  }

  /// Sorts expenses by date (most recent first)
  List<Expense> sortByDateDescending(List<Expense> expenses) {
    final sorted = List<Expense>.from(expenses);
    sorted.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return sorted;
  }

  /// Sorts expenses by amount (highest first)
  List<Expense> sortByAmountDescending(List<Expense> expenses) {
    final sorted = List<Expense>.from(expenses);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }

  /// Filters expenses by date range
  List<Expense> filterByDateRange(
    List<Expense> expenses,
    DateTime startDate,
    DateTime endDate,
  ) {
    return expenses
        .where((expense) =>
            expense.expenseDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            expense.expenseDate.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Calculates summary from expenses
  ExpenseSummary calculateSummary(List<Expense> expenses) {
    return ExpenseSummary.fromExpenses(expenses);
  }

  /// Gets top N expenses by amount
  List<Expense> getTopExpenses(List<Expense> expenses, int count) {
    final sorted = sortByAmountDescending(expenses);
    return sorted.take(count).toList();
  }

  /// Calculates total amount for a list of expenses
  double calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Calculates average expense amount
  double calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return calculateTotal(expenses) / expenses.length;
  }

  /// Gets expenses for a specific category
  List<Expense> getExpensesByCategory(
    List<Expense> expenses,
    ExpenseCategory category,
  ) {
    return expenses.where((expense) => expense.category == category).toList();
  }

  /// Gets expenses for a specific animal
  List<Expense> getExpensesByAnimal(List<Expense> expenses, String animalId) {
    return expenses.where((expense) => expense.animalId == animalId).toList();
  }
}
