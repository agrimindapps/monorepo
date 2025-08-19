import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

enum SyncOperationType {
  create,
  update,
  delete
}

@HiveType(typeId: 100)
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
  final String? userId;

  @HiveField(8)
  final int priority;

  @HiveField(9)
  DateTime? lastRetryAt;

  @HiveField(10)
  String? errorMessage;

  SyncQueueItem({
    required this.id,
    required this.modelType,
    required this.operation,
    required this.data,
    DateTime? timestamp,
    this.retryCount = 0,
    this.isSynced = false,
    this.userId,
    this.priority = 0,
    this.lastRetryAt,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      modelType: json['modelType'] as String,
      operation: json['operation'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      retryCount: json['retryCount'] as int? ?? 0,
      isSynced: json['isSynced'] as bool? ?? false,
      userId: json['userId'] as String?,
      priority: json['priority'] as int? ?? 0,
      lastRetryAt: json['lastRetryAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastRetryAt'] as int)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelType': modelType,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'retryCount': retryCount,
      'isSynced': isSynced,
      'userId': userId,
      'priority': priority,
      'lastRetryAt': lastRetryAt?.millisecondsSinceEpoch,
      'errorMessage': errorMessage,
    };
  }

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

  int get calculatedPriority {
    switch (operationType) {
      case SyncOperationType.create:
        return 3;
      case SyncOperationType.update:
        return 2;
      case SyncOperationType.delete:
        return 1;
    }
  }

  bool get shouldRetry => retryCount < 3;
  
  bool get isRetryDue {
    if (lastRetryAt == null) return true;
    final nextRetryTime = lastRetryAt!.add(Duration(minutes: retryCount * 5));
    return DateTime.now().isAfter(nextRetryTime);
  }

  SyncQueueItem copyWith({
    String? id,
    String? modelType,
    String? operation,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    bool? isSynced,
    String? userId,
    int? priority,
    DateTime? lastRetryAt,
    String? errorMessage,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      modelType: modelType ?? this.modelType,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
      priority: priority ?? this.priority,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem(id: $id, modelType: $modelType, operation: $operation, '
           'retryCount: $retryCount, isSynced: $isSynced, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}