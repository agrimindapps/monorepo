import '../../domain/entities/sync_status.dart';

/// Data model for SyncStatus entity
class SyncStatusModel extends SyncStatus {
  const SyncStatusModel({
    required super.entityType,
    required super.pendingCount,
    required super.syncedCount,
    required super.errorCount,
    super.lastSyncTime,
    super.isSyncing,
    super.error,
  });

  factory SyncStatusModel.fromEntity(SyncStatus entity) {
    return SyncStatusModel(
      entityType: entity.entityType,
      pendingCount: entity.pendingCount,
      syncedCount: entity.syncedCount,
      errorCount: entity.errorCount,
      lastSyncTime: entity.lastSyncTime,
      isSyncing: entity.isSyncing,
      error: entity.error,
    );
  }

  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      entityType: json['entityType'] as String,
      pendingCount: json['pendingCount'] as int,
      syncedCount: json['syncedCount'] as int,
      errorCount: json['errorCount'] as int,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
      isSyncing: json['isSyncing'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'pendingCount': pendingCount,
      'syncedCount': syncedCount,
      'errorCount': errorCount,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'isSyncing': isSyncing,
      'error': error,
    };
  }

  SyncStatus toEntity() => this;
}
