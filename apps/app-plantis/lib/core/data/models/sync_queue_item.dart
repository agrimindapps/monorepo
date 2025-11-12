import 'package:core/core.dart' hide Column;


enum SyncOperationType { create, update, delete }

class SyncQueueItem extends HiveObject {
  final String id;

  final String modelType;

  final String operation;

  final Map<String, dynamic> data;

  final DateTime timestamp;

  int retryCount;

  bool isSynced;

  SyncQueueItem({
    required this.id,
    required this.modelType,
    required this.operation,
    required this.data,
    DateTime? timestamp,
    this.retryCount = 0,
    this.isSynced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  SyncOperationType get operationType {
    switch (operation) {
      case 'create':
        return SyncOperationType.create;
      case 'update':
        return SyncOperationType.update;
      case 'delete':
        return SyncOperationType.delete;
      default:
        throw ArgumentError('Invalid operation type');
    }
  }

  SyncQueueItem copyWith({
    String? id,
    String? modelType,
    String? operation,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    bool? isSynced,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      modelType: modelType ?? this.modelType,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
