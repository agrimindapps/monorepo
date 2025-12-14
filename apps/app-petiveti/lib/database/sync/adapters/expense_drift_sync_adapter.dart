import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/expenses/domain/entities/sync_expense_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/expenses_table.dart';

/// Adapter de sincronização para Expenses
class ExpenseDriftSyncAdapter extends DriftSyncAdapterBase<ExpenseEntity, Expense> {
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
  Insertable<Expense> entityToCompanion(ExpenseEntity entity) {
    return ExpensesCompanion(
      id: entity.id.isNotEmpty && int.tryParse(entity.id) != null
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      animalId: Value(entity.animalId),
      title: Value(entity.title),
      description: Value(entity.description),
      amount: Value(entity.amount),
      category: Value(entity.category),
      paymentMethod: Value(entity.paymentMethod),
      expenseDate: Value(entity.expenseDate),
      veterinaryClinic: Value(entity.veterinaryClinic),
      veterinarianName: Value(entity.veterinarianName),
      invoiceNumber: Value(entity.invoiceNumber),
      notes: Value(entity.notes),
      veterinarian: Value(entity.veterinarian),
      receiptNumber: Value(entity.receiptNumber),
      isPaid: Value(entity.isPaid),
      isRecurring: Value(entity.isRecurring),
      recurrenceType: Value(entity.recurrenceType),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt),
      isDeleted: Value(entity.isDeleted),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(ExpenseEntity entity) {
    return entity.toFirestore();
  }

  @override
  ExpenseEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return ExpenseEntity.fromFirestore(data, data['id'] as String? ?? '');
  }
}
