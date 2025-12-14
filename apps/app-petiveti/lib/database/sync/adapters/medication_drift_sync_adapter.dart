import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/medications/domain/entities/sync_medication_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/medications_table.dart';

/// Adapter de sincronização para Medications
class MedicationDriftSyncAdapter
    extends DriftSyncAdapterBase<MedicationEntity, Medication> {
  MedicationDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'medications';

  @override
  TableInfo<Medications, Medication> get table => localDb.medications;

  @override
  Future<Either<Failure, List<MedicationEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.medications)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar medications dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.medications,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        MedicationsCompanion(
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
        CacheFailure('Erro ao marcar medication como sincronizado: $e'),
      );
    }
  }

  @override
  MedicationEntity driftToEntity(Medication row) {
    return MedicationEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      animalId: row.animalId,
      name: row.name,
      dosage: row.dosage,
      frequency: row.frequency,
      startDate: row.startDate,
      endDate: row.endDate,
      notes: row.notes,
      veterinarian: row.veterinarian,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<Medication> entityToCompanion(MedicationEntity entity) {
    return MedicationsCompanion(
      id: entity.id.isNotEmpty && int.tryParse(entity.id) != null
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      animalId: Value(entity.animalId),
      name: Value(entity.name),
      dosage: Value(entity.dosage),
      frequency: Value(entity.frequency),
      startDate: Value(entity.startDate),
      endDate: Value(entity.endDate),
      notes: Value(entity.notes),
      veterinarian: Value(entity.veterinarian),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt),
      isDeleted: Value(entity.isDeleted),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(MedicationEntity entity) {
    return entity.toFirestore();
  }

  @override
  MedicationEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return MedicationEntity.fromFirestore(data, data['id'] as String? ?? '');
  }
}
