import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' show HiveInterface, Box, singleton;
import '../data/models/sync_queue_item.dart';

@singleton
class SyncQueue {
  final HiveInterface _hive;
  Box<SyncQueueItem>? _syncQueueBox;

  final StreamController<List<SyncQueueItem>> _queueController =
      StreamController<List<SyncQueueItem>>.broadcast();

  Stream<List<SyncQueueItem>> get queueStream => _queueController.stream;

  bool get isInitialized => _syncQueueBox != null;

  SyncQueue(this._hive);

  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      _syncQueueBox = await _hive.openBox<SyncQueueItem>('syncQueue');
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

    final queueItem = SyncQueueItem(
      id: FirebaseFirestore.instance.collection('_').doc().id,
      modelType: modelType,
      operation: operation,
      data: data,
    );

    await _syncQueueBox!.add(queueItem);
    _notifyQueueUpdated();
  }

  /// Get all pending items (not synced and should retry now)
  List<SyncQueueItem> getPendingItems() {
    _ensureInitialized();

    return _syncQueueBox!.values
        .where((item) => !item.isSynced && item.shouldRetryNow())
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get all items (including synced)
  List<SyncQueueItem> getAllItems() {
    _ensureInitialized();
    return _syncQueueBox!.values.toList();
  }

  /// Get pending count
  int get pendingCount {
    _ensureInitialized();
    return _syncQueueBox!.values.where((item) => !item.isSynced).length;
  }

  /// Mark item as successfully synced
  Future<void> markItemAsSynced(String itemId) async {
    _ensureInitialized();

    final item = _syncQueueBox!.values.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found: $itemId'),
    );

    item.isSynced = true;
    await item.save();
    _notifyQueueUpdated();
  }

  /// Increment retry count for failed sync
  Future<void> incrementRetryCount(String itemId, {String? errorMessage}) async {
    _ensureInitialized();

    final item = _syncQueueBox!.values.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found: $itemId'),
    );

    item.retryCount++;
    item.lastRetryAt = DateTime.now();
    if (errorMessage != null) {
      item.errorMessage = errorMessage;
    }
    await item.save();
    _notifyQueueUpdated();
  }

  /// Clear all synced items from queue
  Future<void> clearSyncedItems() async {
    _ensureInitialized();

    final syncedItems = _syncQueueBox!.values.where((item) => item.isSynced).toList();

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

    final item = _syncQueueBox!.values.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found: $itemId'),
    );

    await item.delete();
    _notifyQueueUpdated();
  }

  /// Remove items that exceeded max retries
  Future<void> removeFailedItems() async {
    _ensureInitialized();

    final failedItems = _syncQueueBox!.values
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
