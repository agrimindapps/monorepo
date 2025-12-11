import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/sync_queue_item.dart';

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
// MAIN SYNC STATUS NOTIFIER
// =============================================================================

/// Riverpod notifier for sync status state management
@riverpod
class SyncStatus extends _$SyncStatus {
  StreamSubscription<core.ConnectivityType>? _networkSubscription;

  @override
  SyncStatusModel build() {
    _initializeListeners();

    // Cleanup on dispose
    ref.onDispose(() {
      _networkSubscription?.cancel();
    });

    return const SyncStatusModel();
  }

  /// Initializes network listeners
  void _initializeListeners() {
    final connectivityService = core.ConnectivityService.instance;

    // Listen to network changes
    _networkSubscription = connectivityService.networkStatusStream.listen((
      core.ConnectivityType status,
    ) {
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
    final connectivityService = core.ConnectivityService.instance;

    final networkStatusResult = await connectivityService
        .getCurrentNetworkStatus();

    networkStatusResult.fold(
      (failure) => _updateSyncState(SyncStatusState.error),
      (core.ConnectivityType networkStatus) {
        if (networkStatus == core.ConnectivityType.offline ||
            networkStatus == core.ConnectivityType.none) {
          _updateSyncState(SyncStatusState.offline);
        } else {
          _updateSyncState(SyncStatusState.idle);
        }
      },
    );
  }
}
