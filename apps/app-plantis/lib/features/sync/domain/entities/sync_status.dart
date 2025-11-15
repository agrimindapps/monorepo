import 'package:core/core.dart';

/// Represents the current state of the sync process.
///
/// Provides comprehensive sync status information including:
/// - Current sync state (idle, syncing, error, success)
/// - Number of pending and failed operations
/// - Last sync timestamp
/// - Error message if sync failed
/// - Progress percentage for ongoing operations
///
/// This entity is immutable and uses Equatable for value comparison.
/// Use [copyWith] to create modified instances.
enum PlantisSyncState {
  /// Sync is idle - no active operations
  idle,

  /// Sync is currently in progress
  syncing,

  /// Sync encountered an error
  error,

  /// Sync completed successfully
  success,
}

class PlantisSyncStatus extends Equatable {
  /// Current state of the sync process
  final PlantisSyncState state;

  /// Number of items pending sync
  final int pendingCount;

  /// Number of items that failed to sync
  final int failedCount;

  /// Timestamp of last successful sync
  final DateTime? lastSyncAt;

  /// Error message if sync failed
  final String? errorMessage;

  /// Progress of current sync operation (0.0 to 1.0)
  /// Null if not syncing
  final double? progress;

  const PlantisSyncStatus({
    required this.state,
    required this.pendingCount,
    required this.failedCount,
    this.lastSyncAt,
    this.errorMessage,
    this.progress,
  }) : assert(
          progress == null || (progress >= 0.0 && progress <= 1.0),
          'Progress must be between 0.0 and 1.0',
        );

  /// Creates an idle sync status with no pending operations
  const PlantisSyncStatus.idle()
      : state = PlantisSyncState.idle,
        pendingCount = 0,
        failedCount = 0,
        lastSyncAt = null,
        errorMessage = null,
        progress = null;

  /// Creates a syncing status with optional progress
  const PlantisSyncStatus.syncing({
    required int pendingCount,
    double? progress,
  })  : state = PlantisSyncState.syncing,
        pendingCount = pendingCount,
        failedCount = 0,
        lastSyncAt = null,
        errorMessage = null,
        progress = progress;

  /// Creates a success status after sync completion
  PlantisSyncStatus.success({DateTime? syncTime})
      : state = PlantisSyncState.success,
        pendingCount = 0,
        failedCount = 0,
        lastSyncAt = syncTime ?? DateTime.now(),
        errorMessage = null,
        progress = null;

  /// Creates an error status with failure details
  const PlantisSyncStatus.error({
    required String message,
    int pendingCount = 0,
    int failedCount = 0,
  })  : state = PlantisSyncState.error,
        pendingCount = pendingCount,
        failedCount = failedCount,
        lastSyncAt = null,
        errorMessage = message,
        progress = null;

  /// Computed properties for UI
  bool get isIdle => state == PlantisSyncState.idle;
  bool get isSyncing => state == PlantisSyncState.syncing;
  bool get hasError => state == PlantisSyncState.error;
  bool get isSuccess => state == PlantisSyncState.success;
  bool get hasPendingItems => pendingCount > 0;
  bool get hasFailedItems => failedCount > 0;

  /// Progress percentage (0-100) for display
  int? get progressPercentage =>
      progress != null ? (progress! * 100).round() : null;

  /// Creates a copy with updated fields
  PlantisSyncStatus copyWith({
    PlantisSyncState? state,
    int? pendingCount,
    int? failedCount,
    DateTime? lastSyncAt,
    String? errorMessage,
    double? progress,
  }) {
    return PlantisSyncStatus(
      state: state ?? this.state,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
        state,
        pendingCount,
        failedCount,
        lastSyncAt,
        errorMessage,
        progress,
      ];

  @override
  String toString() {
    return 'PlantisSyncStatus('
        'state: $state, '
        'pending: $pendingCount, '
        'failed: $failedCount, '
        'lastSync: $lastSyncAt, '
        'error: $errorMessage, '
        'progress: ${progressPercentage ?? 'N/A'}%'
        ')';
  }
}
