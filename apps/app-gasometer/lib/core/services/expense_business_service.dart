import '../../../features/expenses/data/models/expense_model.dart';

/// Service responsible for expense business logic operations
/// Extracted from ExpenseModel to follow Single Responsibility Principle
class ExpenseBusinessService {
  /// Calculate total expenses from a list
  static double calculateTotalExpenses(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (total, expense) => total + expense.valor);
  }

  /// Filter expenses by type
  static List<ExpenseModel> filterByType(
    List<ExpenseModel> expenses,
    String type,
  ) {
    return expenses.where((expense) => expense.tipo == type).toList();
  }

  /// Filter expenses by vehicle
  static List<ExpenseModel> filterByVehicle(
    List<ExpenseModel> expenses,
    String vehicleId,
  ) {
    return expenses.where((expense) => expense.veiculoId == vehicleId).toList();
  }

  /// Filter expenses by date range
  static List<ExpenseModel> filterByDateRange(
    List<ExpenseModel> expenses,
    DateTime startDate,
    DateTime endDate,
  ) {
    return expenses.where((expense) {
      final expenseDate = DateTime.fromMillisecondsSinceEpoch(expense.data);
      return expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             expenseDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filter expenses by value range
  static List<ExpenseModel> filterByValueRange(
    List<ExpenseModel> expenses,
    double minValue,
    double maxValue,
  ) {
    return expenses
        .where((expense) => expense.valor >= minValue && expense.valor <= maxValue)
        .toList();
  }

  /// Sort expenses by date (most recent first)
  static List<ExpenseModel> sortByDateDescending(List<ExpenseModel> expenses) {
    final sortedList = List<ExpenseModel>.from(expenses);
    sortedList.sort((a, b) => b.data.compareTo(a.data));
    return sortedList;
  }

  /// Sort expenses by date (oldest first)
  static List<ExpenseModel> sortByDateAscending(List<ExpenseModel> expenses) {
    final sortedList = List<ExpenseModel>.from(expenses);
    sortedList.sort((a, b) => a.data.compareTo(b.data));
    return sortedList;
  }

  /// Sort expenses by value (highest first)
  static List<ExpenseModel> sortByValueDescending(List<ExpenseModel> expenses) {
    final sortedList = List<ExpenseModel>.from(expenses);
    sortedList.sort((a, b) => b.valor.compareTo(a.valor));
    return sortedList;
  }

  /// Sort expenses by value (lowest first)
  static List<ExpenseModel> sortByValueAscending(List<ExpenseModel> expenses) {
    final sortedList = List<ExpenseModel>.from(expenses);
    sortedList.sort((a, b) => a.valor.compareTo(b.valor));
    return sortedList;
  }

  /// Calculate average expense value
  static double calculateAverageValue(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return 0.0;
    return calculateTotalExpenses(expenses) / expenses.length;
  }

  /// Find the highest value expense
  static ExpenseModel? findHighestValueExpense(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((current, next) => 
        current.valor > next.valor ? current : next);
  }

  /// Find the lowest value expense
  static ExpenseModel? findLowestValueExpense(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((current, next) => 
        current.valor < next.valor ? current : next);
  }

  /// Group expenses by month
  static Map<String, List<ExpenseModel>> groupByMonth(List<ExpenseModel> expenses) {
    final Map<String, List<ExpenseModel>> grouped = {};
    
    for (final expense in expenses) {
      final date = DateTime.fromMillisecondsSinceEpoch(expense.data);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      grouped.putIfAbsent(monthKey, () => <ExpenseModel>[]);
      grouped[monthKey]!.add(expense);
    }
    
    return grouped;
  }

  /// Group expenses by type
  static Map<String, List<ExpenseModel>> groupByType(List<ExpenseModel> expenses) {
    final Map<String, List<ExpenseModel>> grouped = {};
    
    for (final expense in expenses) {
      grouped.putIfAbsent(expense.tipo, () => <ExpenseModel>[]);
      grouped[expense.tipo]!.add(expense);
    }
    
    return grouped;
  }

  /// Calculate monthly totals
  static Map<String, double> calculateMonthlyTotals(List<ExpenseModel> expenses) {
    final grouped = groupByMonth(expenses);
    final Map<String, double> totals = {};
    
    grouped.forEach((month, expenseList) {
      totals[month] = calculateTotalExpenses(expenseList);
    });
    
    return totals;
  }

  /// Calculate type totals
  static Map<String, double> calculateTypeTotals(List<ExpenseModel> expenses) {
    final grouped = groupByType(expenses);
    final Map<String, double> totals = {};
    
    grouped.forEach((type, expenseList) {
      totals[type] = calculateTotalExpenses(expenseList);
    });
    
    return totals;
  }

  /// Validate expense data consistency
  static bool isValidExpense(ExpenseModel expense) {
    return expense.veiculoId.isNotEmpty &&
           expense.tipo.isNotEmpty &&
           expense.descricao.isNotEmpty &&
           expense.valor > 0 &&
           expense.data > 0 &&
           expense.odometro >= 0;
  }

  /// Check if expense belongs to specific date
  static bool belongsToDate(ExpenseModel expense, DateTime targetDate) {
    final expenseDate = DateTime.fromMillisecondsSinceEpoch(expense.data);
    return expenseDate.year == targetDate.year && 
           expenseDate.month == targetDate.month &&
           expenseDate.day == targetDate.day;
  }

  /// Check if expense value is within range
  static bool isValueInRange(ExpenseModel expense, double min, double max) {
    return expense.valor >= min && expense.valor <= max;
  }

  /// Compare two expenses by value
  static int compareByValue(ExpenseModel a, ExpenseModel b) {
    return a.valor.compareTo(b.valor);
  }

  /// Compare two expenses by date
  static int compareByDate(ExpenseModel a, ExpenseModel b) {
    return a.data.compareTo(b.data);
  }
}