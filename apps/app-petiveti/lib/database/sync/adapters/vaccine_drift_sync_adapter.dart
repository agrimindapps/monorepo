import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/vaccines/domain/entities/sync_vaccine_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/vaccines_table.dart';

/// Adapter de sincronização para Vaccines
class VaccineDriftSyncAdapter extends DriftSyncAdapterBase<VaccineEntity, Vaccine> {
  VaccineDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'vaccines';

  @override
  TableInfo<Vaccines, Vaccine> get table => localDb.vaccines;

  @override
  Future<Either<Failure, List<VaccineEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.vaccines)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar vaccines dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.vaccines,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        VaccinesCompanion(
          isDirty: const Value(false),
          lastSyncAtTimestamp: Value(DateTime.now().millisecondsSinceEpoch),
          firebaseId: firebaseId != null
              ? Value(firebaseId)
              : const Value.absent(),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar vaccine como sincronizado: $e'));
    }
  }

  @override
  VaccineEntity driftToEntity(Vaccine row) {
    return VaccineEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      animalId: row.animalId,
      name: row.name,
      veterinarian: row.veterinarian,
      dateTimestamp: row.dateTimestamp,
      nextDueDateTimestamp: row.nextDueDateTimestamp,
      batch: row.batch,
      manufacturer: row.manufacturer,
      dosage: row.dosage,
      notes: row.notes,
      isRequired: row.isRequired,
      isCompleted: row.isCompleted,
      reminderDateTimestamp: row.reminderDateTimestamp,
      status: row.status,
      createdAtTimestamp: row.createdAtTimestamp,
      updatedAtTimestamp: row.updatedAtTimestamp,
      isDeleted: row.isDeleted,
      lastSyncAtTimestamp: row.lastSyncAtTimestamp,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<Vaccine> entityToCompanion(VaccineEntity entity) {
    return VaccinesCompanion(
      id: entity.id.isNotEmpty && int.tryParse(entity.id) != null
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      animalId: Value(entity.animalId),
      name: Value(entity.name),
      veterinarian: Value(entity.veterinarian),
      dateTimestamp: Value(entity.dateTimestamp),
      nextDueDateTimestamp: Value(entity.nextDueDateTimestamp),
      batch: Value(entity.batch),
      manufacturer: Value(entity.manufacturer),
      dosage: Value(entity.dosage),
      notes: Value(entity.notes),
      isRequired: Value(entity.isRequired),
      isCompleted: Value(entity.isCompleted),
      reminderDateTimestamp: Value(entity.reminderDateTimestamp),
      status: Value(entity.status),
      createdAtTimestamp: Value(entity.createdAtTimestamp),
      updatedAtTimestamp: Value(entity.updatedAtTimestamp),
      isDeleted: Value(entity.isDeleted),
      lastSyncAtTimestamp: Value(entity.lastSyncAtTimestamp),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(VaccineEntity entity) {
    return entity.toFirestore();
  }

  @override
  VaccineEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return VaccineEntity.fromFirestore(data, data['id'] as String? ?? '');
  }
}
