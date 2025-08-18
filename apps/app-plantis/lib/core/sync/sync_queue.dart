import 'dart:async';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../data/models/sync_queue_item.dart';

@singleton
class SyncQueue {
  final HiveInterface _hive;
  late Box<SyncQueueItem> _syncQueueBox;
  
  final StreamController<List<SyncQueueItem>> _queueController = 
      StreamController<List<SyncQueueItem>>.broadcast();
  
  Stream<List<SyncQueueItem>> get queueStream => _queueController.stream;

  SyncQueue(this._hive);

  Future<void> initialize() async {
    _syncQueueBox = await _hive.openBox<SyncQueueItem>('sync_queue');
    _notifyQueueUpdated();
  }

  void addToQueue({
    required String modelType, 
    required String operation, 
    required Map<String, dynamic> data
  }) {
    final queueItem = SyncQueueItem(
      id: const Uuid().v4(),
      modelType: modelType,
      operation: operation,
      data: data,
    );

    _syncQueueBox.add(queueItem);
    _notifyQueueUpdated();
  }

  List<SyncQueueItem> getPendingItems() {
    return _syncQueueBox.values
        .where((item) => !item.isSynced)
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> markItemAsSynced(String itemId) async {
    final item = _syncQueueBox.values.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    
    item.isSynced = true;
    await item.save();
    _notifyQueueUpdated();
  }

  Future<void> incrementRetryCount(String itemId) async {
    final item = _syncQueueBox.values.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    
    item.retryCount++;
    await item.save();
    _notifyQueueUpdated();
  }

  void _notifyQueueUpdated() {
    _queueController.add(getPendingItems());
  }

  Future<void> clearSyncedItems() async {
    final syncedItems = _syncQueueBox.values
        .where((item) => item.isSynced)
        .toList();
    
    for (var item in syncedItems) {
      await item.delete();
    }
    _notifyQueueUpdated();
  }

  Future<void> clearAllItems() async {
    await _syncQueueBox.clear();
    _notifyQueueUpdated();
  }

  void dispose() {
    _queueController.close();
  }
}