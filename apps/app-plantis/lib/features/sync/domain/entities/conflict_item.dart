import 'package:core/core.dart';

/// Strategy for resolving sync conflicts between local and remote data.
///
/// Each strategy defines how to handle conflicting changes:
/// - [newerWins]: Choose the version with the most recent timestamp
/// - [localWins]: Always prefer the local version
/// - [remoteWins]: Always prefer the remote version
/// - [merge]: Attempt to intelligently merge both versions
/// - [manual]: Require user to manually resolve the conflict
enum PlantisConflictStrategy {
  /// Choose the version with the most recent timestamp
  newerWins,

  /// Always prefer the local version
  localWins,

  /// Always prefer the remote version
  remoteWins,

  /// Attempt to intelligently merge both versions
  merge,

  /// Require user to manually resolve the conflict
  manual,
}

/// Represents a conflict between local and remote data during sync.
///
/// Contains all information needed to understand and resolve the conflict:
/// - Identification (id, entity type)
/// - Conflicting data from both sources
/// - When the conflict occurred
/// - Strategy to use for resolution
///
/// This entity is immutable and uses Equatable for value comparison.
/// Use [copyWith] to update the resolution strategy.
class PlantisConflictItem extends Equatable {
  /// Unique identifier for the conflicted item
  final String id;

  /// Type of entity that has a conflict (e.g., 'plant', 'task')
  final String entityType;

  /// Local version of the data
  /// Can be null if item was deleted locally
  final Map<String, dynamic>? localData;

  /// Remote version of the data
  /// Can be null if item was deleted remotely
  final Map<String, dynamic>? remoteData;

  /// When the conflict was detected
  final DateTime timestamp;

  /// Strategy to use for resolving this conflict
  final PlantisConflictStrategy strategy;

  const PlantisConflictItem({
    required this.id,
    required this.entityType,
    this.localData,
    this.remoteData,
    required this.timestamp,
    required this.strategy,
  });

  /// Creates a conflict item with newerWins strategy
  factory PlantisConflictItem.newerWins({
    required String id,
    required String entityType,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
  }) {
    return PlantisConflictItem(
      id: id,
      entityType: entityType,
      localData: localData,
      remoteData: remoteData,
      timestamp: DateTime.now(),
      strategy: PlantisConflictStrategy.newerWins,
    );
  }

  /// Creates a conflict item requiring manual resolution
  factory PlantisConflictItem.requiresManualResolution({
    required String id,
    required String entityType,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
  }) {
    return PlantisConflictItem(
      id: id,
      entityType: entityType,
      localData: localData,
      remoteData: remoteData,
      timestamp: DateTime.now(),
      strategy: PlantisConflictStrategy.manual,
    );
  }

  /// Computed properties for conflict analysis
  bool get hasLocalData => localData != null;
  bool get hasRemoteData => remoteData != null;
  bool get isDeleteConflict => !hasLocalData || !hasRemoteData;
  bool get requiresManualResolution =>
      strategy == PlantisConflictStrategy.manual;

  /// Check if this conflict can be auto-resolved
  bool get canAutoResolve => !requiresManualResolution;

  /// Get the timestamp of the local data if available
  DateTime? get localTimestamp {
    if (localData == null) return null;
    final updatedAt = localData!['updatedAt'];
    if (updatedAt == null) return null;
    if (updatedAt is DateTime) return updatedAt;
    if (updatedAt is int) {
      return DateTime.fromMillisecondsSinceEpoch(updatedAt);
    }
    if (updatedAt is String) return DateTime.tryParse(updatedAt);
    return null;
  }

  /// Get the timestamp of the remote data if available
  DateTime? get remoteTimestamp {
    if (remoteData == null) return null;
    final updatedAt = remoteData!['updated_at'] ?? remoteData!['updatedAt'];
    if (updatedAt == null) return null;
    if (updatedAt is DateTime) return updatedAt;
    if (updatedAt is int) {
      return DateTime.fromMillisecondsSinceEpoch(updatedAt);
    }
    if (updatedAt is String) return DateTime.tryParse(updatedAt);
    return null;
  }

  /// Creates a copy with updated fields
  PlantisConflictItem copyWith({
    String? id,
    String? entityType,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    DateTime? timestamp,
    PlantisConflictStrategy? strategy,
  }) {
    return PlantisConflictItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      timestamp: timestamp ?? this.timestamp,
      strategy: strategy ?? this.strategy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    entityType,
    localData,
    remoteData,
    timestamp,
    strategy,
  ];

  @override
  String toString() {
    return 'PlantisConflictItem('
        'id: $id, '
        'type: $entityType, '
        'strategy: $strategy, '
        'hasLocal: $hasLocalData, '
        'hasRemote: $hasRemoteData, '
        'timestamp: $timestamp'
        ')';
  }
}
