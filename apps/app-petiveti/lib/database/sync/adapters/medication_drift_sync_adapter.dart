import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/medications/domain/entities/sync_medication_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/medications_table.dart';

/// Adapter de sincronização para Medications
class MedicationDriftSyncAdapter
    extends DriftSyncAdapterBase<dynamic, Medication> {
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
  Insertable<Medication> entityToCompanion(dynamic entity) {
    final medicationEntity = entity as MedicationEntity;
    return MedicationsCompanion(
      id: medicationEntity.id != null && medicationEntity.id!.isNotEmpty
          ? Value(int.parse(medicationEntity.id!))
          : const Value.absent(),
      firebaseId: Value(medicationEntity.firebaseId),
      userId: Value(medicationEntity.userId),
      animalId: Value(medicationEntity.animalId),
      name: Value(medicationEntity.name),
      dosage: Value(medicationEntity.dosage),
      frequency: Value(medicationEntity.frequency),
      startDate: Value(medicationEntity.startDate),
      endDate: Value(medicationEntity.endDate),
      notes: Value(medicationEntity.notes),
      veterinarian: Value(medicationEntity.veterinarian),
      createdAt: Value(medicationEntity.createdAt),
      updatedAt: Value(medicationEntity.updatedAt),
      isDeleted: Value(medicationEntity.isDeleted),
      lastSyncAt: Value(medicationEntity.lastSyncAt),
      isDirty: Value(medicationEntity.isDirty),
      version: Value(medicationEntity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(dynamic entity) {
    final medicationEntity = entity as MedicationEntity;
    return medicationEntity.toFirestore();
  }

  @override
  dynamic fromFirestoreDoc(Map<String, dynamic> data) {
    return MedicationEntity.fromFirestore(data, data['id'] as String);
  }
}
