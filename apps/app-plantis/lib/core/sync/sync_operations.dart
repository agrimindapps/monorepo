import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../data/models/sync_queue_item.dart' as local;
import 'sync_queue.dart' as local;

@singleton
class SyncOperations {
  final local.SyncQueue _syncQueue;
  final ConnectivityService _connectivityService;

  late StreamSubscription<ConnectivityType> _networkSubscription;
  bool _isProcessingSync = false;

  SyncOperations(this._syncQueue, this._connectivityService) {
    _initializeNetworkListener();
  }

  void _initializeNetworkListener() {
    _networkSubscription = _connectivityService.networkStatusStream.listen((
      status,
    ) {
      if (status != ConnectivityType.offline &&
          status != ConnectivityType.none) {
        processOfflineQueue();
      }
    });
  }

  Future<void> processOfflineQueue() async {
    if (_isProcessingSync) return;
    _isProcessingSync = true;

    try {
      final pendingItems = _syncQueue.getPendingItems();
      final prioritizedItems = _prioritizeItems(pendingItems);

      for (var item in prioritizedItems) {
        try {
          await _processSyncItem(item);
        } catch (e) {
          if (kDebugMode) {
            print('Error syncing item ${item.id}: $e');
          }
          if (item.retryCount < 3) {
            await _syncQueue.incrementRetryCount(item.id);
          }
        }
      }
      _syncQueue.clearSyncedItems();
    } catch (e) {
      if (kDebugMode) {
        print('Error processing offline queue: $e');
      }
    } finally {
      _isProcessingSync = false;
    }
  }

  List<local.SyncQueueItem> _prioritizeItems(List<local.SyncQueueItem> items) {
    items.sort((a, b) {
      int getPriority(local.SyncQueueItem item) {
        switch (item.operationType) {
          case local.SyncOperationType.create:
            return 3;
          case local.SyncOperationType.update:
            return 2;
          case local.SyncOperationType.delete:
            return 1;
        }
      }
      final priorityComparison = getPriority(b).compareTo(getPriority(a));
      return priorityComparison != 0
          ? priorityComparison
          : a.timestamp.compareTo(b.timestamp);
    });

    return items;
  }

  Future<void> _processSyncItem(local.SyncQueueItem item) async {
    switch (item.operationType) {
      case local.SyncOperationType.create:
        await _performCreate(item);
        break;
      case local.SyncOperationType.update:
        await _performUpdate(item);
        break;
      case local.SyncOperationType.delete:
        await _performDelete(item);
        break;
    }
    await _syncQueue.markItemAsSynced(item.id);
  }

  Future<void> _performCreate(local.SyncQueueItem item) async {
    switch (item.modelType) {
      case 'Plant':
        break;
      case 'Task':
        break;
    }
  }

  Future<void> _performUpdate(local.SyncQueueItem item) async {
  }

  Future<void> _performDelete(local.SyncQueueItem item) async {
  }

  void dispose() {
    _networkSubscription.cancel();
  }
}
