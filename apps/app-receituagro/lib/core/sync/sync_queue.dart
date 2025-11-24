import 'dart:async';


import '../data/models/sync_queue_item.dart' as models;

/// ✅ SIMPLIFIED: In-memory sync queue (no persistence)
/// Session-based queue for sync operations

class SyncQueue {
  // In-memory queue storage
  final Map<String, models.SyncQueueItem> _queue = {};
  
  final StreamController<List<models.SyncQueueItem>> _queueController =
      StreamController<List<models.SyncQueueItem>>.broadcast();
  
  Stream<List<models.SyncQueueItem>> get queueStream => _queueController.stream;

  SyncQueue();

  /// Initialize sync queue (now a no-op since we use memory)
  Future<void> initialize() async {
    // No initialization needed for in-memory storage
  }

  /// Check if queue is initialized (always true for memory)
  bool get isInitialized => true;

  /// Add item to sync queue
  Future<void> add(models.SyncQueueItem item) async {
    try {
      _queue[item.id] = item;
      _notifyListeners();
    } catch (e) {
      throw Exception('Failed to add item to SyncQueue: $e');
    }
  }

  /// Remove item from queue
  Future<void> remove(String id) async {
    try {
      _queue.remove(id);
      _notifyListeners();
    } catch (e) {
      throw Exception('Failed to remove item from SyncQueue: $e');
    }
  }

  /// Update item status
  Future<void> updateStatus(String id, String status) async {
    try {
      final item = _queue[id];
      if (item != null) {
        _queue[id] = item.copyWith(status: status);
        _notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update item status: $e');
    }
  }

  /// Get all pending items
  List<models.SyncQueueItem> getPendingItems() {
    return _queue.values
        .where((item) => item.status == 'pending')
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Get all items
  List<models.SyncQueueItem> getAllItems() {
    return _queue.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Clear all items
  Future<void> clear() async {
    _queue.clear();
    _notifyListeners();
  }

  /// Notify listeners of queue changes
  void _notifyListeners() {
    if (!_queueController.isClosed) {
      _queueController.add(getAllItems());
    }
  }

  /// Dispose resources
  void dispose() {
    _queueController.close();
  }
}
