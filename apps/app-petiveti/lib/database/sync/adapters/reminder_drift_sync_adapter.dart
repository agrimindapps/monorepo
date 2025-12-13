import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/reminders/domain/entities/sync_reminder_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/reminders_table.dart';

/// Adapter de sincronização para Reminders
class ReminderDriftSyncAdapter extends DriftSyncAdapterBase<dynamic, Reminder> {
  ReminderDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'reminders';

  @override
  TableInfo<Reminders, Reminder> get table => localDb.reminders;

  @override
  Future<Either<Failure, List<ReminderEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.reminders)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar reminders dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.reminders,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        RemindersCompanion(
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
        CacheFailure('Erro ao marcar reminder como sincronizado: $e'),
      );
    }
  }

  @override
  ReminderEntity driftToEntity(Reminder row) {
    return ReminderEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      animalId: row.animalId,
      title: row.title,
      description: row.description,
      reminderDateTime: row.reminderDateTime,
      frequency: row.frequency,
      isCompleted: row.isCompleted,
      notificationEnabled: row.notificationEnabled,
      createdAt: row.createdAt,
      isDeleted: row.isDeleted,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<Reminder> entityToCompanion(dynamic entity) {
    final reminderEntity = entity as ReminderEntity;
    return RemindersCompanion(
      id: reminderEntity.id != null && reminderEntity.id!.isNotEmpty
          ? Value(int.parse(reminderEntity.id!))
          : const Value.absent(),
      firebaseId: Value(reminderEntity.firebaseId),
      userId: Value(reminderEntity.userId),
      animalId: Value(reminderEntity.animalId),
      title: Value(reminderEntity.title),
      description: Value(reminderEntity.description),
      reminderDateTime: Value(reminderEntity.reminderDateTime),
      frequency: Value(reminderEntity.frequency),
      isCompleted: Value(reminderEntity.isCompleted),
      notificationEnabled: Value(reminderEntity.notificationEnabled),
      createdAt: Value(reminderEntity.createdAt),
      isDeleted: Value(reminderEntity.isDeleted),
      lastSyncAt: Value(reminderEntity.lastSyncAt),
      isDirty: Value(reminderEntity.isDirty),
      version: Value(reminderEntity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(dynamic entity) {
    final reminderEntity = entity as ReminderEntity;
    return reminderEntity.toFirestore();
  }

  @override
  dynamic fromFirestoreDoc(Map<String, dynamic> data) {
    return ReminderEntity.fromFirestore(data, data['id'] as String);
  }
}
