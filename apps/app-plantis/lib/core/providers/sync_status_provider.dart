import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../data/models/sync_queue_item.dart' as local;
import '../sync/sync_queue.dart' as local;

enum SyncState {
  idle, // No sync operations
  syncing, // Currently syncing
  offline, // No network connection
  error, // Sync encountered an error
}

class SyncStatusProvider with ChangeNotifier {
  final ConnectivityService _connectivityService;
  final local.SyncQueue _syncQueue;

  // Stream subscriptions for proper disposal
  StreamSubscription<ConnectivityType>? _networkSubscription;
  StreamSubscription<List<local.SyncQueueItem>>? _queueSubscription;

  SyncState _currentState = SyncState.idle;
  SyncState get currentState => _currentState;

  List<local.SyncQueueItem> _pendingItems = [];
  List<local.SyncQueueItem> get pendingItems => _pendingItems;

  int get pendingItemsCount => _pendingItems.length;

  SyncStatusProvider(this._connectivityService, this._syncQueue) {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Listen to network status changes
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

    // Listen to sync queue changes
    _queueSubscription = _syncQueue.queueStream.listen((items) {
      _pendingItems = items;

      if (items.isEmpty) {
        _updateSyncState(SyncState.idle);
      } else {
        _updateSyncState(SyncState.syncing);
      }
    });
  }

  void _updateSyncState(SyncState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      notifyListeners();
    }
  }

  // Method to manually trigger sync or check sync status
  Future<void> checkSyncStatus() async {
    final networkStatusResult =
        await _connectivityService.getCurrentNetworkStatus();

    networkStatusResult.fold((failure) => _updateSyncState(SyncState.error), (
      networkStatus,
    ) {
      if (networkStatus == ConnectivityType.offline ||
          networkStatus == ConnectivityType.none) {
        _updateSyncState(SyncState.offline);
      } else {
        final pendingItems = _syncQueue.getPendingItems();

        if (pendingItems.isEmpty) {
          _updateSyncState(SyncState.idle);
        } else {
          _updateSyncState(SyncState.syncing);
        }
      }
    });
  }

  // Helper method to get a user-friendly status message
  String get statusMessage {
    switch (_currentState) {
      case SyncState.idle:
        return 'Synced';
      case SyncState.syncing:
        return 'Syncing (${_pendingItems.length} items)';
      case SyncState.offline:
        return 'Offline - Changes saved locally';
      case SyncState.error:
        return 'Sync Error';
    }
  }

  @override
  void dispose() {
    // Cancel stream subscriptions to prevent memory leaks
    _networkSubscription?.cancel();
    _queueSubscription?.cancel();
    super.dispose();
  }
}
