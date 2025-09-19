/// Represents the status of background synchronization operations
/// This is different from SyncStatus which represents entity sync status
enum BackgroundSyncStatus {
  /// Background sync is not running
  idle,

  /// Background sync is currently in progress
  syncing,

  /// Background sync completed successfully
  completed,

  /// Background sync encountered an error
  error,

  /// Background sync was cancelled
  cancelled,
}

/// Extension to provide human-readable messages for BackgroundSyncStatus
extension BackgroundSyncStatusExtension on BackgroundSyncStatus {
  /// Returns a user-friendly message for the current status
  String get message {
    switch (this) {
      case BackgroundSyncStatus.idle:
        return 'Pronto para sincronizar';
      case BackgroundSyncStatus.syncing:
        return 'Sincronizando dados...';
      case BackgroundSyncStatus.completed:
        return 'Sincronização concluída';
      case BackgroundSyncStatus.error:
        return 'Erro na sincronização';
      case BackgroundSyncStatus.cancelled:
        return 'Sincronização cancelada';
    }
  }

  /// Returns true if sync is currently active
  bool get isActive {
    return this == BackgroundSyncStatus.syncing;
  }

  /// Returns true if sync failed
  bool get hasError {
    return this == BackgroundSyncStatus.error;
  }

  /// Returns true if sync completed successfully
  bool get isCompleted {
    return this == BackgroundSyncStatus.completed;
  }

  /// Returns color indicator for UI
  String get colorIndicator {
    switch (this) {
      case BackgroundSyncStatus.syncing:
        return 'blue';
      case BackgroundSyncStatus.completed:
        return 'green';
      case BackgroundSyncStatus.error:
        return 'red';
      case BackgroundSyncStatus.cancelled:
        return 'orange';
      case BackgroundSyncStatus.idle:
        return 'grey';
    }
  }
}