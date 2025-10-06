import 'package:core/core.dart';

import '../../sync/sync_status.dart' as local;

/// Base sync model for all Hive models in the Plantis app
/// Integrates with core package's BaseSyncEntity for Firebase sync
///
/// Note: Cannot be @immutable due to HiveObjectMixin requirements
abstract class BaseSyncModel extends BaseSyncEntity
    with HiveObjectMixin, SyncEntityMixin {
  /// Field to track last user who modified the entity
  final String? lastModifiedBy;

  /// Current synchronization status of the entity
  final local.SyncStatus syncStatus;

  /// Additional conflict information
  final Map<String, dynamic>? conflictData;
  BaseSyncModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName = 'plantis',
    this.lastModifiedBy,
    this.syncStatus = local.SyncStatus.pending,
    this.conflictData,
  });

  /// Convert to Hive-compatible map (using millisecond timestamps)
  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
      'userId': userId,
      'moduleName': moduleName,
    };
  }

  /// Parse base fields from Hive map
  static Map<String, dynamic> parseBaseHiveFields(Map<String, dynamic> map) {
    return {
      'id': map['id'] as String,
      'createdAt':
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : null,
      'updatedAt':
          map['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
              : null,
      'lastSyncAt':
          map['lastSyncAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncAt'] as int)
              : null,
      'isDirty': map['isDirty'] as bool? ?? false,
      'isDeleted': map['isDeleted'] as bool? ?? false,
      'version': map['version'] as int? ?? 1,
      'userId': map['userId'] as String?,
      'moduleName': map['moduleName'] as String? ?? 'plantis',
    };
  }

  /// Update timestamps for Hive operations
  BaseSyncModel updateTimestamps() {
    return copyWith(updatedAt: DateTime.now(), isDirty: true) as BaseSyncModel;
  }

  /// Mark as synced with Firebase
  @override
  BaseSyncModel markAsSynced({DateTime? syncTime}) {
    return copyWith(lastSyncAt: syncTime ?? DateTime.now(), isDirty: false)
        as BaseSyncModel;
  }

  /// Mark as dirty (needs sync)
  @override
  BaseSyncModel markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now()) as BaseSyncModel;
  }

  /// Mark as deleted (soft delete)
  @override
  BaseSyncModel markAsDeleted() {
    return copyWith(isDeleted: true, isDirty: true, updatedAt: DateTime.now())
        as BaseSyncModel;
  }

  /// Increment version for conflict resolution
  @override
  BaseSyncModel incrementVersion() {
    return copyWith(
          version: version + 1,
          isDirty: true,
          updatedAt: DateTime.now(),
        )
        as BaseSyncModel;
  }

  /// Set user owner
  @override
  BaseSyncModel withUserId(String userId) {
    return copyWith(userId: userId) as BaseSyncModel;
  }

  /// Set module name
  @override
  BaseSyncModel withModule(String moduleName) {
    return copyWith(moduleName: moduleName) as BaseSyncModel;
  }

  /// Collection name for Firebase (must be implemented by subclasses)
  String get collectionName;

  /// Validation for Firebase sync
  bool get isValidForSync {
    return validateForSync(this) &&
        id.isNotEmpty &&
        userId?.isNotEmpty == true &&
        !isDeleted;
  }

  /// Get Firebase document path
  String getFirebasePath() {
    if (userId == null || userId!.isEmpty) {
      throw Exception('userId is required for Firebase operations');
    }
    return '$collectionName/${userId!}/$id';
  }

  /// Convert timestamps for Firebase (ISO8601 strings)
  Map<String, dynamic> get firebaseTimestampFields => {
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'last_sync_at': lastSyncAt?.toIso8601String(),
    'last_modified_by': lastModifiedBy,
    'sync_status': syncStatus.index,
    'conflict_data': conflictData,
  };

  /// Parse timestamps and sync fields from Firebase
  static Map<String, dynamic> parseFirebaseFields(Map<String, dynamic> map) {
    final baseFields = parseBaseFirebaseFields(map);
    return {
      ...baseFields,
      'lastModifiedBy': map['last_modified_by'] as String?,
      'syncStatus':
          map['sync_status'] != null
              ? local.SyncStatus.values[map['sync_status'] as int]
              : local.SyncStatus.pending,
      'conflictData': map['conflict_data'] as Map<String, dynamic>?,
    };
  }

  /// Parse timestamps from Firebase (ISO8601 strings)
  static Map<String, DateTime?> parseFirebaseTimestamps(
    Map<String, dynamic> map,
  ) {
    return {
      'createdAt':
          map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null,
      'updatedAt':
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'] as String)
              : null,
      'lastSyncAt':
          map['last_sync_at'] != null
              ? DateTime.parse(map['last_sync_at'] as String)
              : null,
    };
  }

  /// Parse base fields from Firebase map (delegates to core)
  static Map<String, dynamic> parseBaseFirebaseFields(
    Map<String, dynamic> map,
  ) {
    return BaseSyncEntity.parseBaseFirebaseFields(map);
  }

  /// Prepara dados para batch sync
  Map<String, dynamic> prepareBatchSyncData(List<BaseSyncModel> models) {
    return prepareBatchData(models);
  }

  /// Calcula hash do conteúdo para detecção de mudanças
  String getContentHash() {
    return calculateContentHash(toFirebaseMap());
  }

  Map<String, dynamic> toJson() {
    return {
      ...toHiveMap(),
      'lastModifiedBy': lastModifiedBy,
      'syncStatus': syncStatus.index,
      'conflictData': conflictData,
    };
  }

  /// Resolve conflito usando estratégia do core
  @override
  BaseSyncModel resolveConflictWith(BaseSyncEntity other) {
    if (other is! BaseSyncModel) return this;
    final resolved = super.resolveConflictWith(other);
    return resolved as BaseSyncModel;
  }

  /// Verifica se pode ser mesclado
  @override
  bool canMergeWith(BaseSyncEntity other) {
    return other is BaseSyncModel && super.canMergeWith(other);
  }

  /// Getters úteis do core herdados automaticamente
}
