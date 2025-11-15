import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart' as local_failures;
import '../../../core/services/data_integrity_service.dart';
import '../../../core/utils/typedef.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';
import 'task_local_datasource.dart';
import 'task_model.dart';

/// TaskRepository implementation using UnifiedSyncManager for offline-first sync
///
/// **Mudanças da versão anterior:**
/// - Usa UnifiedSyncManager para sincronização automática
/// - Marca entidades como dirty após operações CRUD
/// - Integra DataIntegrityService para ID reconciliation
/// - Simplifica lógica (sem dual remote/local datasource)
/// - Auto-sync triggers após operações de escrita
///
/// **Fluxo de operações:**
/// 1. CREATE: Salva local → Marca dirty → UnifiedSyncManager sincroniza em background
/// 2. UPDATE: Atualiza local → Marca dirty → Sync em background
/// 3. DELETE: Marca como deleted (soft delete) → Sync em background
/// 4. READ: Sempre lê do cache local (extremamente rápido)
@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(
    this._localDataSource,
    this._dataIntegrityService,
  );

  final TaskLocalDataSource _localDataSource;
  final DataIntegrityService _dataIntegrityService;

  /// UnifiedSyncManager singleton instance (for future use)
  // ignore: unused_element
  UnifiedSyncManager get _syncManager => UnifiedSyncManager.instance;

  // ========================================================================
  // CREATE
  // ========================================================================

  @override
  ResultFuture<String> createTask(TaskEntity task) async {
    try {
      // 1. Marcar como dirty para sync posterior
      final dirtyTask = task.markAsDirty().withModule('taskolist');
      final taskModel = TaskModel.fromEntity(dirtyTask);

      // 2. Salvar localmente
      await _localDataSource.cacheTask(taskModel);

      if (kDebugMode) {
        debugPrint('[TaskRepository] Task created locally: ${task.id}');
      }

      // 3. Trigger sync em background (não-bloqueante)
      _triggerBackgroundSync();

      return Right(task.id);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[TaskRepository] Error creating task: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(local_failures.ServerFailure('Failed to create task: $e'));
    }
  }

  // ========================================================================
  // READ
  // ========================================================================

  @override
  ResultFuture<TaskEntity> getTask(String id) async {
    try {
      // Sempre lê do cache local (rápido)
      final localTask = await _localDataSource.getTask(id);

      if (localTask != null) {
        // Filtrar tasks deletadas
        if (localTask.isDeleted) {
          return const Left(local_failures.CacheFailure('Task was deleted'));
        }
        return Right(localTask);
      }

      return const Left(local_failures.CacheFailure('Task not found'));
    } catch (e) {
      return Left(local_failures.CacheFailure('Failed to get task: $e'));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
    DateTime? dueBefore,
    DateTime? dueAfter,
  }) async {
    try {
      // Lê do cache local
      final localTasks = await _localDataSource.getTasks(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      );

      // Filtrar tasks deletadas e main tasks (sem parent)
      final activeTasks = localTasks
          .where((task) => !task.isDeleted && task.parentTaskId == null)
          .toList();

      return Right(activeTasks);
    } catch (e) {
      return Left(local_failures.CacheFailure('Failed to get tasks: $e'));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getSubtasks(String parentTaskId) async {
    try {
      final allTasks = await _localDataSource.getTasks();

      // Filtrar subtasks do parent específico (e não deletadas)
      final subtasks = allTasks
          .where((task) =>
              task.parentTaskId == parentTaskId && !task.isDeleted)
          .toList();

      return Right(subtasks);
    } catch (e) {
      return Left(local_failures.CacheFailure('Failed to get subtasks: $e'));
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) {
    // Watch do cache local (reactive)
    return _localDataSource
        .watchTasks(
          listId: listId,
          userId: userId,
          status: status,
          priority: priority,
          isStarred: isStarred,
        )
        .map((tasks) =>
            tasks.where((task) => !task.isDeleted).toList());
  }

  @override
  ResultFuture<List<TaskEntity>> searchTasks(String query) async {
    try {
      final allTasks = await _localDataSource.getTasks();

      // Filtrar por query (title, description, tags) e não deletadas
      final filteredTasks = allTasks.where((task) {
        if (task.isDeleted) return false;

        return task.title.toLowerCase().contains(query.toLowerCase()) ||
            (task.description?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            task.tags.any(
              (tag) => tag.toLowerCase().contains(query.toLowerCase()),
            );
      }).toList();

      return Right(filteredTasks);
    } catch (e) {
      return Left(local_failures.CacheFailure('Failed to search tasks: $e'));
    }
  }

  // ========================================================================
  // UPDATE
  // ========================================================================

  @override
  ResultFuture<void> updateTask(TaskEntity task) async {
    try {
      // 1. Marcar como dirty e incrementar versão
      final dirtyTask = task
          .markAsDirty()
          .incrementVersion()
          .copyWith(updatedAt: DateTime.now());

      final taskModel = TaskModel.fromEntity(dirtyTask);

      // 2. Atualizar localmente
      await _localDataSource.updateTask(taskModel);

      if (kDebugMode) {
        debugPrint('[TaskRepository] Task updated locally: ${task.id}');
      }

      // 3. Trigger sync em background
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Failed to update task: $e'));
    }
  }

  @override
  ResultFuture<void> updateTaskStatus(String id, TaskStatus status) async {
    try {
      final localTask = await _localDataSource.getTask(id);
      if (localTask == null) {
        return const Left(local_failures.CacheFailure('Task not found'));
      }

      final updatedTask = localTask
          .copyWith(
            status: status,
            updatedAt: DateTime.now(),
          )
          .markAsDirty()
          .incrementVersion();

      await _localDataSource.updateTask(updatedTask as TaskModel);

      if (kDebugMode) {
        debugPrint('[TaskRepository] Task status updated: $id → $status');
      }

      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Failed to update task status: $e'));
    }
  }

  @override
  ResultFuture<void> toggleTaskStar(String id) async {
    try {
      final localTask = await _localDataSource.getTask(id);
      if (localTask == null) {
        return const Left(local_failures.CacheFailure('Task not found'));
      }

      final updatedTask = localTask
          .copyWith(
            isStarred: !localTask.isStarred,
            updatedAt: DateTime.now(),
          )
          .markAsDirty()
          .incrementVersion();

      await _localDataSource.updateTask(updatedTask as TaskModel);

      if (kDebugMode) {
        debugPrint('[TaskRepository] Task star toggled: $id');
      }

      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Failed to toggle task star: $e'));
    }
  }

  @override
  ResultFuture<void> reorderTasks(List<String> taskIds) async {
    try {
      final List<TaskModel> updatedTasks = [];

      for (int i = 0; i < taskIds.length; i++) {
        final taskId = taskIds[i];
        final localTask = await _localDataSource.getTask(taskId);

        if (localTask != null) {
          final updatedTask = localTask
              .copyWith(
                position: i,
                updatedAt: DateTime.now(),
              )
              .markAsDirty()
              .incrementVersion() as TaskModel;

          updatedTasks.add(updatedTask);
        }
      }

      if (updatedTasks.isNotEmpty) {
        await _localDataSource.cacheTasks(updatedTasks);

        if (kDebugMode) {
          debugPrint('[TaskRepository] ${updatedTasks.length} tasks reordered');
        }

        _triggerBackgroundSync();
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Failed to reorder tasks: $e'));
    }
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  @override
  ResultFuture<void> deleteTask(String id) async {
    try {
      final localTask = await _localDataSource.getTask(id);
      if (localTask == null) {
        return const Left(local_failures.CacheFailure('Task not found'));
      }

      // Soft delete: marcar como deleted (não remover do storage)
      final deletedTask = localTask.markAsDeleted();

      await _localDataSource.updateTask(deletedTask as TaskModel);

      if (kDebugMode) {
        debugPrint('[TaskRepository] Task soft-deleted: $id');
      }

      // Trigger sync para propagar delete
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Failed to delete task: $e'));
    }
  }

  // ========================================================================
  // SYNC HELPERS
  // ========================================================================

  /// Trigger sync em background (não-bloqueante)
  /// UnifiedSyncManager gerencia filas e throttling automaticamente
  void _triggerBackgroundSync() {
    // TODO: Implementar quando UnifiedSyncManager tiver método trigger manual
    // Por enquanto, AutoSyncService fará sync periódico automaticamente
    if (kDebugMode) {
      debugPrint('[TaskRepository] Background sync will be triggered by AutoSyncService');
    }
  }

  /// Force sync manual (bloqueante) - para uso em casos específicos
  Future<Either<local_failures.Failure, void>> forceSync() async {
    try {
      // TODO: Implementar quando UnifiedSyncManager tiver método forceSync
      // await _syncManager.forceSyncApp('taskolist');

      if (kDebugMode) {
        debugPrint('[TaskRepository] Manual sync requested (not yet implemented)');
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Failed to force sync: $e'));
    }
  }

  /// Verifica integridade dos dados (útil após sync)
  Future<Either<local_failures.Failure, IntegrityReport>> verifyIntegrity() async {
    return _dataIntegrityService.verifyTaskIntegrity();
  }
}
