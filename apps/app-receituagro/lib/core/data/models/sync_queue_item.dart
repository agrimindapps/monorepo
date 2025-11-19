/// Sync operation type
enum SyncOperationType { create, update, delete }

/// Item in the sync queue representing a pending operation
class SyncQueueItem {
  final String syncId;

  final String modelType;

  final String syncOperation;

  final Map<String, dynamic> data;

  final DateTime syncTimestamp;

  int syncRetryCount;

  bool syncIsSynced;

  String? syncErrorMessage;

  DateTime? syncLastRetryAt;

  SyncQueueItem({
    required this.syncId,
    required this.modelType,
    required this.syncOperation,
    required this.data,
    DateTime? syncTimestamp,
    this.syncRetryCount = 0,
    this.syncIsSynced = false,
    this.syncErrorMessage,
    this.syncLastRetryAt,
  }) : syncTimestamp = syncTimestamp ?? DateTime.now();

  /// Get operation type from string
  SyncOperationType get operationType {
    switch (syncOperation.toLowerCase()) {
      case 'create':
        return SyncOperationType.create;
      case 'update':
        return SyncOperationType.update;
      case 'delete':
        return SyncOperationType.delete;
      default:
        throw ArgumentError('Invalid operation type: $syncOperation');
    }
  }

  /// Check if max retries reached (3 attempts)
  bool get hasExceededMaxRetries => syncRetryCount >= 3;

  /// Check if item needs retry
  bool get needsRetry => !syncIsSynced && !hasExceededMaxRetries;

  /// Check if should retry based on exponential backoff
  bool shouldRetryNow() {
    if (syncIsSynced || hasExceededMaxRetries) return false;
    if (syncLastRetryAt == null) return true;

    // Exponential backoff: 1min, 5min, 15min
    final backoffMinutes = [1, 5, 15];
    if (syncRetryCount >= backoffMinutes.length) return false;

    final minutesSinceLastRetry = DateTime.now()
        .difference(syncLastRetryAt!)
        .inMinutes;
    return minutesSinceLastRetry >= backoffMinutes[syncRetryCount];
  }

  // ✅ Compatibility getters for SyncQueue
  String get id => syncId;
  String get status => syncIsSynced ? 'synced' : 'pending';
  DateTime get createdAt => syncTimestamp;

  // ✅ Compatibility getters for legacy code
  String get sync_id => syncId;
  String get sync_operation => syncOperation;
  DateTime get sync_timestamp => syncTimestamp;
  int get sync_retryCount => syncRetryCount;
  bool get sync_isSynced => syncIsSynced;
  String? get sync_errorMessage => syncErrorMessage;
  DateTime? get sync_lastRetryAt => syncLastRetryAt;

  SyncQueueItem copyWith({
    String? syncId,
    String? modelType,
    String? syncOperation,
    Map<String, dynamic>? data,
    DateTime? syncTimestamp,
    int? syncRetryCount,
    bool? syncIsSynced,
    String? syncErrorMessage,
    DateTime? syncLastRetryAt,
    String? status, // ✅ Compatibility parameter
    // Legacy parameters
    String? sync_id,
    String? sync_operation,
    DateTime? sync_timestamp,
    int? sync_retryCount,
    bool? sync_isSynced,
    String? sync_errorMessage,
    DateTime? sync_lastRetryAt,
  }) {
    // ✅ Handle status parameter
    final bool isSynced = status != null 
        ? (status == 'synced' || status == 'completed')
        : (syncIsSynced ?? sync_isSynced ?? this.syncIsSynced);
    
    return SyncQueueItem(
      syncId: syncId ?? sync_id ?? this.syncId,
      modelType: modelType ?? this.modelType,
      syncOperation: syncOperation ?? sync_operation ?? this.syncOperation,
      data: data ?? this.data,
      syncTimestamp: syncTimestamp ?? sync_timestamp ?? this.syncTimestamp,
      syncRetryCount: syncRetryCount ?? sync_retryCount ?? this.syncRetryCount,
      syncIsSynced: isSynced,
      syncErrorMessage: syncErrorMessage ?? sync_errorMessage ?? this.syncErrorMessage,
      syncLastRetryAt: syncLastRetryAt ?? sync_lastRetryAt ?? this.syncLastRetryAt,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem(syncId: $syncId, modelType: $modelType, syncOperation: $syncOperation, '
        'syncRetryCount: $syncRetryCount, syncIsSynced: $syncIsSynced)';
  }
}
