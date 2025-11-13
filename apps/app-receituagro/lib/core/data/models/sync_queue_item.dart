/// Sync operation type
enum SyncOperationType { create, update, delete }

/// Item in the sync queue representing a pending operation
class SyncQueueItem {
  final String sync_id;

  final String modelType;

  final String sync_operation;

  final Map<String, dynamic> data;

  final DateTime sync_timestamp;

  int sync_retryCount;

  bool sync_isSynced;

  String? sync_errorMessage;

  DateTime? sync_lastRetryAt;

  SyncQueueItem({
    required this.sync_id,
    required this.modelType,
    required this.sync_operation,
    required this.data,
    DateTime? sync_timestamp,
    this.sync_retryCount = 0,
    this.sync_isSynced = false,
    this.sync_errorMessage,
    this.sync_lastRetryAt,
  }) : sync_timestamp = sync_timestamp ?? DateTime.now();

  /// Get operation type from string
  SyncOperationType get operationType {
    switch (sync_operation.toLowerCase()) {
      case 'create':
        return SyncOperationType.create;
      case 'update':
        return SyncOperationType.update;
      case 'delete':
        return SyncOperationType.delete;
      default:
        throw ArgumentError('Invalid operation type: $sync_operation');
    }
  }

  /// Check if max retries reached (3 attempts)
  bool get hasExceededMaxRetries => sync_retryCount >= 3;

  /// Check if item needs retry
  bool get needsRetry => !sync_isSynced && !hasExceededMaxRetries;

  /// Check if should retry based on exponential backoff
  bool shouldRetryNow() {
    if (sync_isSynced || hasExceededMaxRetries) return false;
    if (sync_lastRetryAt == null) return true;

    // Exponential backoff: 1min, 5min, 15min
    final backoffMinutes = [1, 5, 15];
    if (sync_retryCount >= backoffMinutes.length) return false;

    final minutesSinceLastRetry = DateTime.now()
        .difference(sync_lastRetryAt!)
        .inMinutes;
    return minutesSinceLastRetry >= backoffMinutes[sync_retryCount];
  }

  // ✅ Compatibility getters for SyncQueue
  String get id => sync_id;
  String get status => sync_isSynced ? 'synced' : 'pending';
  DateTime get createdAt => sync_timestamp;

  SyncQueueItem copyWith({
    String? sync_id,
    String? modelType,
    String? sync_operation,
    Map<String, dynamic>? data,
    DateTime? sync_timestamp,
    int? sync_retryCount,
    bool? sync_isSynced,
    String? sync_errorMessage,
    DateTime? sync_lastRetryAt,
    String? status, // ✅ Compatibility parameter
  }) {
    // ✅ Handle status parameter
    final bool isSynced = status != null 
        ? (status == 'synced' || status == 'completed')
        : (sync_isSynced ?? this.sync_isSynced);
    
    return SyncQueueItem(
      sync_id: sync_id ?? this.sync_id,
      modelType: modelType ?? this.modelType,
      sync_operation: sync_operation ?? this.sync_operation,
      data: data ?? this.data,
      sync_timestamp: sync_timestamp ?? this.sync_timestamp,
      sync_retryCount: sync_retryCount ?? this.sync_retryCount,
      sync_isSynced: isSynced,
      sync_errorMessage: sync_errorMessage ?? this.sync_errorMessage,
      sync_lastRetryAt: sync_lastRetryAt ?? this.sync_lastRetryAt,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem(sync_id: $sync_id, modelType: $modelType, sync_operation: $sync_operation, '
        'sync_retryCount: $sync_retryCount, sync_isSynced: $sync_isSynced)';
  }
}
