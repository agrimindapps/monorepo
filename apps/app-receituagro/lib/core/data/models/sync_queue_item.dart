import 'package:core/core.dart';

/// Sync operation type
enum SyncOperationType { create, update, delete }

/// Item in the sync queue representing a pending operation
@HiveType(typeId: 109)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String modelType;

  @HiveField(2)
  final String operation;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  int retryCount;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  String? errorMessage;

  @HiveField(8)
  DateTime? lastRetryAt;

  SyncQueueItem({
    required this.id,
    required this.modelType,
    required this.operation,
    required this.data,
    DateTime? timestamp,
    this.retryCount = 0,
    this.isSynced = false,
    this.errorMessage,
    this.lastRetryAt,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get operation type from string
  SyncOperationType get operationType {
    switch (operation.toLowerCase()) {
      case 'create':
        return SyncOperationType.create;
      case 'update':
        return SyncOperationType.update;
      case 'delete':
        return SyncOperationType.delete;
      default:
        throw ArgumentError('Invalid operation type: $operation');
    }
  }

  /// Check if max retries reached (3 attempts)
  bool get hasExceededMaxRetries => retryCount >= 3;

  /// Check if item needs retry
  bool get needsRetry => !isSynced && !hasExceededMaxRetries;

  /// Check if should retry based on exponential backoff
  bool shouldRetryNow() {
    if (isSynced || hasExceededMaxRetries) return false;
    if (lastRetryAt == null) return true;

    // Exponential backoff: 1min, 5min, 15min
    final backoffMinutes = [1, 5, 15];
    if (retryCount >= backoffMinutes.length) return false;

    final minutesSinceLastRetry = DateTime.now()
        .difference(lastRetryAt!)
        .inMinutes;
    return minutesSinceLastRetry >= backoffMinutes[retryCount];
  }

  SyncQueueItem copyWith({
    String? id,
    String? modelType,
    String? operation,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    bool? isSynced,
    String? errorMessage,
    DateTime? lastRetryAt,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      modelType: modelType ?? this.modelType,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      isSynced: isSynced ?? this.isSynced,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem(id: $id, modelType: $modelType, operation: $operation, '
        'retryCount: $retryCount, isSynced: $isSynced)';
  }
}
