import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/database/drift_database.dart';
import '../services/task_sync_service.dart';
import '../services/list_sync_service.dart';

part 'sync_providers.g.dart';

/// Provider do TaskSyncService
@riverpod
TaskSyncService taskSyncService(TaskSyncServiceRef ref) {
  final database = ref.watch(databaseProvider);
  return TaskSyncService(database);
}

/// Provider do ListSyncService
@riverpod
ListSyncService listSyncService(ListSyncServiceRef ref) {
  final database = ref.watch(databaseProvider);
  return ListSyncService(database);
}

/// Provider que monitora o status de sincronização global
@riverpod
class SyncStatus extends _$SyncStatus {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  /// Inicia sincronização completa
  Future<void> syncAll() async {
    state = const AsyncValue.loading();
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = const AsyncValue.data(false);
        return;
      }

      // Sincroniza tasks
      final taskSync = ref.read(taskSyncServiceProvider);
      await taskSync.syncTasks(user.uid);

      // Sincroniza lists
      final listSync = ref.read(listSyncServiceProvider);
      await listSync.syncLists(user.uid);

      state = const AsyncValue.data(true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Para a sincronização
  void stopSync() {
    final taskSync = ref.read(taskSyncServiceProvider);
    final listSync = ref.read(listSyncServiceProvider);
    
    taskSync.dispose();
    listSync.dispose();
    
    state = const AsyncValue.data(false);
  }
}

/// Provider que monitora mudanças de autenticação e inicia/para sync
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

/// Provider que gerencia auto-sync baseado no estado de auth
@riverpod
class AutoSync extends _$AutoSync {
  @override
  void build() {
    // Monitora mudanças de autenticação
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Usuário logou - inicia sync
          ref.read(syncStatusProvider.notifier).syncAll();
        } else {
          // Usuário deslogou - para sync
          ref.read(syncStatusProvider.notifier).stopSync();
        }
      });
    });
  }
}
