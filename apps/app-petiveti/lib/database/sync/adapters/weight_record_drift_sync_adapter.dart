import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/weight/domain/entities/sync_weight_record_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/weight_records_table.dart';

/// Adapter de sincronização para Weight Records
class WeightRecordDriftSyncAdapter
    extends DriftSyncAdapterBase<WeightRecordEntity, WeightRecord> {
  WeightRecordDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'weight_records';

  @override
  TableInfo<WeightRecords, WeightRecord> get table => localDb.weightRecords;

  @override
  Future<Either<Failure, List<WeightRecordEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.weightRecords)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar weight records dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.weightRecords,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        WeightRecordsCompanion(
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
        CacheFailure('Erro ao marcar weight record como sincronizado: $e'),
      );
    }
  }

  @override
  WeightRecordEntity driftToEntity(WeightRecord row) {
    return WeightRecordEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      animalId: row.animalId,
      weight: row.weight,
      unit: row.unit,
      date: row.date,
      notes: row.notes,
      createdAt: row.createdAt,
      isDeleted: row.isDeleted,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<WeightRecord> entityToCompanion(WeightRecordEntity entity) {
    return WeightRecordsCompanion(
      id: entity.id.isNotEmpty && int.tryParse(entity.id) != null
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      animalId: Value(entity.animalId),
      weight: Value(entity.weight),
      unit: Value(entity.unit),
      date: Value(entity.date),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      isDeleted: Value(entity.isDeleted),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(WeightRecordEntity entity) {
    return entity.toFirestore();
  }

  @override
  WeightRecordEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return WeightRecordEntity.fromFirestore(data, data['id'] as String? ?? '');
  }
}
