import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/services/task_upload_sync_service.dart';
import '../data/task_firebase_datasource.dart';
import '../data/task_firebase_datasource_impl.dart';
import '../data/task_local_datasource.dart';
import '../data/task_local_datasource_impl.dart';
import '../data/task_repository_impl.dart';
import '../domain/create_task.dart';
import '../domain/create_task_with_limits.dart';
import '../domain/delete_task.dart';
import '../domain/get_subtasks.dart';
import '../domain/get_tasks.dart';
import '../domain/reorder_tasks.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';
import '../domain/update_task.dart';
import '../domain/usecases/create_next_recurrence_usecase.dart';
import '../domain/watch_tasks.dart';

part 'task_providers.g.dart';

// ============================================================================
// DATA LAYER
// ============================================================================

/// Provider para TaskLocalDataSource
@riverpod
TaskLocalDataSource taskLocalDataSource(Ref ref) {
  final database = ref.watch(taskolistDatabaseProvider);
  return TaskLocalDataSourceImpl(database);
}

/// Provider para TaskFirebaseDataSource
@riverpod
TaskFirebaseDataSource taskFirebaseDataSource(Ref ref) {
  return TaskFirebaseDataSourceImpl();
}

/// Provider para TaskUploadSyncService
@riverpod
TaskUploadSyncService taskUploadSyncService(Ref ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  final firebaseDataSource = ref.watch(taskFirebaseDataSourceProvider);
  return TaskUploadSyncService(localDataSource, firebaseDataSource);
}

/// Provider para TaskRepository
@riverpod
TaskRepository taskRepository(Ref ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  final dataIntegrityService = ref.watch(dataIntegrityServiceProvider);
  final uploadSyncService = ref.watch(taskUploadSyncServiceProvider);
  return TaskRepositoryImpl(
    localDataSource,
    dataIntegrityService,
    uploadSyncService,
  );
}

// ============================================================================
// DOMAIN LAYER - USE CASES
// ============================================================================

/// Provider para CreateTask use case
@riverpod
CreateTask createTask(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTask(repository);
}

/// Provider para CreateTaskWithLimits use case
@riverpod
CreateTaskWithLimits createTaskWithLimits(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  final getTasks = ref.watch(getTasksProvider);
  return CreateTaskWithLimits(repository, subscriptionService, getTasks);
}

/// Provider para DeleteTask use case
@riverpod
DeleteTask deleteTask(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTask(repository);
}

/// Provider para GetTasks use case
@riverpod
GetTasks getTasks(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasks(repository);
}

/// Provider para GetSubtasks use case
@riverpod
GetSubtasks getSubtasks(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetSubtasks(repository);
}

/// Provider para ReorderTasks use case
@riverpod
ReorderTasks reorderTasks(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return ReorderTasks(repository);
}

/// Provider para UpdateTask use case
@riverpod
UpdateTask updateTask(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return UpdateTask(repository);
}

/// Provider para WatchTasks use case
@riverpod
WatchTasks watchTasks(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return WatchTasks(repository);
}

/// Provider para CreateNextRecurrenceUseCase use case
@riverpod
CreateNextRecurrenceUseCase createNextRecurrence(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateNextRecurrenceUseCase(repository);
}

// ============================================================================
// PRESENTATION LAYER - DATA PROVIDERS
// ============================================================================

/// Provider para obter uma task por ID
@riverpod
Future<TaskEntity?> getTaskById(Ref ref, String taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  final result = await repository.getTask(taskId);
  return result.fold(
    (failure) => null,
    (task) => task,
  );
}
