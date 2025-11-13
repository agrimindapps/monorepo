import 'package:injectable/injectable.dart';

import '../../../../database/petiveti_database.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<List<ExpenseModel>> getExpensesByAnimalId(int animalId);
  Future<List<ExpenseModel>> getExpensesByCategory(String userId, String category);
  Future<double> getTotalExpenses(int animalId);
  Future<ExpenseModel?> getExpenseById(int id);
  Future<int> addExpense(ExpenseModel expense);
  Future<bool> updateExpense(ExpenseModel expense);
  Future<bool> deleteExpense(int id);
  Stream<List<ExpenseModel>> watchExpensesByAnimalId(int animalId);
}

@LazySingleton(as: ExpenseLocalDataSource)
class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final PetivetiDatabase _database;

  ExpenseLocalDataSourceImpl(this._database);

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final expenses = await _database.expenseDao.getAllExpenses(userId);
    return expenses.map(_toModel).toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByAnimalId(int animalId) async {
    final expenses = await _database.expenseDao.getExpensesByAnimal(animalId);
    return expenses.map(_toModel).toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(String userId, String category) async {
    final expenses = await _database.expenseDao.getExpensesByCategory(userId, category);
    return expenses.map(_toModel).toList();
  }

  @override
  Future<double> getTotalExpenses(int animalId) async {
    return await _database.expenseDao.getTotalExpenses(animalId);
  }

  @override
  Future<ExpenseModel?> getExpenseById(int id) async {
    final expense = await _database.expenseDao.getExpenseById(id);
    return expense != null ? _toModel(expense) : null;
  }

  @override
  Future<int> addExpense(ExpenseModel expense) async {
    final companion = _toCompanion(expense);
    return await _database.expenseDao.createExpense(companion);
  }

  @override
  Future<bool> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) return false;
    final companion = _toCompanion(expense, forUpdate: true);
    return await _database.expenseDao.updateExpense(int.parse(expense.id!), companion);
  }

  @override
  Future<bool> deleteExpense(int id) async {
    return await _database.expenseDao.deleteExpense(id);
  }

  @override
  Stream<List<ExpenseModel>> watchExpensesByAnimalId(int animalId) {
    return _database.expenseDao.watchExpensesByAnimal(animalId)
        .map((expenses) => expenses.map(_toModel).toList());
  }

  ExpenseModel _toModel(Expense expense) {
    return ExpenseModel(
      id: expense.id.toString(),
      animalId: expense.animalId.toString(),
      description: expense.description,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      notes: expense.notes,
      userId: expense.userId,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      isDeleted: expense.isDeleted,
    );
  }

  ExpensesCompanion _toCompanion(ExpenseModel model, {bool forUpdate = false}) {
    if (forUpdate) {
      return ExpensesCompanion(
        id: model.id != null ? Value(int.parse(model.id!)) : const Value.absent(),
        animalId: Value(int.parse(model.animalId)),
        description: Value(model.description),
        amount: Value(model.amount),
        category: Value(model.category),
        date: Value(model.date),
        notes: Value.ofNullable(model.notes),
        userId: Value(model.userId),
        updatedAt: Value(DateTime.now()),
      );
    }

    return ExpensesCompanion.insert(
      animalId: int.parse(model.animalId),
      description: model.description,
      amount: model.amount,
      category: model.category,
      date: model.date,
      notes: Value.ofNullable(model.notes),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }
}
