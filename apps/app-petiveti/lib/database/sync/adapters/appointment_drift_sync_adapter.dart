import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/appointments/domain/entities/sync_appointment_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/appointments_table.dart';

/// Adapter de sincronização para Appointments
class AppointmentDriftSyncAdapter
    extends DriftSyncAdapterBase<AppointmentEntity, Appointment> {
  AppointmentDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'appointments';

  @override
  TableInfo<Appointments, Appointment> get table => localDb.appointments;

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.appointments)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar appointments dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.appointments,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        AppointmentsCompanion(
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
        CacheFailure('Erro ao marcar appointment como sincronizado: $e'),
      );
    }
  }

  @override
  AppointmentEntity driftToEntity(Appointment row) {
    return AppointmentEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      animalId: row.animalId,
      title: row.title,
      description: row.description,
      appointmentDateTime: row.appointmentDateTime,
      veterinarian: row.veterinarian,
      location: row.location,
      notes: row.notes,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<Appointment> entityToCompanion(AppointmentEntity entity) {
    return AppointmentsCompanion(
      id: entity.id.isNotEmpty
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      animalId: Value(entity.animalId),
      title: Value(entity.title),
      description: Value(entity.description),
      appointmentDateTime: Value(entity.appointmentDateTime),
      veterinarian: Value(entity.veterinarian),
      location: Value(entity.location),
      notes: Value(entity.notes),
      status: Value(entity.status),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt),
      isDeleted: Value(entity.isDeleted),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(AppointmentEntity entity) {
    return entity.toFirestore();
  }

  @override
  AppointmentEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return AppointmentEntity.fromFirestore(data, data['id'] as String? ?? '');
  }
}
