import '../../domain/entities/expense.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<List<ExpenseModel>> getExpensesByAnimal(String animalId);
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  );
  Future<List<ExpenseModel>> getExpensesByCategory(
    String userId, 
    ExpenseCategory category
  );
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<void> cacheExpenses(List<ExpenseModel> expenses);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  static const String _boxName = 'expenses';
  final Map<String, ExpenseModel> _cache = {};

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    return _cache.values
        .where((expense) => expense.userId == userId)
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
  }

  @override
  Future<List<ExpenseModel>> getExpensesByAnimal(String animalId) async {
    return _cache.values
        .where((expense) => expense.animalId == animalId)
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    return _cache.values
        .where((expense) => 
            expense.userId == userId &&
            expense.expenseDate.isAfter(startDate.subtract(const Duration(milliseconds: 1))) &&
            expense.expenseDate.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(
    String userId, 
    ExpenseCategory category
  ) async {
    return _cache.values
        .where((expense) => 
            expense.userId == userId &&
            expense.category == category)
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    _cache[expense.id] = expense;
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    _cache[expense.id] = expense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    _cache.remove(expenseId);
  }

  @override
  Future<void> cacheExpenses(List<ExpenseModel> expenses) async {
    for (final expense in expenses) {
      _cache[expense.id] = expense;
    }
  }
}