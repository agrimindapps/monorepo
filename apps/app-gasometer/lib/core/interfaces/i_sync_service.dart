/// Interface for sync service operations
/// Provides contract for different sync implementations
abstract class ISyncService {
  /// Initialize the sync service
  Future<void> initialize();

  /// Start synchronization process
  Future<void> startSync();

  /// Stop synchronization process
  Future<void> stopSync();

  /// Sync specific collection
  Future<bool> syncCollection(String collectionName);

  /// Get current sync status
  Stream<SyncStatus> get syncStatusStream;

  /// Get pending sync items count
  Future<int> getPendingSyncCount();

  /// Force sync of all dirty items
  Future<void> forceSyncAll();

  /// Check if sync is currently running
  bool get isSyncing;

  /// Get last sync timestamp
  DateTime? get lastSyncTime;

  /// Check connectivity status
  Future<bool> get isConnected;
}

/// Sync status enumeration
enum SyncStatus {
  idle,
  syncing,
  error,
  completed,
  offline,
}

/// Sync result information
class SyncResult {
  const SyncResult({
    required this.success,
    this.error,
    required this.itemsSynced,
    required this.timestamp,
  });

  final bool success;
  final String? error;
  final int itemsSynced;
  final DateTime timestamp;
}