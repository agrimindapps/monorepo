import '../../domain/entities/sync_operation.dart';

/// Data model for SyncOperation entity
class SyncOperationModel extends SyncOperation {
  const SyncOperationModel({
    required super.id,
    required super.entityType,
    required super.operationType,
    required super.timestamp,
    required super.success,
    super.error,
    super.itemsAffected,
    super.metadata,
  });

  factory SyncOperationModel.fromEntity(SyncOperation entity) {
    return SyncOperationModel(
      id: entity.id,
      entityType: entity.entityType,
      operationType: entity.operationType,
      timestamp: entity.timestamp,
      success: entity.success,
      error: entity.error,
      itemsAffected: entity.itemsAffected,
      metadata: entity.metadata,
    );
  }

  factory SyncOperationModel.fromJson(Map<String, dynamic> json) {
    return SyncOperationModel(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      operationType: SyncOperationType.values.firstWhere(
        (e) => e.toString() == 'SyncOperationType.${json['operationType']}',
        orElse: () => SyncOperationType.full,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
      error: json['error'] as String?,
      itemsAffected: json['itemsAffected'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'operationType': operationType.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'error': error,
      'itemsAffected': itemsAffected,
      'metadata': metadata,
    };
  }

  SyncOperation toEntity() => this;
}
