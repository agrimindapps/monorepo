import 'dart:async';

import 'package:core/core.dart' hide getIt;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/background_sync_service.dart';
import '../sync/background_sync_status.dart';

part 'background_sync_notifier.g.dart';

/// State for background synchronization
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

  /// Helper method to check if sync is needed
  bool shouldStartInitialSync(String? userId) {
    return userId != null &&
        userId.isNotEmpty &&
        !hasPerformedInitialSync &&
        !isSyncInProgress;
  }

  /// Helper method to get sync progress percentage
  double getSyncProgress() {
    if (operationStatus.isEmpty) return 0.0;

    final completedCount =
        operationStatus.values.where((completed) => completed).length;
    return completedCount / operationStatus.length;
  }

  /// Helper method to get human-readable sync status
  String getSyncStatusMessage() {
    switch (syncStatus) {
      case BackgroundSyncStatus.idle:
        return 'Pronto para sincronizar';
      case BackgroundSyncStatus.syncing:
        return currentSyncMessage;
      case BackgroundSyncStatus.completed:
        return 'Sincronização concluída';
      case BackgroundSyncStatus.error:
        return 'Erro na sincronização';
      case BackgroundSyncStatus.cancelled:
        return 'Sincronização cancelada';
    }
  }

  /// Helper method to determine if sync indicator should be shown
  bool shouldShowSyncIndicator() {
    return isSyncInProgress || syncStatus == BackgroundSyncStatus.error;
  }

  /// Helper method to determine sync indicator color
  String getSyncIndicatorColor() {
    switch (syncStatus) {
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
}

/// Notifier for managing background synchronization state
@riverpod
class BackgroundSyncNotifier extends _$BackgroundSyncNotifier {
  late final BackgroundSyncService _backgroundSyncService;

  StreamSubscription<String>? _messageSubscription;
  StreamSubscription<bool>? _progressSubscription;
  StreamSubscription<BackgroundSyncStatus>? _statusSubscription;

  @override
  BackgroundSyncState build() {
    _backgroundSyncService = ref.read(backgroundSyncServiceProvider);

    // Setup cleanup
    ref.onDispose(() {
      _messageSubscription?.cancel();
      _progressSubscription?.cancel();
      _statusSubscription?.cancel();
    });

    // Listen to service updates
    _listenToSyncUpdates();

    // Return initial state from service
    return BackgroundSyncState(
      isSyncInProgress: _backgroundSyncService.isSyncInProgress,
      hasPerformedInitialSync: _backgroundSyncService.hasPerformedInitialSync,
      currentSyncMessage: _backgroundSyncService.currentSyncMessage,
      syncStatus: _backgroundSyncService.syncStatus,
      operationStatus: _backgroundSyncService.getOperationStatus(),
    );
  }

  /// Listen to sync service updates and propagate to state
  void _listenToSyncUpdates() {
    _messageSubscription =
        _backgroundSyncService.syncMessageStream.listen((message) {
      state = state.copyWith(
        currentSyncMessage: message,
      );
    });

    _progressSubscription =
        _backgroundSyncService.syncProgressStream.listen((inProgress) {
      state = state.copyWith(
        isSyncInProgress: inProgress,
        operationStatus: _backgroundSyncService.getOperationStatus(),
      );
    });

    _statusSubscription =
        _backgroundSyncService.syncStatusStream.listen((status) {
      state = state.copyWith(
        syncStatus: status,
        operationStatus: _backgroundSyncService.getOperationStatus(),
      );
    });
  }

  /// Starts background sync for authenticated user
  Future<void> startBackgroundSync({
    required String userId,
    bool isInitialSync = false,
  }) async {
    await _backgroundSyncService.startBackgroundSync(
      userId: userId,
      isInitialSync: isInitialSync,
    );

    // Update state after sync starts
    state = state.copyWith(
      isSyncInProgress: _backgroundSyncService.isSyncInProgress,
      hasPerformedInitialSync: _backgroundSyncService.hasPerformedInitialSync,
      syncStatus: _backgroundSyncService.syncStatus,
    );
  }

  /// Cancels ongoing sync
  void cancelSync() {
    _backgroundSyncService.cancelSync();

    state = state.copyWith(
      syncStatus: _backgroundSyncService.syncStatus,
      isSyncInProgress: false,
    );
  }

  /// Retries failed sync
  Future<void> retrySync(String userId) async {
    await _backgroundSyncService.retrySync(userId);

    state = state.copyWith(
      syncStatus: _backgroundSyncService.syncStatus,
      operationStatus: _backgroundSyncService.getOperationStatus(),
    );
  }

  /// Syncs specific data type
  Future<void> syncSpecificData({
    required String userId,
    required String dataType,
  }) async {
    await _backgroundSyncService.syncSpecificData(
      userId: userId,
      dataType: dataType,
    );

    state = state.copyWith(
      operationStatus: _backgroundSyncService.getOperationStatus(),
    );
  }

  /// Checks if specific operation was successful
  bool isOperationSuccessful(String operation) {
    return _backgroundSyncService.isOperationSuccessful(operation);
  }

  /// Resets sync state (useful for logout)
  void resetSyncState() {
    _backgroundSyncService.resetSyncState();

    state = BackgroundSyncState(
      isSyncInProgress: _backgroundSyncService.isSyncInProgress,
      hasPerformedInitialSync: _backgroundSyncService.hasPerformedInitialSync,
      currentSyncMessage: _backgroundSyncService.currentSyncMessage,
      syncStatus: _backgroundSyncService.syncStatus,
      operationStatus: _backgroundSyncService.getOperationStatus(),
    );
  }
}

/// Dependency provider for BackgroundSyncService
@riverpod
BackgroundSyncService backgroundSyncService(Ref ref) {
  return GetIt.instance<BackgroundSyncService>();
}

/// Stream providers for real-time updates
@riverpod
Stream<BackgroundSyncStatus> backgroundSyncStatusStream(Ref ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.syncStatusStream;
}

@riverpod
Stream<String> backgroundSyncMessageStream(Ref ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.syncMessageStream;
}

@riverpod
Stream<bool> backgroundSyncProgressStream(Ref ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.syncProgressStream;
}
