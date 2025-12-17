import 'package:core/core.dart' show Equatable;

/// Represents the synchronization status of an entity
class SyncStatus extends Equatable {
  final String entityType;
  final int pendingCount;
  final int syncedCount;
  final int errorCount;
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final String? error;

  const SyncStatus({
    required this.entityType,
    required this.pendingCount,
    required this.syncedCount,
    required this.errorCount,
    this.lastSyncTime,
    this.isSyncing = false,
    this.error,
  });

  bool get hasPending => pendingCount > 0;
  bool get hasErrors => errorCount > 0;
  bool get isIdle => !isSyncing && !hasPending && !hasErrors;

  SyncStatus copyWith({
    String? entityType,
    int? pendingCount,
    int? syncedCount,
    int? errorCount,
    DateTime? lastSyncTime,
    bool? isSyncing,
    String? error,
  }) {
    return SyncStatus(
      entityType: entityType ?? this.entityType,
      pendingCount: pendingCount ?? this.pendingCount,
      syncedCount: syncedCount ?? this.syncedCount,
      errorCount: errorCount ?? this.errorCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        entityType,
        pendingCount,
        syncedCount,
        errorCount,
        lastSyncTime,
        isSyncing,
        error,
      ];
}
