import 'dart:async';
import 'package:core/core.dart' hide SyncQueue, SyncQueueItem;
import 'package:flutter/foundation.dart';
import '../data/models/sync_queue_item.dart';
import 'sync_queue.dart';

/// Handles sync operations with queue management
/// Note: Not using @singleton because dependencies aren't injectable-annotated
/// Must be registered manually in injection_container.dart
class SyncOperations {
  final SyncQueue _syncQueue;
  final ConnectivityService _connectivityService;

  late StreamSubscription<ConnectivityType> _networkSubscription;
  bool _isProcessingSync = false;
  bool _isInitialized = false;

  SyncOperations(this._syncQueue, this._connectivityService);

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _syncQueue.initialize();
    _initializeNetworkListener();
    _isInitialized = true;
  }

  void _initializeNetworkListener() {
    _networkSubscription = _connectivityService.networkStatusStream.listen(
      (status) {
        if (status != ConnectivityType.offline &&
            status != ConnectivityType.none) {
          processOfflineQueue();
        }
      },
    );
  }

  /// Process all pending items in the sync queue
  Future<void> processOfflineQueue() async {
    if (_isProcessingSync) return;
    _isProcessingSync = true;

    try {
      final pendingItems = _syncQueue.getPendingItems();
      final prioritizedItems = _prioritizeItems(pendingItems);

      if (kDebugMode) {
        print('Processing ${prioritizedItems.length} pending sync items');
      }

      for (var item in prioritizedItems) {
        try {
          await _processSyncItem(item);
        } catch (e) {
          if (kDebugMode) {
            print('Error syncing item ${item.id}: $e');
          }

          if (!item.hasExceededMaxRetries) {
            await _syncQueue.incrementRetryCount(
              item.id,
              errorMessage: e.toString(),
            );
          }
        }
      }

      // Clean up synced items periodically
      await _syncQueue.clearSyncedItems();

      if (kDebugMode) {
        print('Sync queue processing completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing offline queue: $e');
      }
    } finally {
      _isProcessingSync = false;
    }
  }

  /// Prioritize sync items: create > update > delete
  List<SyncQueueItem> _prioritizeItems(List<SyncQueueItem> items) {
    items.sort((a, b) {
      int getPriority(SyncQueueItem item) {
        switch (item.operationType) {
          case SyncOperationType.create:
            return 3; // Highest priority
          case SyncOperationType.update:
            return 2; // Medium priority
          case SyncOperationType.delete:
            return 1; // Lowest priority
        }
      }

      final priorityComparison = getPriority(b).compareTo(getPriority(a));
      return priorityComparison != 0
          ? priorityComparison
          : a.timestamp.compareTo(b.timestamp); // FIFO within same priority
    });

    return items;
  }

  /// Process individual sync item
  Future<void> _processSyncItem(SyncQueueItem item) async {
    if (kDebugMode) {
      print('Processing sync item: ${item.modelType} - ${item.operation}');
    }

    switch (item.operationType) {
      case SyncOperationType.create:
        await _performCreate(item);
        break;
      case SyncOperationType.update:
        await _performUpdate(item);
        break;
      case SyncOperationType.delete:
        await _performDelete(item);
        break;
    }

    await _syncQueue.markItemAsSynced(item.id);

    if (kDebugMode) {
      print('Successfully synced item: ${item.id}');
    }
  }

  /// Perform create operation - to be implemented by specific repositories
  Future<void> _performCreate(SyncQueueItem item) async {
    // TODO: Implement specific create logic based on modelType
    // This will be called by specific repositories
    switch (item.modelType) {
      case 'ComentarioHive':
        // Repository should handle this
        break;
      case 'DiagnosticoHive':
        // Repository should handle this
        break;
      default:
        if (kDebugMode) {
          print('Unknown model type for create: ${item.modelType}');
        }
    }
  }

  /// Perform update operation - to be implemented by specific repositories
  Future<void> _performUpdate(SyncQueueItem item) async {
    // TODO: Implement specific update logic based on modelType
    if (kDebugMode) {
      print('Update operation for ${item.modelType}');
    }
  }

  /// Perform delete operation - to be implemented by specific repositories
  Future<void> _performDelete(SyncQueueItem item) async {
    // TODO: Implement specific delete logic based on modelType
    if (kDebugMode) {
      print('Delete operation for ${item.modelType}');
    }
  }

  /// Manual trigger for sync queue processing
  Future<void> syncNow() async {
    if (!_isInitialized) {
      throw StateError('SyncOperations not initialized');
    }

    await processOfflineQueue();
  }

  /// Get current sync status
  bool get isSyncing => _isProcessingSync;

  /// Get pending items count
  int get pendingItemsCount => _syncQueue.pendingCount;

  void dispose() {
    _networkSubscription.cancel();
  }
}
