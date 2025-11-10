import 'dart:async';
import 'package:core/core.dart' hide SyncQueueItem, Column;
import '../data/models/sync_queue_item.dart' as models;

/// Sync queue for offline-first operations
/// ✅ FIXED: Changed from HiveInterface to IHiveManager (current pattern)
/// Note: Not using @singleton because IHiveManager isn't injectable-annotated
/// Must be registered manually in injection_container.dart
class SyncQueue {
  final IHiveManager _hiveManager;
  Box<dynamic>? _syncQueueBox;

  final StreamController<List<models.SyncQueueItem>> _queueController =
      StreamController<List<models.SyncQueueItem>>.broadcast();

  Stream<List<models.SyncQueueItem>> get queueStream => _queueController.stream;

  bool get isInitialized => _syncQueueBox != null;

  SyncQueue(this._hiveManager);

  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      // Use IHiveManager to get box as Box<dynamic> (matches BoxRegistryService pattern)
      final result = await _hiveManager.getBox<dynamic>('syncQueue');
      if (result.isFailure) {
        throw Exception('Failed to open syncQueue box: ${result.error?.message}');
      }
      _syncQueueBox = result.data;
      _notifyQueueUpdated();
    } catch (e) {
      throw Exception('Failed to initialize SyncQueue: $e');
    }
  }

  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError('SyncQueue not initialized. Call initialize() first.');
    }
  }

  /// Add item to sync queue
  Future<void> addToQueue({
    required String modelType,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    _ensureInitialized();

    final queueItem = models.SyncQueueItem(
      sync_id: DateTime.now().millisecondsSinceEpoch.toString(),
      modelType: modelType,
      sync_operation: operation,
      data: data,
    );

    await _syncQueueBox!.add(queueItem);
    _notifyQueueUpdated();
  }

  /// Get all items as SyncQueueItem (with type checking)
  List<models.SyncQueueItem> _getAllSyncItems() {
    _ensureInitialized();

    final items = <models.SyncQueueItem>[];
    for (final value in _syncQueueBox!.values) {
      if (value is models.SyncQueueItem) {
        items.add(value);
      }
    }
    return items;
  }

  /// Get all pending items (not synced and should retry now)
  List<models.SyncQueueItem> getPendingItems() {
    _ensureInitialized();

    return _getAllSyncItems()
        .where((item) => !item.sync_isSynced && item.shouldRetryNow())
        .toList()
      ..sort((a, b) => a.sync_timestamp.compareTo(b.sync_timestamp));
  }

  /// Get all items (including synced)
  List<models.SyncQueueItem> getAllItems() {
    _ensureInitialized();
    return _getAllSyncItems();
  }

  /// Get pending count
  int get pendingCount {
    _ensureInitialized();
    return _getAllSyncItems().where((item) => !item.sync_isSynced).length;
  }

  /// Mark item as successfully synced
  Future<void> markItemAsSynced(String itemId) async {
    _ensureInitialized();

    final item = _getAllSyncItems().firstWhere(
      (item) => item.sync_id == itemId,
      orElse: () => throw Exception('Item not found: $itemId'),
    );

    item.sync_isSynced = true;
    await item.save();
    _notifyQueueUpdated();
  }

  /// Increment retry count for failed sync
  Future<void> incrementRetryCount(String itemId, {String? errorMessage}) async {
    _ensureInitialized();

    final item = _getAllSyncItems().firstWhere(
      (item) => item.sync_id == itemId,
      orElse: () => throw Exception('Item not found: $itemId'),
    );

    item.sync_retryCount++;
    item.sync_lastRetryAt = DateTime.now();
    if (errorMessage != null) {
      item.sync_errorMessage = errorMessage;
    }
    await item.save();
    _notifyQueueUpdated();
  }

  /// Clear all synced items from queue
  Future<void> clearSyncedItems() async {
    _ensureInitialized();

    final syncedItems = _getAllSyncItems().where((item) => item.sync_isSynced).toList();

    for (var item in syncedItems) {
      await item.delete();
    }
    _notifyQueueUpdated();
  }

  /// Clear all items (including pending) - use with caution
  Future<void> clearAllItems() async {
    _ensureInitialized();

    await _syncQueueBox!.clear();
    _notifyQueueUpdated();
  }

  /// Remove specific item from queue
  Future<void> removeItem(String itemId) async {
    _ensureInitialized();

    final item = _getAllSyncItems().firstWhere(
      (item) => item.sync_id == itemId,
      orElse: () => throw Exception('Item not found: $itemId'),
    );

    await item.delete();
    _notifyQueueUpdated();
  }

  /// Remove items that exceeded max retries
  Future<void> removeFailedItems() async {
    _ensureInitialized();

    final failedItems = _getAllSyncItems()
        .where((item) => item.hasExceededMaxRetries)
        .toList();

    for (var item in failedItems) {
      await item.delete();
    }
    _notifyQueueUpdated();
  }

  void _notifyQueueUpdated() {
    if (isInitialized) {
      _queueController.add(getPendingItems());
    }
  }

  void dispose() {
    _queueController.close();
  }
}
