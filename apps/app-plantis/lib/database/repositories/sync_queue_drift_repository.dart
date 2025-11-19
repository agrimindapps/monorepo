import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../plantis_database.dart' as db;

/// Repository Drift para SyncQueue (fila de operações pendentes de sincronização)
@lazySingleton
class SyncQueueDriftRepository {
  final db.PlantisDatabase _db;

  SyncQueueDriftRepository(this._db);

  Future<int> enqueue({
    required String modelType,
    required String modelId,
    required String operation,
    String? data,
  }) async {
    final now = DateTime.now();
    final companion = db.PlantsSyncQueueCompanion.insert(
      modelType: modelType,
      modelId: modelId,
      operation: operation,
      data: data ?? '',
      timestamp: now,
      createdAt: now.millisecondsSinceEpoch,
      attempts: const Value(0),
      lastAttemptAt: const Value(null),
      error: const Value(null),
    );

    return await _db.into(_db.plantsSyncQueue).insert(companion);
  }

  Future<List<db.PlantsSyncQueueData>> getPendingItems({int limit = 50}) async {
    return (_db.select(_db.plantsSyncQueue)
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.timestamp)])
          ..limit(limit))
        .get();
  }

  Future<bool> markAsSynced(int id) async {
    final updated =
        await (_db.update(_db.plantsSyncQueue)..where((s) => s.id.equals(id)))
            .write(const db.PlantsSyncQueueCompanion(isSynced: Value(true)));

    return updated > 0;
  }

  Future<void> incrementSyncAttempts(int id, String? errorMessage) async {
    final item = await (_db.select(
      _db.plantsSyncQueue,
    )..where((s) => s.id.equals(id))).getSingleOrNull();

    if (item != null) {
      await (_db.update(
        _db.plantsSyncQueue,
      )..where((s) => s.id.equals(id))).write(
        db.PlantsSyncQueueCompanion(
          attempts: Value(item.attempts + 1),
          lastAttemptAt: Value(DateTime.now()),
          error: Value(errorMessage),
        ),
      );
    }
  }

  Future<void> clearSyncedItems() async {
    await (_db.delete(
      _db.plantsSyncQueue,
    )..where((s) => s.isSynced.equals(true))).go();
  }

  Future<int> countPendingItems() async {
    final count = _db.plantsSyncQueue.id.count();
    final query = _db.selectOnly(_db.plantsSyncQueue)
      ..addColumns([count])
      ..where(_db.plantsSyncQueue.isSynced.equals(false));

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Contagem de itens sincronizados
  Future<int> countSyncedItems() async {
    final count = _db.plantsSyncQueue.id.count();
    final query = _db.selectOnly(_db.plantsSyncQueue)
      ..addColumns([count])
      ..where(_db.plantsSyncQueue.isSynced.equals(true));

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Contagem de itens que falharam (excederam max retries)
  Future<int> countFailedItems({int maxRetries = 3}) async {
    final count = _db.plantsSyncQueue.id.count();
    final query = _db.selectOnly(_db.plantsSyncQueue)
      ..addColumns([count])
      ..where(
        _db.plantsSyncQueue.attempts.isBiggerOrEqualValue(maxRetries) &
            _db.plantsSyncQueue.isSynced.equals(false),
      );

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Limpar todos os itens (útil para testes)
  Future<void> deleteAll() async {
    await _db.delete(_db.plantsSyncQueue).go();
  }

  /// Obter itens falhados que excederam max retries
  Future<List<db.PlantsSyncQueueData>> getFailedItems({
    int maxRetries = 3,
    int limit = 50,
  }) async {
    return (_db.select(_db.plantsSyncQueue)
          ..where(
            (s) =>
                s.attempts.isBiggerOrEqualValue(maxRetries) &
                s.isSynced.equals(false),
          )
          ..orderBy([
            (s) => OrderingTerm.desc(s.lastAttemptAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Watch stream de itens pendentes para updates em tempo real
  Stream<List<db.PlantsSyncQueueData>> watchPendingItems({int limit = 50}) {
    return (_db.select(_db.plantsSyncQueue)
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.timestamp)])
          ..limit(limit))
        .watch();
  }
}
