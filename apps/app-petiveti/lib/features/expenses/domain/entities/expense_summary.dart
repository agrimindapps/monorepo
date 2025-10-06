import 'package:core/core.dart' show Equatable;
import 'expense.dart';

class ExpenseSummary extends Equatable {
  final double totalAmount;
  final double monthlyAmount;
  final double yearlyAmount;
  final Map<ExpenseCategory, double> categoryBreakdown;
  final Map<String, double> monthlyBreakdown;
  final int totalExpenses;
  final double averageExpense;
  final ExpenseCategory mostExpensiveCategory;
  final PaymentMethod mostUsedPaymentMethod;

  const ExpenseSummary({
    required this.totalAmount,
    required this.monthlyAmount,
    required this.yearlyAmount,
    required this.categoryBreakdown,
    required this.monthlyBreakdown,
    required this.totalExpenses,
    required this.averageExpense,
    required this.mostExpensiveCategory,
    required this.mostUsedPaymentMethod,
  });

  factory ExpenseSummary.fromExpenses(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const ExpenseSummary(
        totalAmount: 0,
        monthlyAmount: 0,
        yearlyAmount: 0,
        categoryBreakdown: {},
        monthlyBreakdown: {},
        totalExpenses: 0,
        averageExpense: 0,
        mostExpensiveCategory: ExpenseCategory.other,
        mostUsedPaymentMethod: PaymentMethod.cash,
      );
    }

    final totalAmount = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final now = DateTime.now();
    final monthlyExpenses = expenses.where((e) => e.isCurrentMonth).toList();
    final yearlyExpenses = expenses.where((e) => e.isCurrentYear).toList();

    final monthlyAmount = monthlyExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final yearlyAmount = yearlyExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final categoryBreakdown = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      categoryBreakdown[expense.category] =
          (categoryBreakdown[expense.category] ?? 0) + expense.amount;
    }
    final monthlyBreakdown = <String, double>{};
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final monthExpenses =
          expenses
              .where(
                (e) =>
                    e.expenseDate.year == date.year &&
                    e.expenseDate.month == date.month,
              )
              .toList();
      monthlyBreakdown[monthKey] = monthExpenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
    }
    var mostExpensiveCategory = ExpenseCategory.other;
    double maxCategoryAmount = 0;
    categoryBreakdown.forEach((category, amount) {
      if (amount > maxCategoryAmount) {
        maxCategoryAmount = amount;
        mostExpensiveCategory = category;
      }
    });
    final paymentMethodCount = <PaymentMethod, int>{};
    for (final expense in expenses) {
      paymentMethodCount[expense.paymentMethod] =
          (paymentMethodCount[expense.paymentMethod] ?? 0) + 1;
    }

    var mostUsedPaymentMethod = PaymentMethod.cash;
    int maxMethodCount = 0;
    paymentMethodCount.forEach((method, count) {
      if (count > maxMethodCount) {
        maxMethodCount = count;
        mostUsedPaymentMethod = method;
      }
    });

    return ExpenseSummary(
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      yearlyAmount: yearlyAmount,
      categoryBreakdown: categoryBreakdown,
      monthlyBreakdown: monthlyBreakdown,
      totalExpenses: expenses.length,
      averageExpense: totalAmount / expenses.length,
      mostExpensiveCategory: mostExpensiveCategory,
      mostUsedPaymentMethod: mostUsedPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [
    totalAmount,
    monthlyAmount,
    yearlyAmount,
    categoryBreakdown,
    monthlyBreakdown,
    totalExpenses,
    averageExpense,
    mostExpensiveCategory,
    mostUsedPaymentMethod,
  ];
}
