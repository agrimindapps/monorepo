import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../entities/sync_calculation_history_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/calculation_history_table.dart';

/// Adapter de sincronização para Calculation History
class CalculationHistoryDriftSyncAdapter
    extends DriftSyncAdapterBase<SyncCalculationHistoryEntity, CalculationHistoryEntry> {
  CalculationHistoryDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'calculation_history';

  @override
  TableInfo<CalculationHistory, CalculationHistoryEntry> get table =>
      localDb.calculationHistory;

  @override
  Future<Either<Failure, List<SyncCalculationHistoryEntity>>> getDirtyRecords(String userId) async {
    try {
      final query = localDb.select(localDb.calculationHistory)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar calculation history dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.calculationHistory,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        CalculationHistoryCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
          firebaseId: firebaseId != null
              ? Value(firebaseId)
              : const Value.absent(),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao marcar calculation history como sincronizado: $e',
        ),
      );
    }
  }

  @override
  SyncCalculationHistoryEntity driftToEntity(CalculationHistoryEntry row) {
    return SyncCalculationHistoryEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      calculatorType: row.calculatorType,
      inputData: row.inputData,
      result: row.result,
      date: row.date,
      isDeleted: row.isDeleted,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<CalculationHistoryEntry> entityToCompanion(SyncCalculationHistoryEntity entity) {
    return CalculationHistoryCompanion(
      id: entity.id.isNotEmpty && int.tryParse(entity.id) != null
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      calculatorType: Value(entity.calculatorType),
      inputData: Value(entity.inputData),
      result: Value(entity.result),
      date: Value(entity.date),
      isDeleted: Value(entity.isDeleted),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(SyncCalculationHistoryEntity entity) {
    return entity.toFirestore();
  }

  @override
  SyncCalculationHistoryEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return SyncCalculationHistoryEntity(
      id: data['localId'] as String? ?? data['id'] as String? ?? '',
      firebaseId: data['id'] as String?,
      userId: data['userId'] as String? ?? '',
      calculatorType: data['calculatorType'] as String,
      inputData: data['inputData'] as String,
      result: data['result'] as String,
      date: (data['date'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: data['lastSyncAt'] != null
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
