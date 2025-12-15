import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/plants/presentation/providers/plants_providers.dart';
import '../../features/tasks/presentation/providers/tasks_providers.dart';
import '../services/background_sync_service.dart';
import '../sync/background_sync_status.dart';
import 'repository_providers.dart';

part 'background_sync_provider.g.dart';

/// Dependency provider for BackgroundSyncService
@riverpod
BackgroundSyncService backgroundSyncService(Ref ref) {
  return BackgroundSyncService(
    getPlantsUseCase: ref.watch(getPlantsUseCaseProvider),
    getTasksUseCase: ref.watch(getTasksUseCaseProvider),
    syncSettingsUseCase: ref.watch(syncSettingsUseCaseProvider),
    // syncUserProfileUseCase: ref.watch(syncUserProfileUseCaseProvider), // Not implemented yet
  );
}

/// State class for background sync
class BackgroundSyncState {
  final bool isSyncInProgress;
  final bool hasPerformedInitialSync;
  final String currentSyncMessage;
  final BackgroundSyncStatus syncStatus;
  final Map<String, bool> operationStatus;

  const BackgroundSyncState({
    this.isSyncInProgress = false,
    this.hasPerformedInitialSync = false,
    this.currentSyncMessage = '',
    this.syncStatus = BackgroundSyncStatus.idle,
    this.operationStatus = const {},
  });

  BackgroundSyncState copyWith({
    bool? isSyncInProgress,
    bool? hasPerformedInitialSync,
    String? currentSyncMessage,
    BackgroundSyncStatus? syncStatus,
    Map<String, bool>? operationStatus,
  }) {
    return BackgroundSyncState(
      isSyncInProgress: isSyncInProgress ?? this.isSyncInProgress,
      hasPerformedInitialSync:
          hasPerformedInitialSync ?? this.hasPerformedInitialSync,
      currentSyncMessage: currentSyncMessage ?? this.currentSyncMessage,
      syncStatus: syncStatus ?? this.syncStatus,
      operationStatus: operationStatus ?? this.operationStatus,
    );
  }
}

/// Riverpod notifier for managing background synchronization state
/// Now manages state directly without relying on service streams
@riverpod
class BackgroundSync extends _$BackgroundSync {
  @override
  BackgroundSyncState build() {
    return const BackgroundSyncState();
  }

  /// Starts background sync for authenticated user
  Future<void> startBackgroundSync({
    required String userId,
    bool isInitialSync = false,
  }) async {
    // Check if sync is already in progress
    if (state.isSyncInProgress) {
      return;
    }

    // Check if initial sync already performed
    if (!isInitialSync && state.hasPerformedInitialSync) {
      return;
    }

    // Update state to syncing
    state = state.copyWith(
      isSyncInProgress: true,
      syncStatus: BackgroundSyncStatus.syncing,
      currentSyncMessage: 'Iniciando sincronização...',
    );

    final service = ref.read(backgroundSyncServiceProvider);
    final result = await service.startBackgroundSync(
      userId: userId,
      isInitialSync: isInitialSync,
    );

    // Update state with result
    state = state.copyWith(
      isSyncInProgress: false,
      hasPerformedInitialSync: isInitialSync
          ? true
          : state.hasPerformedInitialSync,
      syncStatus: result.status,
      currentSyncMessage: result.message,
      operationStatus: result.operationStatus,
    );
  }

  /// Cancels ongoing sync
  void cancelSync() {
    if (state.isSyncInProgress) {
      state = state.copyWith(
        isSyncInProgress: false,
        syncStatus: BackgroundSyncStatus.cancelled,
        currentSyncMessage: 'Sincronização cancelada',
      );
    }
  }

  /// Retries failed sync
  Future<void> retrySync(String userId) async {
    await startBackgroundSync(userId: userId, isInitialSync: false);
  }

  /// Syncs specific data type
  Future<void> syncSpecificData({
    required String userId,
    required String dataType,
  }) async {
    if (state.isSyncInProgress) {
      return;
    }

    state = state.copyWith(
      isSyncInProgress: true,
      syncStatus: BackgroundSyncStatus.syncing,
      currentSyncMessage: 'Sincronizando $dataType...',
    );

    final service = ref.read(backgroundSyncServiceProvider);
    final result = await service.syncSpecificData(
      userId: userId,
      dataType: dataType,
    );

    state = state.copyWith(
      isSyncInProgress: false,
      syncStatus: result.status,
      currentSyncMessage: result.message,
      operationStatus: {...state.operationStatus, ...result.operationStatus},
    );
  }

  /// Resets sync state (useful for logout)
  void resetSyncState() {
    state = const BackgroundSyncState();
  }
}

// =============================================================================
// COMPUTED/DERIVED PROVIDERS
// =============================================================================

/// Helper provider to check if sync is needed
@riverpod
bool shouldStartInitialSync(Ref ref, String? userId) {
  final syncState = ref.watch(backgroundSyncProvider);

  return userId != null &&
      userId.isNotEmpty &&
      !syncState.hasPerformedInitialSync &&
      !syncState.isSyncInProgress;
}

/// Helper provider to get sync progress percentage
@riverpod
double syncProgress(Ref ref) {
  final syncState = ref.watch(backgroundSyncProvider);
  final operations = syncState.operationStatus;

  if (operations.isEmpty) return 0.0;

  final completedCount = operations.values
      .where((completed) => completed)
      .length;
  return completedCount / operations.length;
}

/// Helper provider to get human-readable sync status
@riverpod
String syncStatusMessage(Ref ref) {
  final syncState = ref.watch(backgroundSyncProvider);

  switch (syncState.syncStatus) {
    case BackgroundSyncStatus.idle:
      return 'Pronto para sincronizar';
    case BackgroundSyncStatus.syncing:
      return syncState.currentSyncMessage;
    case BackgroundSyncStatus.completed:
      return 'Sincronização concluída';
    case BackgroundSyncStatus.error:
      return 'Erro na sincronização';
    case BackgroundSyncStatus.cancelled:
      return 'Sincronização cancelada';
  }
}

/// Helper provider to determine if sync indicator should be shown
@riverpod
bool shouldShowSyncIndicator(Ref ref) {
  final syncState = ref.watch(backgroundSyncProvider);
  return syncState.isSyncInProgress ||
      syncState.syncStatus == BackgroundSyncStatus.error;
}

/// Helper provider to determine sync indicator color
@riverpod
String syncIndicatorColor(Ref ref) {
  final syncState = ref.watch(backgroundSyncProvider);

  switch (syncState.syncStatus) {
    case BackgroundSyncStatus.syncing:
      return 'blue';
    case BackgroundSyncStatus.completed:
      return 'green';
    case BackgroundSyncStatus.error:
      return 'red';
    case BackgroundSyncStatus.cancelled:
      return 'orange';
    case BackgroundSyncStatus.idle:
      return 'grey';
  }
}
