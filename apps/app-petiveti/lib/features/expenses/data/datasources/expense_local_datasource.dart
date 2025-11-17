import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/petiveti_database.dart';
import '../models/expense_model.dart';
import '../../domain/entities/expense.dart' as domain;

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<List<ExpenseModel>> getExpensesByAnimalId(int animalId);
  Future<List<ExpenseModel>> getExpensesByCategory(
    String userId,
    String category,
  );
  Future<double> getTotalExpenses(int animalId);
  Future<ExpenseModel?> getExpenseById(int id);
  Future<int> addExpense(ExpenseModel expense);
  Future<bool> updateExpense(ExpenseModel expense);
  Future<bool> deleteExpense(int id);
  Stream<List<ExpenseModel>> watchExpensesByAnimalId(int animalId);
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<ExpenseModel>> getExpensesByAnimal(String animalId);
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
  Future<List<ExpenseModel>> getExpensesByCategory(
    String userId,
    String category,
  ) async {
    final expenses = await _database.expenseDao.getExpensesByCategory(
      userId,
      category,
    );
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
    final companion = _toCompanion(expense, forUpdate: true);
    return await _database.expenseDao.updateExpense(expense.intId, companion);
  }

  @override
  Future<bool> deleteExpense(int id) async {
    return await _database.expenseDao.deleteExpense(id);
  }

  @override
  Stream<List<ExpenseModel>> watchExpensesByAnimalId(int animalId) {
    return _database.expenseDao
        .watchExpensesByAnimal(animalId)
        .map((expenses) => expenses.map(_toModel).toList());
  }

  ExpenseModel _toModel(Expense expense) {
    // Parse enum from string
    final category = domain.ExpenseCategory.values.firstWhere(
      (e) => e.toString() == 'ExpenseCategory.${expense.category}',
      orElse: () => domain.ExpenseCategory.other,
    );

    final paymentMethod = domain.PaymentMethod.values.firstWhere(
      (e) => e.toString() == 'PaymentMethod.${expense.paymentMethod}',
      orElse: () => domain.PaymentMethod.cash,
    );

    domain.RecurrenceType? recurrenceType;
    if (expense.recurrenceType != null) {
      recurrenceType = domain.RecurrenceType.values.firstWhere(
        (e) => e.toString() == 'RecurrenceType.${expense.recurrenceType}',
        orElse: () => domain.RecurrenceType.monthly,
      );
    }

    return ExpenseModel(
      id: expense.id.toString(),
      animalId: expense.animalId.toString(),
      userId: expense.userId,
      title: expense.title,
      description: expense.description,
      amount: expense.amount,
      category: category,
      paymentMethod: paymentMethod,
      expenseDate: expense.expenseDate,
      veterinaryClinic: expense.veterinaryClinic,
      veterinarianName: expense.veterinarianName,
      invoiceNumber: expense.invoiceNumber,
      notes: expense.notes,
      veterinarian: expense.veterinarian,
      receiptNumber: expense.receiptNumber,
      isPaid: expense.isPaid,
      isRecurring: expense.isRecurring,
      recurrenceType: recurrenceType,
      isDeleted: expense.isDeleted,
      attachments: const [], // Not stored in Drift yet
      metadata: null, // Not stored in Drift yet
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt ?? expense.createdAt,
    );
  }

  ExpensesCompanion _toCompanion(ExpenseModel model, {bool forUpdate = false}) {
    final categoryStr = model.category.toString().split('.').last;
    final paymentMethodStr = model.paymentMethod.toString().split('.').last;
    final recurrenceTypeStr = model.recurrenceType?.toString().split('.').last;

    if (forUpdate) {
      return ExpensesCompanion(
        id: Value(model.intId),
        animalId: Value(model.intAnimalId),
        title: Value(model.title),
        description: Value(model.description),
        amount: Value(model.amount),
        category: Value(categoryStr),
        paymentMethod: Value(paymentMethodStr),
        expenseDate: Value(model.expenseDate),
        veterinaryClinic: Value.absentIfNull(model.veterinaryClinic),
        veterinarianName: Value.absentIfNull(model.veterinarianName),
        invoiceNumber: Value.absentIfNull(model.invoiceNumber),
        notes: Value.absentIfNull(model.notes),
        veterinarian: Value.absentIfNull(model.veterinarian),
        receiptNumber: Value.absentIfNull(model.receiptNumber),
        isPaid: Value(model.isPaid),
        isRecurring: Value(model.isRecurring),
        recurrenceType: Value.absentIfNull(recurrenceTypeStr),
        userId: Value(model.userId),
        updatedAt: Value(DateTime.now()),
      );
    }

    return ExpensesCompanion.insert(
      animalId: model.intAnimalId,
      title: model.title,
      description: model.description,
      amount: model.amount,
      category: categoryStr,
      paymentMethod: paymentMethodStr,
      expenseDate: model.expenseDate,
      veterinaryClinic: Value.absentIfNull(model.veterinaryClinic),
      veterinarianName: Value.absentIfNull(model.veterinarianName),
      invoiceNumber: Value.absentIfNull(model.invoiceNumber),
      notes: Value.absentIfNull(model.notes),
      veterinarian: Value.absentIfNull(model.veterinarian),
      receiptNumber: Value.absentIfNull(model.receiptNumber),
      isPaid: Value(model.isPaid),
      isRecurring: Value(model.isRecurring),
      recurrenceType: Value.absentIfNull(recurrenceTypeStr),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    // TODO: implement getExpensesByDateRange
    throw UnimplementedError();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByAnimal(String animalId) {
    // TODO: implement getExpensesByAnimal
    throw UnimplementedError();
  }
}
