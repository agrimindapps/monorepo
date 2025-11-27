import 'dart:async';

import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/background_sync_service.dart';
import '../sync/background_sync_status.dart';

import '../../features/plants/presentation/providers/plants_providers.dart';
import '../../features/tasks/presentation/providers/tasks_providers.dart';
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
    // authStateNotifier: AuthStateNotifier.instance, // Or ref.watch(authStateNotifierProvider) if available
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
@riverpod
class BackgroundSync extends _$BackgroundSync {
  StreamSubscription<String>? _messageSubscription;
  StreamSubscription<bool>? _progressSubscription;
  StreamSubscription<BackgroundSyncStatus>? _statusSubscription;

  @override
  BackgroundSyncState build() {
    final service = ref.watch(backgroundSyncServiceProvider);

    // Setup listeners on first build
    _listenToSyncUpdates();

    // Cleanup on dispose
    ref.onDispose(() {
      _messageSubscription?.cancel();
      _progressSubscription?.cancel();
      _statusSubscription?.cancel();
    });

    return BackgroundSyncState(
      isSyncInProgress: service.isSyncInProgress,
      hasPerformedInitialSync: service.hasPerformedInitialSync,
      currentSyncMessage: service.currentSyncMessage,
      syncStatus: service.syncStatus,
      operationStatus: service.getOperationStatus(),
    );
  }

  /// Listen to sync service updates and propagate to state
  void _listenToSyncUpdates() {
    final service = ref.read(backgroundSyncServiceProvider);

    _messageSubscription = service.syncMessageStream.listen((message) {
      state = state.copyWith(currentSyncMessage: message);
    });

    _progressSubscription = service.syncProgressStream.listen((inProgress) {
      state = state.copyWith(isSyncInProgress: inProgress);
    });

    _statusSubscription = service.syncStatusStream.listen((status) {
      state = state.copyWith(
        syncStatus: status,
        operationStatus: service.getOperationStatus(),
      );
    });
  }

  /// Starts background sync for authenticated user
  Future<void> startBackgroundSync({
    required String userId,
    bool isInitialSync = false,
  }) async {
    final service = ref.read(backgroundSyncServiceProvider);
    await service.startBackgroundSync(
      userId: userId,
      isInitialSync: isInitialSync,
    );

    // Update state after sync starts
    state = state.copyWith(
      isSyncInProgress: service.isSyncInProgress,
      hasPerformedInitialSync: service.hasPerformedInitialSync,
    );
  }

  /// Cancels ongoing sync
  void cancelSync() {
    final service = ref.read(backgroundSyncServiceProvider);
    service.cancelSync();

    state = state.copyWith(
      isSyncInProgress: service.isSyncInProgress,
      syncStatus: service.syncStatus,
    );
  }

  /// Retries failed sync
  Future<void> retrySync(String userId) async {
    final service = ref.read(backgroundSyncServiceProvider);
    await service.retrySync(userId);

    state = state.copyWith(
      isSyncInProgress: service.isSyncInProgress,
      syncStatus: service.syncStatus,
    );
  }

  /// Syncs specific data type
  Future<void> syncSpecificData({
    required String userId,
    required String dataType,
  }) async {
    final service = ref.read(backgroundSyncServiceProvider);
    await service.syncSpecificData(
      userId: userId,
      dataType: dataType,
    );

    state = state.copyWith(
      isSyncInProgress: service.isSyncInProgress,
      operationStatus: service.getOperationStatus(),
    );
  }

  /// Resets sync state (useful for logout)
  void resetSyncState() {
    final service = ref.read(backgroundSyncServiceProvider);
    service.resetSyncState();

    state = const BackgroundSyncState(); // Reset to initial state
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

  final completedCount =
      operations.values.where((completed) => completed).length;
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

// =============================================================================
// STREAM PROVIDERS (for direct stream access)
// =============================================================================

/// Stream provider for sync status changes
@riverpod
Stream<BackgroundSyncStatus> syncStatusStream(Ref ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.syncStatusStream;
}

/// Stream provider for sync messages
@riverpod
Stream<String> syncMessageStream(Ref ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.syncMessageStream;
}

/// Stream provider for sync progress
@riverpod
Stream<bool> syncProgressStream(Ref ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.syncProgressStream;
}
