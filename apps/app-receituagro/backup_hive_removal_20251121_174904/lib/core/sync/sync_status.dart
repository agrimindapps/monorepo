/// Synchronization status for entities
enum SyncStatus {
  /// Entity is pending synchronization
  pending,

  /// Entity is currently being synchronized
  syncing,

  /// Entity has been successfully synchronized
  synced,

  /// Synchronization failed
  failed,

  /// Entity has a conflict that needs resolution
  conflict,
}

extension SyncStatusExtension on SyncStatus {
  bool get isPending => this == SyncStatus.pending;
  bool get isSyncing => this == SyncStatus.syncing;
  bool get isSynced => this == SyncStatus.synced;
  bool get isFailed => this == SyncStatus.failed;
  bool get isConflict => this == SyncStatus.conflict;
  bool get needsSync => isPending || isFailed;
}
