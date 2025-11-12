/// Base model class for all models in the GasOMeter app
/// Provides common fields for sync and versioning
abstract class BaseModel {
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
  String? id;

  int? createdAt;

  int? updatedAt;

  bool isDeleted = false;

  bool needsSync;

  int? lastSyncAt;

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
