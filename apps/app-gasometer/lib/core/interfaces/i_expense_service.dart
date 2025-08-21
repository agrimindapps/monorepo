import '../../features/expenses/data/models/expense_model.dart';

/// Interface for expense business operations
/// Provides contract for expense-related business logic
abstract class IExpenseService {
  /// Calculate business metrics
  Future<ExpenseMetrics> calculateMetrics(String vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get expense analytics
  Future<ExpenseAnalytics> getAnalytics(String vehicleId);

  /// Validate expense data
  ValidationResult validateExpense(ExpenseModel expense);

  /// Generate expense report
  Future<ExpenseReport> generateReport({
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? expenseTypes,
  });

  /// Get expense trends
  Future<List<ExpenseTrend>> getTrends(String vehicleId);

  /// Compare expenses between periods
  Future<ExpenseComparison> compareExpenses({
    required String vehicleId,
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
  });
}

/// Expense metrics data model
class ExpenseMetrics {
  final double totalExpenses;
  final double averageExpense;
  final int totalTransactions;
  final double highestExpense;
  final double lowestExpense;
  final Map<String, double> expensesByType;
  final Map<String, double> monthlyTotals;

  const ExpenseMetrics({
    required this.totalExpenses,
    required this.averageExpense,
    required this.totalTransactions,
    required this.highestExpense,
    required this.lowestExpense,
    required this.expensesByType,
    required this.monthlyTotals,
  });
}

/// Expense analytics data model
class ExpenseAnalytics {
  final ExpenseMetrics metrics;
  final List<ExpenseTrend> trends;
  final List<String> topExpenseCategories;
  final double projectedMonthlyExpense;

  const ExpenseAnalytics({
    required this.metrics,
    required this.trends,
    required this.topExpenseCategories,
    required this.projectedMonthlyExpense,
  });
}

/// Expense trend data model
class ExpenseTrend {
  final String period;
  final double amount;
  final double percentageChange;

  const ExpenseTrend({
    required this.period,
    required this.amount,
    required this.percentageChange,
  });
}

/// Expense comparison data model
class ExpenseComparison {
  final double period1Total;
  final double period2Total;
  final double difference;
  final double percentageChange;
  final Map<String, ExpenseTrend> categoryComparison;

  const ExpenseComparison({
    required this.period1Total,
    required this.period2Total,
    required this.difference,
    required this.percentageChange,
    required this.categoryComparison,
  });
}

/// Expense report data model
class ExpenseReport {
  final String title;
  final DateTime generatedAt;
  final ExpenseMetrics metrics;
  final List<ExpenseModel> expenses;
  final Map<String, dynamic> summary;

  const ExpenseReport({
    required this.title,
    required this.generatedAt,
    required this.metrics,
    required this.expenses,
    required this.summary,
  });
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}