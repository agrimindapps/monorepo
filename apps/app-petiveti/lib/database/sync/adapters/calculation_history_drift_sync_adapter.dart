import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../entities/sync_calculation_history_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/calculation_history_table.dart';

/// Adapter de sincronização para Calculation History
/// FIXME: Entity precisa estender BaseSyncEntity
class CalculationHistoryDriftSyncAdapter
    extends DriftSyncAdapterBase<dynamic, CalculationHistoryEntry> {
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
  Future<Either<Failure, List<dynamic>>> getDirtyRecords(String userId) async {
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
      id: row.id,
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
  Insertable<CalculationHistoryEntry> entityToCompanion(dynamic entity) {
    final historyEntity = entity as SyncCalculationHistoryEntity;
    return CalculationHistoryCompanion(
      id: historyEntity.id != null
          ? Value(historyEntity.id!)
          : const Value.absent(),
      firebaseId: Value(historyEntity.firebaseId),
      userId: Value(historyEntity.userId),
      calculatorType: Value(historyEntity.calculatorType),
      inputData: Value(historyEntity.inputData),
      result: Value(historyEntity.result),
      date: Value(historyEntity.date),
      isDeleted: Value(historyEntity.isDeleted),
      lastSyncAt: Value(historyEntity.lastSyncAt),
      isDirty: Value(historyEntity.isDirty),
      version: Value(historyEntity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(dynamic entity) {
    final historyEntity = entity as SyncCalculationHistoryEntity;
    return historyEntity.toFirestore();
  }

  @override
  dynamic fromFirestoreDoc(Map<String, dynamic> data) {
    // Note: fromFirestore expects DocumentSnapshot, but we receive Map
    // This adapter may need entity refactoring
    return SyncCalculationHistoryEntity(
      firebaseId: data['id'] as String?,
      userId: data['userId'] as String,
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
