import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/expenses/domain/entities/sync_expense_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/expenses_table.dart';

/// Adapter de sincronização para Expenses
class ExpenseDriftSyncAdapter extends DriftSyncAdapterBase<dynamic, Expense> {
  ExpenseDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'expenses';

  @override
  TableInfo<Expenses, Expense> get table => localDb.expenses;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.expenses)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar expenses dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.expenses,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        ExpensesCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
          firebaseId: firebaseId != null
              ? Value(firebaseId)
              : const Value.absent(),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar expense como sincronizado: $e'));
    }
  }

  @override
  ExpenseEntity driftToEntity(Expense row) {
    return ExpenseEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      animalId: row.animalId,
      title: row.title,
      description: row.description,
      amount: row.amount,
      category: row.category,
      paymentMethod: row.paymentMethod,
      expenseDate: row.expenseDate,
      veterinaryClinic: row.veterinaryClinic,
      veterinarianName: row.veterinarianName,
      invoiceNumber: row.invoiceNumber,
      notes: row.notes,
      veterinarian: row.veterinarian,
      receiptNumber: row.receiptNumber,
      isPaid: row.isPaid,
      isRecurring: row.isRecurring,
      recurrenceType: row.recurrenceType,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<Expense> entityToCompanion(dynamic entity) {
    final expenseEntity = entity as ExpenseEntity;
    return ExpensesCompanion(
      id: expenseEntity.id != null && expenseEntity.id!.isNotEmpty
          ? Value(int.parse(expenseEntity.id!))
          : const Value.absent(),
      firebaseId: Value(expenseEntity.firebaseId),
      userId: Value(expenseEntity.userId),
      animalId: Value(expenseEntity.animalId),
      title: Value(expenseEntity.title),
      description: Value(expenseEntity.description),
      amount: Value(expenseEntity.amount),
      category: Value(expenseEntity.category),
      paymentMethod: Value(expenseEntity.paymentMethod),
      expenseDate: Value(expenseEntity.expenseDate),
      veterinaryClinic: Value(expenseEntity.veterinaryClinic),
      veterinarianName: Value(expenseEntity.veterinarianName),
      invoiceNumber: Value(expenseEntity.invoiceNumber),
      notes: Value(expenseEntity.notes),
      veterinarian: Value(expenseEntity.veterinarian),
      receiptNumber: Value(expenseEntity.receiptNumber),
      isPaid: Value(expenseEntity.isPaid),
      isRecurring: Value(expenseEntity.isRecurring),
      recurrenceType: Value(expenseEntity.recurrenceType),
      createdAt: Value(expenseEntity.createdAt),
      updatedAt: Value(expenseEntity.updatedAt),
      isDeleted: Value(expenseEntity.isDeleted),
      lastSyncAt: Value(expenseEntity.lastSyncAt),
      isDirty: Value(expenseEntity.isDirty),
      version: Value(expenseEntity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(dynamic entity) {
    final expenseEntity = entity as ExpenseEntity;
    return expenseEntity.toFirestore();
  }

  @override
  dynamic fromFirestoreDoc(Map<String, dynamic> data) {
    return ExpenseEntity.fromFirestore(data, data['id'] as String);
  }
}
