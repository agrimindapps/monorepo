import 'package:core/core.dart';

/// Represents the current state of sync for PetiVeti app.
///
/// Provides comprehensive sync status per entity type (animals, medications, etc):
/// - Current sync state (idle, syncing, error, synced)
/// - Number of pending and failed operations per entity
/// - Last sync timestamp
/// - Progress information
///
/// This entity is immutable and uses Equatable for value comparison.
class PetivetiSyncStatus extends Equatable {
  /// Overall sync state
  final SyncStatus state;

  /// Entity-specific sync information
  final Map<PetCareEntityType, EntitySyncInfo> entityStatus;

  /// Timestamp of last successful sync
  final DateTime? lastSyncAt;

  /// Error message if sync failed
  final String? errorMessage;

  /// Overall progress (0.0 to 1.0) if syncing
  final double? progress;

  /// Emergency sync mode enabled
  final bool isEmergencyMode;

  const PetivetiSyncStatus({
    required this.state,
    required this.entityStatus,
    this.lastSyncAt,
    this.errorMessage,
    this.progress,
    this.isEmergencyMode = false,
  }) : assert(
          progress == null || (progress >= 0.0 && progress <= 1.0),
          'Progress must be between 0.0 and 1.0',
        );

  /// Creates an idle sync status
  const PetivetiSyncStatus.idle()
      : state = SyncStatus.offline,
        entityStatus = const {},
        lastSyncAt = null,
        errorMessage = null,
        progress = null,
        isEmergencyMode = false;

  /// Creates a syncing status
  PetivetiSyncStatus.syncing({
    required this.entityStatus,
    this.progress,
  })  : state = SyncStatus.syncing,
        lastSyncAt = null,
        errorMessage = null,
        isEmergencyMode = false;

  /// Creates a synced status
  PetivetiSyncStatus.synced({
    required this.entityStatus,
    DateTime? syncTime,
  })  : state = SyncStatus.synced,
        lastSyncAt = syncTime ?? DateTime.now(),
        errorMessage = null,
        progress = null,
        isEmergencyMode = false;

  /// Creates an error status
  const PetivetiSyncStatus.error({
    required String message,
    required this.entityStatus,
  })  : state = SyncStatus.error,
        lastSyncAt = null,
        errorMessage = message,
        progress = null,
        isEmergencyMode = false;

  /// Computed properties
  bool get isIdle => state == SyncStatus.offline;
  bool get isSyncing => state == SyncStatus.syncing;
  bool get hasError => state == SyncStatus.error;
  bool get isSynced => state == SyncStatus.synced;

  /// Check if any entity has pending items
  bool get hasPendingItems =>
      entityStatus.values.any((info) => info.pendingCount > 0);

  /// Check if any entity has failed items
  bool get hasFailedItems =>
      entityStatus.values.any((info) => info.failedCount > 0);

  /// Total pending items across all entities
  int get totalPendingCount =>
      entityStatus.values.fold(0, (total, info) => total + info.pendingCount);

  /// Total failed items across all entities
  int get totalFailedCount =>
      entityStatus.values.fold(0, (total, info) => total + info.failedCount);

  /// Progress percentage (0-100)
  int? get progressPercentage =>
      progress != null ? (progress! * 100).round() : null;

  /// Get sync info for specific entity
  EntitySyncInfo? getEntityInfo(PetCareEntityType type) => entityStatus[type];

  /// Creates a copy with updated fields
  PetivetiSyncStatus copyWith({
    SyncStatus? state,
    Map<PetCareEntityType, EntitySyncInfo>? entityStatus,
    DateTime? lastSyncAt,
    String? errorMessage,
    double? progress,
    bool? isEmergencyMode,
  }) {
    return PetivetiSyncStatus(
      state: state ?? this.state,
      entityStatus: entityStatus ?? this.entityStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      errorMessage: errorMessage,
      progress: progress,
      isEmergencyMode: isEmergencyMode ?? this.isEmergencyMode,
    );
  }

  @override
  List<Object?> get props => [
        state,
        entityStatus,
        lastSyncAt,
        errorMessage,
        progress,
        isEmergencyMode,
      ];

  @override
  String toString() {
    return 'PetivetiSyncStatus('
        'state: $state, '
        'pending: $totalPendingCount, '
        'failed: $totalFailedCount, '
        'lastSync: $lastSyncAt, '
        'emergency: $isEmergencyMode'
        ')';
  }
}

/// Information about sync status for a specific entity type
class EntitySyncInfo extends Equatable {
  final PetCareEntityType type;
  final int pendingCount;
  final int failedCount;
  final int syncedCount;
  final DateTime? lastSyncAt;
  final String? error;

  const EntitySyncInfo({
    required this.type,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.syncedCount = 0,
    this.lastSyncAt,
    this.error,
  });

  bool get hasPending => pendingCount > 0;
  bool get hasFailed => failedCount > 0;
  bool get hasError => error != null;

  EntitySyncInfo copyWith({
    PetCareEntityType? type,
    int? pendingCount,
    int? failedCount,
    int? syncedCount,
    DateTime? lastSyncAt,
    String? error,
  }) {
    return EntitySyncInfo(
      type: type ?? this.type,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      syncedCount: syncedCount ?? this.syncedCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        type,
        pendingCount,
        failedCount,
        syncedCount,
        lastSyncAt,
        error,
      ];
}

/// Entity types supported in PetiVeti
enum PetCareEntityType {
  animal,
  medication,
  vaccine,
  appointment,
  weight,
  expense,
  reminder;

  String get displayName {
    switch (this) {
      case PetCareEntityType.animal:
        return 'Animais';
      case PetCareEntityType.medication:
        return 'Medicações';
      case PetCareEntityType.vaccine:
        return 'Vacinas';
      case PetCareEntityType.appointment:
        return 'Consultas';
      case PetCareEntityType.weight:
        return 'Peso';
      case PetCareEntityType.expense:
        return 'Despesas';
      case PetCareEntityType.reminder:
        return 'Lembretes';
    }
  }
}
