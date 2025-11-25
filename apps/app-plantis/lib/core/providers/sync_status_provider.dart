import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/sync_queue_item.dart';
import 'repository_providers.dart';

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
sealed class SyncStatusModel with _$SyncStatusModel {
  const factory SyncStatusModel({
    @Default(SyncStatusState.idle) SyncStatusState currentState,
    @Default([]) List<SyncQueueItem> pendingItems,
  }) = _SyncStatusModel;
}

/// Extension providing computed properties for SyncStatusModel
extension SyncStatusModelX on SyncStatusModel {
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
core.ConnectivityService syncConnectivityService(
    Ref ref) {
  return ref.watch(connectivityServiceProvider);
}

// =============================================================================
// MAIN SYNC STATUS NOTIFIER
// =============================================================================

/// Riverpod notifier for sync status state management
@riverpod
class SyncStatusNotifier extends _$SyncStatusNotifier {
  StreamSubscription<core.ConnectivityType>? _networkSubscription;
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
      (core.ConnectivityType status) {
        switch (status) {
          case core.ConnectivityType.offline:
          case core.ConnectivityType.none:
            _updateSyncState(SyncStatusState.offline);
            break;
          case core.ConnectivityType.mobile:
          case core.ConnectivityType.wifi:
          case core.ConnectivityType.online:
          case core.ConnectivityType.ethernet:
          case core.ConnectivityType.vpn:
          case core.ConnectivityType.other:
          case core.ConnectivityType.bluetooth:
            _updateSyncState(SyncStatusState.idle);
            break;
        }
      },
    );

    // Listen to queue changes
    _queueSubscription = queue.queueStream.listen((List<SyncQueueItem> items) {
      final pendingItems = items.where((item) => !item.isSynced).toList();
      state = state.copyWith(pendingItems: pendingItems);

      if (pendingItems.isEmpty) {
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

    final networkStatusResult =
        await connectivityService.getCurrentNetworkStatus();

    networkStatusResult.fold(
      (failure) => _updateSyncState(SyncStatusState.error),
      (core.ConnectivityType networkStatus) {
        if (networkStatus == core.ConnectivityType.offline ||
            networkStatus == core.ConnectivityType.none) {
          _updateSyncState(SyncStatusState.offline);
        } else {
          // For manual check, we can't easily get pending items without async
          // Just update to idle for now
          _updateSyncState(SyncStatusState.idle);
        }
      },
    );
  }
}
