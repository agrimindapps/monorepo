import 'package:core/core.dart';

enum SyncOperationType { create, update, delete }

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
