import 'package:core/core.dart';

/// Base sync model for all models in the GasOMeter app
/// Integrates with core package's BaseSyncEntity for Firebase sync
abstract class BaseSyncModel extends BaseSyncEntity {
  BaseSyncModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName = 'gasometer',
  });
  /// Update timestamps for operations
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
    return id.isNotEmpty && userId?.isNotEmpty == true && !isDeleted;
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
  };

  /// Parse timestamps from Firebase (Timestamp or ISO8601 strings)
  static Map<String, DateTime?> parseFirebaseTimestamps(
    Map<String, dynamic> map,
  ) {
    return {
      'createdAt': _parseTimestamp(map['created_at']),
      'updatedAt': _parseTimestamp(map['updated_at']),
      'lastSyncAt': _parseTimestamp(map['last_sync_at']),
    };
  }

  /// Helper method to parse timestamp from various formats
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    } else if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Parse base fields from Firebase map (delegate to BaseSyncEntity)
  static Map<String, dynamic> parseBaseFirebaseFields(
    Map<String, dynamic> map,
  ) {
    return BaseSyncEntity.parseBaseFirebaseFields(map);
  }

  /// Default toFirebaseMap implementation
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {...baseFirebaseFields, ...firebaseTimestampFields};
  }
}
