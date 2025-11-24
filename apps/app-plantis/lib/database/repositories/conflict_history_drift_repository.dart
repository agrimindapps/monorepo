import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/data/models/conflict_history_model.dart';
import '../plantis_database.dart' as db;

/// Repository Drift para ConflictHistory (auditoria de conflitos de sync)
///
/// TODO: This repository needs significant refactoring to align ConflictHistoryModel
/// with the ConflictHistory table schema. Temporarily simplified for migration.
class ConflictHistoryDriftRepository {
  final db.PlantisDatabase _db;

  ConflictHistoryDriftRepository(this._db);

  Future<int> logConflict(ConflictHistoryModel model) async {
    final companion = db.ConflictHistoryCompanion.insert(
      firebaseId: Value(model.id),
      modelType: model.modelType,
      modelId: model.modelId,
      localVersion: 1, // ConflictHistoryModel doesn't store versions
      remoteVersion: 1,
      resolutionStrategy: model.resolutionStrategy,
      localData: jsonEncode(model.localData),
      remoteData: jsonEncode(model.remoteData),
      resolvedData: jsonEncode(model.resolvedData),
      occurredAt: model.createdAtMs ?? DateTime.now().millisecondsSinceEpoch,
      resolvedAt: Value(model.updatedAtMs),
      autoResolved: Value(model.autoResolved),
      createdAt: Value(model.createdAt ?? DateTime.now()),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      version: Value(model.version),
      userId: Value(model.userId),
      moduleName: Value(model.moduleName ?? 'plantis'),
    );

    return await _db.into(_db.conflictHistory).insert(companion);
  }

  Future<List<ConflictHistoryModel>> getConflictHistory({
    String? modelType,
    bool resolvedOnly = false,
  }) async {
    final query = _db.select(_db.conflictHistory);

    if (modelType != null) {
      query.where((c) => c.modelType.equals(modelType));
    }

    if (resolvedOnly) {
      query.where((c) => c.resolvedAt.isNotNull());
    }

    query.orderBy([
      (c) => OrderingTerm.desc(c.occurredAt),
    ]);

    final conflicts = await query.get();
    return conflicts.map(_conflictDriftToModel).toList();
  }

  ConflictHistoryModel _conflictDriftToModel(db.ConflictHistoryData conflict) {
    return ConflictHistoryModel(
      id: conflict.firebaseId ?? conflict.id.toString(),
      modelType: conflict.modelType,
      modelId: conflict.modelId,
      resolutionStrategy: conflict.resolutionStrategy,
      localData: jsonDecode(conflict.localData) as Map<String, dynamic>,
      remoteData: jsonDecode(conflict.remoteData) as Map<String, dynamic>,
      resolvedData: jsonDecode(conflict.resolvedData) as Map<String, dynamic>,
      autoResolved: conflict.autoResolved,
      createdAtMs: conflict.createdAt?.millisecondsSinceEpoch,
      updatedAtMs: conflict.updatedAt?.millisecondsSinceEpoch,
      version: conflict.version,
      userId: conflict.userId,
      moduleName: conflict.moduleName,
    );
  }

  /// Marcar conflito como resolvido
  Future<bool> markAsResolved(String firebaseId, int resolvedAtMs) async {
    final updated = await (_db.update(
      _db.conflictHistory,
    )..where((c) => c.firebaseId.equals(firebaseId)))
        .write(
      db.ConflictHistoryCompanion(
        resolvedAt: Value(resolvedAtMs),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return updated > 0;
  }

  /// Obter conflitos não resolvidos
  Future<List<ConflictHistoryModel>> getUnresolvedConflicts() async {
    final conflicts = await (_db.select(_db.conflictHistory)
          ..where((c) => c.resolvedAt.isNull())
          ..orderBy([
            (c) => OrderingTerm.desc(c.occurredAt),
          ]))
        .get();

    return conflicts.map(_conflictDriftToModel).toList();
  }

  /// Limpar histórico de conflitos antigos (mais de 30 dias)
  Future<int> clearOldConflicts({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final cutoffMs = cutoffDate.millisecondsSinceEpoch;

    return await (_db.delete(
      _db.conflictHistory,
    )..where((c) => c.occurredAt.isSmallerThanValue(cutoffMs)))
        .go();
  }

  /// Contagem de conflitos não resolvidos
  Future<int> getUnresolvedCount() async {
    final count = _db.conflictHistory.id.count();
    final query = _db.selectOnly(_db.conflictHistory)
      ..addColumns([count])
      ..where(_db.conflictHistory.resolvedAt.isNull());

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Limpar todos os conflitos (útil para testes)
  Future<void> deleteAll() async {
    await _db.delete(_db.conflictHistory).go();
  }
}
