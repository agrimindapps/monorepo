/// Represents the synchronization status of an entity
enum SyncStatus {
  /// Entity is synchronized with remote
  synced,

  /// Entity has local changes not yet synchronized
  pending,

  /// Conflict detected during synchronization
  conflict,

  /// Entity is marked for deletion but not yet synchronized
  markedForDeletion,

  /// Synchronization failed
  failed
}