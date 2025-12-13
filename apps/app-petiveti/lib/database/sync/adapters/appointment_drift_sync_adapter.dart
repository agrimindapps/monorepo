import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/appointments/domain/entities/sync_appointment_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/appointments_table.dart';

/// Adapter de sincronização para Appointments
class AppointmentDriftSyncAdapter
    extends DriftSyncAdapterBase<dynamic, Appointment> {
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
  Insertable<Appointment> entityToCompanion(dynamic entity) {
    final appointmentEntity = entity as AppointmentEntity;
    return AppointmentsCompanion(
      id: appointmentEntity.id != null && appointmentEntity.id!.isNotEmpty
          ? Value(int.parse(appointmentEntity.id!))
          : const Value.absent(),
      firebaseId: Value(appointmentEntity.firebaseId),
      userId: Value(appointmentEntity.userId),
      animalId: Value(appointmentEntity.animalId),
      title: Value(appointmentEntity.title),
      description: Value(appointmentEntity.description),
      appointmentDateTime: Value(appointmentEntity.appointmentDateTime),
      veterinarian: Value(appointmentEntity.veterinarian),
      location: Value(appointmentEntity.location),
      notes: Value(appointmentEntity.notes),
      status: Value(appointmentEntity.status),
      createdAt: Value(appointmentEntity.createdAt),
      updatedAt: Value(appointmentEntity.updatedAt),
      isDeleted: Value(appointmentEntity.isDeleted),
      lastSyncAt: Value(appointmentEntity.lastSyncAt),
      isDirty: Value(appointmentEntity.isDirty),
      version: Value(appointmentEntity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(dynamic entity) {
    final appointmentEntity = entity as AppointmentEntity;
    return appointmentEntity.toFirestore();
  }

  @override
  dynamic fromFirestoreDoc(Map<String, dynamic> data) {
    return AppointmentEntity.fromFirestore(data, data['id'] as String);
  }
}
