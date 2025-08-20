import 'dart:async';
import 'package:flutter/foundation.dart';

import '../services/connectivity_service.dart';
import '../sync/sync_queue.dart';
import '../data/models/sync_queue_item.dart';

enum SyncState {
  idle,    // No sync operations
  syncing, // Currently syncing
  offline, // No network connection
  error    // Sync encountered an error
}

class SyncStatusProvider with ChangeNotifier {
  final ConnectivityService _connectivityService;
  final SyncQueue _syncQueue;
  
  // Stream subscriptions for proper disposal
  StreamSubscription<NetworkStatus>? _networkSubscription;
  StreamSubscription<List<SyncQueueItem>>? _queueSubscription;

  SyncState _currentState = SyncState.idle;
  SyncState get currentState => _currentState;

  List<SyncQueueItem> _pendingItems = [];
  List<SyncQueueItem> get pendingItems => _pendingItems;

  int get pendingItemsCount => _pendingItems.length;

  SyncStatusProvider(this._connectivityService, this._syncQueue) {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Listen to network status changes
    _networkSubscription = _connectivityService.networkStatusStream.listen((status) {
      switch (status) {
        case NetworkStatus.offline:
          _updateSyncState(SyncState.offline);
          break;
        case NetworkStatus.mobile:
        case NetworkStatus.wifi:
        case NetworkStatus.online:
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
    final networkStatus = await _connectivityService.getCurrentNetworkStatus();
    
    if (networkStatus == NetworkStatus.offline) {
      _updateSyncState(SyncState.offline);
    } else {
      final pendingItems = _syncQueue.getPendingItems();
      
      if (pendingItems.isEmpty) {
        _updateSyncState(SyncState.idle);
      } else {
        _updateSyncState(SyncState.syncing);
      }
    }
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