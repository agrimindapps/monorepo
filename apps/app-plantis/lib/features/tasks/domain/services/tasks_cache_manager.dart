import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../entities/task.dart' as task_entity;
import '../usecases/get_tasks_usecase.dart';

/// Gerencia cache local e estratégia de loading para Tasks
///
/// Responsabilidades (SRP):
/// - Load local-first strategy (cache → network)
/// - Background sync coordination
/// - Cache invalidation
/// - Data freshness tracking
class TasksCacheManager {
  TasksCacheManager({required GetTasksUseCase getTasksUseCase})
    : _getTasksUseCase = getTasksUseCase;

  final GetTasksUseCase _getTasksUseCase;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  /// Cache freshness duration (5 minutes)
  static const _cacheDuration = Duration(minutes: 5);

  /// Check if cached data is still fresh
  bool get isCacheFresh {
    if (_lastSyncTime == null) return false;
    return DateTime.now().difference(_lastSyncTime!) < _cacheDuration;
  }

  /// Load tasks with local-first strategy
  ///
  /// Strategy:
  /// 1. Try loading from local cache first
  /// 2. Return cached data immediately if available
  /// 3. Sync with server in background if cache is stale
  Future<TasksLoadResult> loadLocalFirst() async {
    try {
      debugPrint('🔄 TasksCacheManager: Loading tasks (local-first)...');

      final result = await _getTasksUseCase(const NoParams());

      return await result.fold(
        (failure) async {
          debugPrint('❌ TasksCacheManager: Load failed - ${failure.message}');
          return TasksLoadResult.failure(failure.message);
        },
        (tasks) async {
          debugPrint('✅ TasksCacheManager: Loaded ${tasks.length} tasks');
          _lastSyncTime = DateTime.now();
          return TasksLoadResult.success(tasks);
        },
      );
    } catch (e) {
      debugPrint('❌ TasksCacheManager: Exception - $e');
      return TasksLoadResult.failure('Erro ao carregar tarefas: $e');
    }
  }

  /// Sync with server in background (fire and forget)
  ///
  /// This method:
  /// - Doesn't block UI
  /// - Updates cache timestamp on success
  /// - Ignores errors silently (we already have local data)
  Future<List<task_entity.Task>?> syncInBackground() async {
    if (_isSyncing) {
      debugPrint('⏭️ TasksCacheManager: Sync already in progress, skipping');
      return null;
    }

    try {
      _isSyncing = true;
      debugPrint('🔄 TasksCacheManager: Background sync started...');

      final result = await _getTasksUseCase(const NoParams());

      return result.fold(
        (failure) {
          debugPrint(
            '⚠️ TasksCacheManager: Background sync failed - ${failure.message}',
          );
          return null;
        },
        (tasks) {
          _lastSyncTime = DateTime.now();
          debugPrint(
            '✅ TasksCacheManager: Background sync successful - ${tasks.length} tasks',
          );
          return tasks;
        },
      );
    } catch (e) {
      debugPrint('⚠️ TasksCacheManager: Background sync exception - $e');
      return null;
    } finally {
      _isSyncing = false;
    }
  }

  /// Force refresh from server (explicit user action)
  ///
  /// Use this when user explicitly pulls to refresh
  Future<TasksLoadResult> forceRefresh() async {
    try {
      debugPrint('🔄 TasksCacheManager: Force refresh...');

      final result = await _getTasksUseCase(const NoParams());

      return result.fold(
        (failure) {
          debugPrint('❌ TasksCacheManager: Force refresh failed');
          return TasksLoadResult.failure(failure.message);
        },
        (tasks) {
          _lastSyncTime = DateTime.now();
          debugPrint('✅ TasksCacheManager: Force refresh successful');
          return TasksLoadResult.success(tasks);
        },
      );
    } catch (e) {
      return TasksLoadResult.failure('Erro ao atualizar tarefas: $e');
    }
  }

  /// Clear cache and force next load from network
  void clearCache() {
    _lastSyncTime = null;
    debugPrint('🗑️ TasksCacheManager: Cache cleared');
  }
}

/// Result type for tasks loading operations
///
/// Provides type-safe result handling with fold pattern
class TasksLoadResult {
  TasksLoadResult._({this.tasks, this.error});

  factory TasksLoadResult.success(List<task_entity.Task> tasks) {
    return TasksLoadResult._(tasks: tasks);
  }

  factory TasksLoadResult.failure(String error) {
    return TasksLoadResult._(error: error);
  }

  final List<task_entity.Task>? tasks;
  final String? error;

  /// Pattern matching for type-safe result handling
  T fold<T>({
    required T Function(List<task_entity.Task>) onSuccess,
    required T Function(String) onFailure,
  }) {
    if (tasks != null) {
      return onSuccess(tasks!);
    }
    return onFailure(error ?? 'Erro desconhecido');
  }
}
