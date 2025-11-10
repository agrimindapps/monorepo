import 'dart:async';

import 'package:core/core.dart' hide Column, SyncQueue, SyncQueueItem;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/models/sync_queue_item.dart';
import '../sync/sync_queue.dart';

part 'sync_status_provider.freezed.dart';
part 'sync_status_provider.g.dart';

/// Enum representing sync state
enum SyncStatusState {
  idle, // No sync operations
  syncing, // Currently syncing
  offline, // No network connection
  error, // Sync encountered an error
}

/// State class for sync status with freezed immutability
@freezed
class SyncStatusModel with _$SyncStatusModel {
  const factory SyncStatusModel({
    @Default(SyncStatusState.idle) SyncStatusState currentState,
    @Default([]) List<SyncQueueItem> pendingItems,
  }) = _SyncStatusModel;

  const SyncStatusModel._();

  /// Convenience getter for pending items count
  int get pendingItemsCount => pendingItems.length;

  /// Human-readable status message
  String get statusMessage {
    switch (currentState) {
      case SyncStatusState.idle:
        return 'Synced';
      case SyncStatusState.syncing:
        return 'Syncing (${pendingItems.length} items)';
      case SyncStatusState.offline:
        return 'Offline - Changes saved locally';
      case SyncStatusState.error:
        return 'Sync Error';
    }
  }
}

// =============================================================================
// DEPENDENCY PROVIDERS
// =============================================================================

/// Provider for ConnectivityService
@riverpod
ConnectivityService syncConnectivityService(SyncConnectivityServiceRef ref) {
  return GetIt.instance<ConnectivityService>();
}

/// Provider for SyncQueue
@riverpod
SyncQueue syncQueue(SyncQueueRef ref) {
  return GetIt.instance<SyncQueue>();
}

// =============================================================================
// MAIN SYNC STATUS NOTIFIER
// =============================================================================

/// Riverpod notifier for sync status state management
@riverpod
class SyncStatusNotifier extends _$SyncStatusNotifier {
  StreamSubscription<ConnectivityType>? _networkSubscription;
  StreamSubscription<List<SyncQueueItem>>? _queueSubscription;

  @override
  SyncStatusModel build() {
    _initializeListeners();

    // Cleanup on dispose
    ref.onDispose(() {
      _networkSubscription?.cancel();
      _queueSubscription?.cancel();
    });

    return const SyncStatusModel();
  }

  /// Initializes network and queue listeners
  void _initializeListeners() {
    final connectivityService = ref.read(syncConnectivityServiceProvider);
    final queue = ref.read(syncQueueProvider);

    // Listen to network changes
    _networkSubscription = connectivityService.networkStatusStream.listen(
      (status) {
        switch (status) {
          case ConnectivityType.offline:
          case ConnectivityType.none:
            _updateSyncState(SyncStatusState.offline);
            break;
          case ConnectivityType.mobile:
          case ConnectivityType.wifi:
          case ConnectivityType.online:
          case ConnectivityType.ethernet:
          case ConnectivityType.vpn:
          case ConnectivityType.other:
          case ConnectivityType.bluetooth:
            _updateSyncState(SyncStatusState.idle);
            break;
        }
      },
    );

    // Listen to queue changes
    _queueSubscription = queue.queueStream.listen((List<SyncQueueItem> items) {
      final typedItems = items.whereType<SyncQueueItem>().toList();
      state = state.copyWith(pendingItems: typedItems);

      if (typedItems.isEmpty) {
        _updateSyncState(SyncStatusState.idle);
      } else {
        _updateSyncState(SyncStatusState.syncing);
      }
    });
  }

  /// Updates sync state if different from current
  void _updateSyncState(SyncStatusState newState) {
    if (state.currentState != newState) {
      state = state.copyWith(currentState: newState);
    }
  }

  /// Manually checks current sync status
  Future<void> checkSyncStatus() async {
    final connectivityService = ref.read(syncConnectivityServiceProvider);
    final queue = ref.read(syncQueueProvider);

    final networkStatusResult =
        await connectivityService.getCurrentNetworkStatus();

    networkStatusResult.fold(
      (failure) => _updateSyncState(SyncStatusState.error),
      (networkStatus) {
        if (networkStatus == ConnectivityType.offline ||
            networkStatus == ConnectivityType.none) {
          _updateSyncState(SyncStatusState.offline);
        } else {
          final pendingItems = queue.getPendingItems();

          if (pendingItems.isEmpty) {
            _updateSyncState(SyncStatusState.idle);
          } else {
            _updateSyncState(SyncStatusState.syncing);
          }
        }
      },
    );
  }
}
