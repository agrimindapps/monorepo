import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_queue_item.g.dart';

enum SyncOperationType { create, update, delete }

@HiveType(typeId: 100)
@JsonSerializable()
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'modelType')
  final String modelType;

  @HiveField(2)
  @JsonKey(name: 'operation')
  final String operation;

  @HiveField(3)
  @JsonKey(name: 'data')
  final Map<String, dynamic> data;

  @HiveField(4)
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  @HiveField(5)
  @JsonKey(name: 'retryCount')
  int retryCount;

  @HiveField(6)
  @JsonKey(name: 'isSynced')
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

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);

  Map<String, dynamic> toJson() => _$SyncQueueItemToJson(this);

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
