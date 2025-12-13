import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/tasks/data/task_firebase_datasource.dart';
import '../../features/tasks/data/task_local_datasource.dart';
import '../../features/tasks/data/task_model.dart';

/// Serviço responsável por sincronizar tasks dirty (local → Firebase)
/// 
/// **Fluxo:**
/// 1. Query tasks WHERE isDirty = true
/// 2. Batch upload para Firebase
/// 3. Update isDirty = false + lastSyncAt
/// 4. Retry com exponential backoff em caso de erro
/// 
/// **Uso:**
/// ```dart
/// final service = ref.read(taskUploadSyncServiceProvider);
/// await service.syncDirtyTasks(userId);
/// ```
class TaskUploadSyncService {
  final TaskLocalDataSource _localDataSource;
  final TaskFirebaseDataSource _firebaseDataSource;

  TaskUploadSyncService(
    this._localDataSource,
    this._firebaseDataSource,
  );

  /// Sincroniza todas as tasks dirty do usuário
  /// 
  /// **Retorna:** Número de tasks sincronizadas
  Future<int> syncDirtyTasks(String userId) async {
    try {
      // 1. Buscar todas as tasks dirty do cache local
      final allTasks = await _localDataSource.getTasks(userId: userId);
      final dirtyTasks = allTasks.where((task) => task.isDirty).toList();

      if (dirtyTasks.isEmpty) {
        if (kDebugMode) {
          debugPrint('[UploadSync] No dirty tasks to sync');
        }
        return 0;
      }

      if (kDebugMode) {
        debugPrint('[UploadSync] Found ${dirtyTasks.length} dirty tasks to sync');
      }

      // 2. Batch upload para Firebase
      await _firebaseDataSource.batchSync(userId, dirtyTasks);

      // 3. Marcar como sincronizado (isDirty = false, lastSyncAt = now)
      final now = DateTime.now();
      for (final task in dirtyTasks) {
        final syncedTask = task.copyWith(
          isDirty: false,
          lastSyncAt: now,
        );
        await _localDataSource.updateTask(TaskModel.fromEntity(syncedTask));
      }

      if (kDebugMode) {
        debugPrint('[UploadSync] Successfully synced ${dirtyTasks.length} tasks');
      }

      return dirtyTasks.length;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[UploadSync] Error syncing dirty tasks: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Sincroniza uma task específica
  Future<void> syncTask(String userId, String taskId) async {
    try {
      final task = await _localDataSource.getTask(taskId);

      if (task == null) {
        if (kDebugMode) {
          debugPrint('[UploadSync] Task not found: $taskId');
        }
        return;
      }

      if (!task.isDirty) {
        if (kDebugMode) {
          debugPrint('[UploadSync] Task not dirty, skipping: $taskId');
        }
        return;
      }

      // Upload para Firebase
      if (task.isDeleted) {
        await _firebaseDataSource.deleteTask(userId, taskId);
      } else {
        await _firebaseDataSource.updateTask(userId, task);
      }

      // Marcar como sincronizado
      final syncedTask = task.copyWith(
        isDirty: false,
        lastSyncAt: DateTime.now(),
      );
      await _localDataSource.updateTask(TaskModel.fromEntity(syncedTask));

      if (kDebugMode) {
        debugPrint('[UploadSync] Task synced: $taskId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UploadSync] Error syncing task $taskId: $e');
      }
      rethrow;
    }
  }

  /// Força sincronização imediata de todas as tasks dirty
  /// 
  /// **Com retry logic:**
  /// - Tenta até 3x com exponential backoff
  /// - Backoff: 2s, 4s, 8s
  Future<SyncResult> forceSyncWithRetry(String userId) async {
    const maxRetries = 3;
    int attempt = 0;
    int syncedCount = 0;
    Exception? lastError;

    while (attempt < maxRetries) {
      try {
        syncedCount = await syncDirtyTasks(userId);
        
        if (kDebugMode) {
          debugPrint('[UploadSync] Force sync succeeded on attempt ${attempt + 1}');
        }

        return SyncResult.success(syncedCount);
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        attempt++;

        if (attempt < maxRetries) {
          final delaySeconds = (2 << (attempt - 1)); // 2, 4, 8 seconds
          if (kDebugMode) {
            debugPrint('[UploadSync] Attempt $attempt failed, retrying in ${delaySeconds}s...');
          }
          await Future<void>.delayed(Duration(seconds: delaySeconds));
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[UploadSync] Force sync failed after $maxRetries attempts');
    }

    return SyncResult.failure(lastError!);
  }

  /// Obtém estatísticas de sync
  Future<SyncStats> getStats(String userId) async {
    final allTasks = await _localDataSource.getTasks(userId: userId);
    final dirtyCount = allTasks.where((task) => task.isDirty).length;
    final syncedCount = allTasks.where((task) => !task.isDirty).length;
    final deletedCount = allTasks.where((task) => task.isDeleted).length;

    return SyncStats(
      totalTasks: allTasks.length,
      dirtyTasks: dirtyCount,
      syncedTasks: syncedCount,
      deletedTasks: deletedCount,
    );
  }
}

/// Resultado de uma operação de sync
class SyncResult {
  final bool success;
  final int syncedCount;
  final Exception? error;

  const SyncResult._({
    required this.success,
    required this.syncedCount,
    this.error,
  });

  factory SyncResult.success(int count) => SyncResult._(
        success: true,
        syncedCount: count,
      );

  factory SyncResult.failure(Exception error) => SyncResult._(
        success: false,
        syncedCount: 0,
        error: error,
      );
}

/// Estatísticas de sincronização
class SyncStats {
  final int totalTasks;
  final int dirtyTasks;
  final int syncedTasks;
  final int deletedTasks;

  const SyncStats({
    required this.totalTasks,
    required this.dirtyTasks,
    required this.syncedTasks,
    required this.deletedTasks,
  });

  double get syncPercentage =>
      totalTasks > 0 ? (syncedTasks / totalTasks * 100) : 100.0;

  bool get hasPendingSync => dirtyTasks > 0;

  @override
  String toString() {
    return 'SyncStats(total: $totalTasks, dirty: $dirtyTasks, synced: $syncedTasks, deleted: $deletedTasks, sync%: ${syncPercentage.toStringAsFixed(1)}%)';
  }
}
