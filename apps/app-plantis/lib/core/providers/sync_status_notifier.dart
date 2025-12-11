import 'dart:async';

import 'package:core/core.dart' hide Column, SyncQueue, SyncQueueItem;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/sync_queue_item.dart';
import '../sync/sync_queue.dart';

part 'sync_status_notifier.g.dart';

enum SyncState {
  idle, // No sync operations
  syncing, // Currently syncing
  offline, // No network connection
  error, // Sync encountered an error
}

/// Sync Status State model for Riverpod
class SyncStatusState {
  final SyncState currentState;
  final List<SyncQueueItem> pendingItems;

  const SyncStatusState({
    this.currentState = SyncState.idle,
    this.pendingItems = const [],
  });

  SyncStatusState copyWith({
    SyncState? currentState,
    List<SyncQueueItem>? pendingItems,
  }) {
    return SyncStatusState(
      currentState: currentState ?? this.currentState,
      pendingItems: pendingItems ?? this.pendingItems,
    );
  }

  int get pendingItemsCount => pendingItems.length;
  bool get isIdle => currentState == SyncState.idle;
  bool get isSyncing => currentState == SyncState.syncing;
  bool get isOffline => currentState == SyncState.offline;
  bool get hasError => currentState == SyncState.error;

  /// Get a user-friendly status message
  String get statusMessage {
    switch (currentState) {
      case SyncState.idle:
        return 'Synced';
      case SyncState.syncing:
        return 'Syncing ($pendingItemsCount items)';
      case SyncState.offline:
        return 'Offline - Changes saved locally';
      case SyncState.error:
        return 'Sync Error';
    }
  }
}

/// Notifier for managing sync status and queue
@riverpod
class SyncStatusNotifier extends _$SyncStatusNotifier {
  late final ConnectivityService _connectivityService;
  SyncQueue? _syncQueue;
  StreamSubscription<ConnectivityType>? _networkSubscription;
  StreamSubscription<List<SyncQueueItem>>? _queueSubscription;

  @override
  SyncStatusState build() {
    _connectivityService = ConnectivityService.instance;
    ref.onDispose(() {
      _networkSubscription?.cancel();
      _queueSubscription?.cancel();
    });
    _initializeListeners();
    return const SyncStatusState();
  }

  void _initializeListeners() {
    _networkSubscription = _connectivityService.networkStatusStream.listen((
      status,
    ) {
      switch (status) {
        case ConnectivityType.offline:
        case ConnectivityType.none:
          _updateSyncState(SyncState.offline);
          break;
        case ConnectivityType.mobile:
        case ConnectivityType.wifi:
        case ConnectivityType.online:
        case ConnectivityType.ethernet:
        case ConnectivityType.vpn:
        case ConnectivityType.other:
        case ConnectivityType.bluetooth:
          _updateSyncState(SyncState.idle);
          break;
      }
    });
  }

  /// Set the sync queue (called from outside with proper type)
  void setSyncQueue(SyncQueue queue) {
    _syncQueue = queue;
    _queueSubscription?.cancel();
    _queueSubscription = queue.queueStream.listen((List<SyncQueueItem> items) {
      final newState = items.isEmpty ? SyncState.idle : SyncState.syncing;
      state = state.copyWith(pendingItems: items, currentState: newState);
    });
  }

  void _updateSyncState(SyncState newState) {
    if (state.currentState != newState) {
      state = state.copyWith(currentState: newState);
    }
  }

  /// Method to manually trigger sync or check sync status
  Future<void> checkSyncStatus() async {
    final networkStatusResult = await _connectivityService
        .getCurrentNetworkStatus();

    networkStatusResult.fold((failure) => _updateSyncState(SyncState.error), (
      networkStatus,
    ) async {
      if (networkStatus == ConnectivityType.offline ||
          networkStatus == ConnectivityType.none) {
        _updateSyncState(SyncState.offline);
      } else if (_syncQueue != null) {
        final pendingItems = await _syncQueue!.getPendingItemsAsync();

        final newState = pendingItems.isEmpty
            ? SyncState.idle
            : SyncState.syncing;

        state = state.copyWith(
          currentState: newState,
          pendingItems: pendingItems,
        );
      }
    });
  }

  /// Force update sync state (useful for manual refresh)
  void forceUpdateState(SyncState newState) {
    _updateSyncState(newState);
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      _updateSyncState(SyncState.idle);
    }
  }
}
