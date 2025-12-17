import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/sync_conflict.dart';
import '../../domain/entities/sync_operation.dart';
import '../models/sync_conflict_model.dart';
import '../models/sync_operation_model.dart';

/// Local data source for sync operations
/// Stores sync history and conflicts in local storage
abstract class SyncLocalDataSource {
  /// Save sync operation to history
  Future<void> saveSyncOperation(SyncOperation operation);

  /// Get sync history from local storage
  Future<List<SyncOperation>> getSyncHistory({
    int limit = 50,
    String? entityType,
  });

  /// Save sync conflict
  Future<void> saveSyncConflict(SyncConflict conflict);

  /// Get unresolved conflicts
  Future<List<SyncConflict>> getSyncConflicts({String? entityType});

  /// Remove resolved conflict
  Future<void> removeConflict(String conflictId);

  /// Clear sync history
  Future<void> clearHistory();
}

/// Implementation using SharedPreferences
class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  final SharedPreferences prefs;

  static const String _historyKey = 'sync_history';
  static const String _conflictsKey = 'sync_conflicts';

  SyncLocalDataSourceImpl(this.prefs);

  @override
  Future<void> saveSyncOperation(SyncOperation operation) async {
    final history = await getSyncHistory();
    final updatedHistory = [operation, ...history];

    // Keep only last 100 operations
    final limitedHistory = updatedHistory.take(100).toList();

    final jsonList = limitedHistory
        .map((op) => SyncOperationModel.fromEntity(op).toJson())
        .toList();

    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  @override
  Future<List<SyncOperation>> getSyncHistory({
    int limit = 50,
    String? entityType,
  }) async {
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    var operations = jsonList
        .map((json) => SyncOperationModel.fromJson(json as Map<String, dynamic>))
        .toList();

    if (entityType != null) {
      operations = operations.where((op) => op.entityType == entityType).toList();
    }

    return operations.take(limit).toList();
  }

  @override
  Future<void> saveSyncConflict(SyncConflict conflict) async {
    final conflicts = await getSyncConflicts();
    final updatedConflicts = [...conflicts, conflict];

    final jsonList = updatedConflicts
        .map((c) => SyncConflictModel.fromEntity(c).toJson())
        .toList();

    await prefs.setString(_conflictsKey, jsonEncode(jsonList));
  }

  @override
  Future<List<SyncConflict>> getSyncConflicts({String? entityType}) async {
    final jsonString = prefs.getString(_conflictsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    var conflicts = jsonList
        .map((json) => SyncConflictModel.fromJson(json as Map<String, dynamic>))
        .where((c) => !c.isResolved)
        .toList();

    if (entityType != null) {
      conflicts = conflicts.where((c) => c.entityType == entityType).toList();
    }

    return conflicts;
  }

  @override
  Future<void> removeConflict(String conflictId) async {
    final conflicts = await getSyncConflicts();
    final updatedConflicts = conflicts.where((c) => c.id != conflictId).toList();

    final jsonList = updatedConflicts
        .map((c) => SyncConflictModel.fromEntity(c).toJson())
        .toList();

    await prefs.setString(_conflictsKey, jsonEncode(jsonList));
  }

  @override
  Future<void> clearHistory() async {
    await prefs.remove(_historyKey);
  }
}
