import 'package:core/core.dart' show HiveObject, HiveField;

/// Base model class for all Hive models in the GasOMeter app
/// Provides common fields for sync and versioning
abstract class BaseModel extends HiveObject {
  BaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    isDeleted = false,
    this.needsSync = true,
    this.lastSyncAt,
    version = 1,
  }) {
    id ??= DateTime.now().millisecondsSinceEpoch.toString();
    createdAt ??= DateTime.now().millisecondsSinceEpoch;
    updatedAt ??= DateTime.now().millisecondsSinceEpoch;
  }
  @HiveField(0)
  String? id;

  @HiveField(1)
  int? createdAt;

  @HiveField(2)
  int? updatedAt;

  @HiveField(3)
  bool isDeleted = false;

  @HiveField(4)
  bool needsSync;

  @HiveField(5)
  int? lastSyncAt;

  @HiveField(6)
  int version = 1;

  /// Convert to map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'needsSync': needsSync,
      'lastSyncAt': lastSyncAt,
      'version': version,
    };
  }

  /// Update timestamps
  void updateTimestamps() {
    updatedAt = DateTime.now().millisecondsSinceEpoch;
    needsSync = true;
  }

  /// Mark as synced
  void markAsSynced() {
    needsSync = false;
    lastSyncAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// Soft delete
  void softDelete() {
    isDeleted = true;
    updateTimestamps();
  }

  /// Restore from soft delete
  void restore() {
    isDeleted = false;
    updateTimestamps();
  }
}
