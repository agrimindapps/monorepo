import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/task_sync_service.dart';
import '../../data/services/sync_coordinator.dart';
import '../../domain/entities/sync_status.dart';
import '../../data/models/task_model.dart';

part 'sync_providers.g.dart';

/// Provider do TaskSyncService
@riverpod
TaskSyncService taskSyncService(TaskSyncServiceRef ref) {
  return TaskSyncService();
}

/// Provider do SyncCoordinator
@riverpod
SyncCoordinator syncCoordinator(SyncCoordinatorRef ref) {
  final coordinator = SyncCoordinator(
    taskSyncService: ref.watch(taskSyncServiceProvider),
  );
  
  // Inicia sincronização automática
  coordinator.startAutoSync();
  
  // Cleanup ao descartar
  ref.onDispose(() {
    coordinator.dispose();
  });
  
  return coordinator;
}

/// Provider do status de sincronização atual
@riverpod
class CurrentSyncStatus extends _$CurrentSyncStatus {
  @override
  SyncStatus build() {
    final coordinator = ref.watch(syncCoordinatorProvider);
    return coordinator.currentStatus;
  }

  void updateStatus(SyncStatus status) {
    state = status;
  }
}

/// Provider para verificar se está sincronizando
@riverpod
bool isSyncing(IsSyncingRef ref) {
  final coordinator = ref.watch(syncCoordinatorProvider);
  return coordinator.isSyncing;
}

/// Provider para stream de tarefas do Firebase
@riverpod
Stream<List<TaskModel>> firebaseTasks(FirebaseTasksRef ref) {
  final syncService = ref.watch(taskSyncServiceProvider);
  return syncService.watchUserTasks();
}

/// Provider para sincronizar tarefa específica
@riverpod
class TaskSync extends _$TaskSync {
  @override
  FutureOr<SyncStatus?> build() {
    return null;
  }

  Future<void> syncTask(TaskModel task) async {
    state = const AsyncLoading();
    
    final coordinator = ref.read(syncCoordinatorProvider);
    final result = await coordinator.syncTask(task);
    
    state = AsyncData(result);
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncLoading();
    
    final coordinator = ref.read(syncCoordinatorProvider);
    final result = await coordinator.deleteTask(taskId);
    
    state = AsyncData(result);
  }
}

/// Provider para forçar sincronização completa
@riverpod
class FullSync extends _$FullSync {
  @override
  FutureOr<SyncStatus?> build() {
    return null;
  }

  Future<void> forceSync(List<TaskModel> localTasks) async {
    state = const AsyncLoading();
    
    final coordinator = ref.read(syncCoordinatorProvider);
    final result = await coordinator.forceFullSync(localTasks);
    
    state = AsyncData(result);
  }

  Future<void> syncNow() async {
    state = const AsyncLoading();
    
    final coordinator = ref.read(syncCoordinatorProvider);
    final result = await coordinator.syncNow();
    
    state = AsyncData(result);
  }
}
