// TEMPORARILY DISABLED: Hive to Drift migration in progress
// Minimal stub implementation - full implementation in sync_operations_backup.dart
// ignore_for_file: unused_field, cancel_subscriptions
import 'dart:async';

import 'package:core/core.dart' hide SyncQueue, SyncQueueItem, Column;

import 'sync_queue.dart';

/// Stub implementation of SyncOperations during Drift migration
/// Full implementation will be restored after migration is complete
class SyncOperations {
  final SyncQueue _syncQueue;
  final ConnectivityService _connectivityService;

  late StreamSubscription<ConnectivityType>? _networkSubscription;
  final bool _isProcessingSync = false;
  bool _isInitialized = false;

  SyncOperations(this._syncQueue, this._connectivityService);

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _syncQueue.initialize();
    _isInitialized = true;
    // Network listener disabled during migration
  }

  /// Process all pending items in the sync queue (disabled during migration)
  Future<void> processOfflineQueue() async {
    // Stub - disabled during migration
    return;
  }

  /// Manual trigger for sync queue processing (disabled during migration)
  Future<void> syncNow() async {
    if (!_isInitialized) {
      throw StateError('SyncOperations not initialized');
    }
    // Stub - disabled during migration
    return;
  }

  /// Get current sync status
  bool get isSyncing => _isProcessingSync;

  /// Get pending items count
  int get pendingItemsCount => 0; // Stub

  void dispose() {
    // Stub - disabled during migration
  }
}
