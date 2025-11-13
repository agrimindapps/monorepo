import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/expenses_table.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<PetivetiDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(PetivetiDatabase db) : super(db);

  /// Get all expenses for a user
  Future<List<Expense>> getAllExpenses(String userId) {
    return (select(expenses)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  /// Get expenses by animal ID
  Future<List<Expense>> getExpensesByAnimal(int animalId) {
    return (select(expenses)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  /// Watch expenses for an animal
  Stream<List<Expense>> watchExpensesByAnimal(int animalId) {
    return (select(expenses)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id) {
    return (select(expenses)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Create expense
  Future<int> createExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  /// Update expense
  Future<bool> updateExpense(int id, ExpensesCompanion expense) async {
    return (update(expenses)..where((tbl) => tbl.id.equals(id)))
      .write(expense.copyWith(updatedAt: Value(DateTime.now())));
  }

  /// Delete expense
  Future<bool> deleteExpense(int id) async {
    return (update(expenses)..where((tbl) => tbl.id.equals(id)))
      .write(ExpensesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String userId, String category) {
    return (select(expenses)
      ..where((tbl) => 
        tbl.userId.equals(userId) & 
        tbl.isDeleted.equals(false) &
        tbl.category.equals(category))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  /// Get total expenses for an animal
  Future<double> getTotalExpenses(int animalId) async {
    final sum = expenses.amount.sum();
    final query = selectOnly(expenses)
      ..addColumns([sum])
      ..where(expenses.animalId.equals(animalId) & expenses.isDeleted.equals(false));
    
    final result = await query.getSingleOrNull();
    return result?.read(sum) ?? 0.0;
  }

  /// Get expenses within date range
  Future<List<Expense>> getExpensesByDateRange(
    int animalId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(expenses)
      ..where((tbl) => 
        tbl.animalId.equals(animalId) & 
        tbl.isDeleted.equals(false) &
        tbl.date.isBetweenValues(startDate, endDate))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }
}
