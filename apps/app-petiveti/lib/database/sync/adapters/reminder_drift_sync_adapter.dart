import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/reminders/domain/entities/sync_reminder_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/reminders_table.dart';

/// Adapter de sincronização para Reminders
class ReminderDriftSyncAdapter extends DriftSyncAdapterBase<ReminderEntity, ReminderRecord> {
  ReminderDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'reminders';

  @override
  TableInfo<Reminders, ReminderRecord> get table => localDb.reminders;

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
  ReminderEntity driftToEntity(ReminderRecord row) {
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
  Insertable<ReminderRecord> entityToCompanion(ReminderEntity entity) {
    return RemindersCompanion(
      id: entity.id.isNotEmpty && int.tryParse(entity.id) != null
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      animalId: Value(entity.animalId),
      title: Value(entity.title),
      description: Value(entity.description),
      reminderDateTime: Value(entity.reminderDateTime),
      frequency: Value(entity.frequency),
      isCompleted: Value(entity.isCompleted),
      notificationEnabled: Value(entity.notificationEnabled),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      isDeleted: Value(entity.isDeleted),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(ReminderEntity entity) {
    return entity.toFirestore();
  }

  @override
  ReminderEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return ReminderEntity.fromFirestore(data, data['id'] as String? ?? '');
  }
}
