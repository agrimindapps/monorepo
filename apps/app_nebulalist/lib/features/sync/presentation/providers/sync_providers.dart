import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/task_sync_service.dart';
import '../../data/services/list_sync_service.dart';
import '../../../tasks/data/datasources/task_local_data_source.dart';
import '../../../tasks/data/datasources/task_remote_data_source.dart';
import '../../../lists/data/datasources/list_local_data_source.dart';
import '../../../lists/data/datasources/list_remote_data_source.dart';

part 'sync_providers.g.dart';

@riverpod
TaskSyncService taskSyncService(TaskSyncServiceRef ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  final remoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  
  return TaskSyncService(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
}

@riverpod
ListSyncService listSyncService(ListSyncServiceRef ref) {
  final localDataSource = ref.watch(listLocalDataSourceProvider);
  final remoteDataSource = ref.watch(listRemoteDataSourceProvider);
  
  return ListSyncService(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
}

/// Provider para controlar o estado de sincronização
@riverpod
class SyncState extends _$SyncState {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Sincroniza todas as entidades
  Future<void> syncAll() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final taskSyncService = ref.read(taskSyncServiceProvider);
      final listSyncService = ref.read(listSyncServiceProvider);
      
      // Sincronizar listas primeiro (dependência)
      await listSyncService.syncAll();
      
      // Depois sincronizar tarefas
      await taskSyncService.syncAll();
    });
  }

  /// Sincroniza apenas tasks
  Future<void> syncTasks() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final taskSyncService = ref.read(taskSyncServiceProvider);
      await taskSyncService.syncAll();
    });
  }

  /// Sincroniza apenas lists
  Future<void> syncLists() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final listSyncService = ref.read(listSyncServiceProvider);
      await listSyncService.syncAll();
    });
  }
}

/// Provider para auto-sync (executado periodicamente)
@riverpod
class AutoSync extends _$AutoSync {
  @override
  bool build() {
    return false;
  }

  void enable() {
    state = true;
    _startAutoSync();
  }

  void disable() {
    state = false;
  }

  void _startAutoSync() {
    if (!state) return;
    
    // Sync a cada 5 minutos
    Future.delayed(const Duration(minutes: 5), () {
      if (state) {
        ref.read(syncStateProvider.notifier).syncAll();
        _startAutoSync();
      }
    });
  }
}
