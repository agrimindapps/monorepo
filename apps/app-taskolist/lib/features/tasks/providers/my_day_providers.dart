import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_providers.dart';
import '../../task_lists/providers/task_list_providers.dart';
import '../data/my_day_local_datasource.dart';
import '../data/my_day_local_datasource_impl.dart';
import '../data/my_day_repository_impl.dart';
import '../domain/add_task_to_my_day.dart';
import '../domain/clear_my_day.dart';
import '../domain/get_my_day_suggestions.dart';
import '../domain/get_my_day_tasks.dart';
import '../domain/my_day_repository.dart';
import '../domain/remove_task_from_my_day.dart';
import '../domain/watch_my_day_tasks.dart';
import 'task_providers.dart';

part 'my_day_providers.g.dart';

// ============================================================================
// DATA LAYER
// ============================================================================

/// Provider para MyDayLocalDataSource
@riverpod
MyDayLocalDataSource myDayLocalDataSource(Ref ref) {
  final database = ref.watch(taskolistDatabaseProvider);
  return MyDayLocalDataSourceImpl(database);
}

/// Provider para MyDayRepository
@riverpod
MyDayRepository myDayRepository(Ref ref) {
  final localDataSource = ref.watch(myDayLocalDataSourceProvider);
  final taskLocalDataSource = ref.watch(taskLocalDataSourceProvider);
  return MyDayRepositoryImpl(localDataSource, taskLocalDataSource);
}

// ============================================================================
// DOMAIN LAYER - USE CASES
// ============================================================================

/// Provider para AddTaskToMyDay use case
@riverpod
AddTaskToMyDay addTaskToMyDay(Ref ref) {
  final repository = ref.watch(myDayRepositoryProvider);
  return AddTaskToMyDay(repository);
}

/// Provider para RemoveTaskFromMyDay use case
@riverpod
RemoveTaskFromMyDay removeTaskFromMyDay(Ref ref) {
  final repository = ref.watch(myDayRepositoryProvider);
  return RemoveTaskFromMyDay(repository);
}

/// Provider para GetMyDayTasks use case
@riverpod
GetMyDayTasks getMyDayTasks(Ref ref) {
  final repository = ref.watch(myDayRepositoryProvider);
  return GetMyDayTasks(repository);
}

/// Provider para WatchMyDayTasks use case
@riverpod
WatchMyDayTasks watchMyDayTasks(Ref ref) {
  final repository = ref.watch(myDayRepositoryProvider);
  return WatchMyDayTasks(repository);
}

/// Provider para ClearMyDay use case
@riverpod
ClearMyDay clearMyDay(Ref ref) {
  final repository = ref.watch(myDayRepositoryProvider);
  return ClearMyDay(repository);
}

/// Provider para GetMyDaySuggestions use case
@riverpod
GetMyDaySuggestions getMyDaySuggestions(Ref ref) {
  final repository = ref.watch(myDayRepositoryProvider);
  return GetMyDaySuggestions(repository);
}

// ============================================================================
// PRESENTATION LAYER - NOTIFIERS
// ============================================================================

/// Notifier simplificado para adicionar tarefas ao Meu Dia
@riverpod
class MyDayNotifier extends _$MyDayNotifier {
  @override
  void build() {}

  Future<void> addTask(String taskId) async {
    final useCase = ref.read(addTaskToMyDayProvider);
    final userId = ref.read(currentUserIdProvider); // Assumindo que existe
    if (userId == null) return;
    
    await useCase.call(AddTaskToMyDayParams(
      taskId: taskId,
      userId: userId,
    ));
  }

  Future<void> removeTask(String taskId) async {
    final useCase = ref.read(removeTaskFromMyDayProvider);
    
    await useCase.call(RemoveTaskFromMyDayParams(
      taskId: taskId,
    ));
  }

  Future<void> clearAll() async {
    final useCase = ref.read(clearMyDayProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    await useCase.call(ClearMyDayParams(userId: userId));
  }
}
