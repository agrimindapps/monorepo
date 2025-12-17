import '../../domain/entities/sync_conflict.dart';

/// Data model for SyncConflict entity
class SyncConflictModel extends SyncConflict {
  const SyncConflictModel({
    required super.id,
    required super.entityType,
    required super.entityId,
    required super.detectedAt,
    required super.localData,
    required super.remoteData,
    super.resolution,
    super.resolvedAt,
  });

  factory SyncConflictModel.fromEntity(SyncConflict entity) {
    return SyncConflictModel(
      id: entity.id,
      entityType: entity.entityType,
      entityId: entity.entityId,
      detectedAt: entity.detectedAt,
      localData: entity.localData,
      remoteData: entity.remoteData,
      resolution: entity.resolution,
      resolvedAt: entity.resolvedAt,
    );
  }

  factory SyncConflictModel.fromJson(Map<String, dynamic> json) {
    return SyncConflictModel(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      localData: json['localData'] as Map<String, dynamic>,
      remoteData: json['remoteData'] as Map<String, dynamic>,
      resolution: json['resolution'] != null
          ? ConflictResolution.values.firstWhere(
              (e) =>
                  e.toString() == 'ConflictResolution.${json['resolution']}',
            )
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'detectedAt': detectedAt.toIso8601String(),
      'localData': localData,
      'remoteData': remoteData,
      'resolution': resolution?.toString().split('.').last,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  SyncConflict toEntity() => this;
}
