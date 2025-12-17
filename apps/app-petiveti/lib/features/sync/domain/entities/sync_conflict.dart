import 'package:core/core.dart' show Equatable;

/// Resolution strategies for sync conflicts
enum ConflictResolution {
  useLocal,
  useRemote,
  merge,
  skip,
}

/// Represents a conflict during synchronization
class SyncConflict extends Equatable {
  final String id;
  final String entityType;
  final String entityId;
  final DateTime detectedAt;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final ConflictResolution? resolution;
  final DateTime? resolvedAt;

  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.detectedAt,
    required this.localData,
    required this.remoteData,
    this.resolution,
    this.resolvedAt,
  });

  bool get isResolved => resolution != null && resolvedAt != null;

  SyncConflict copyWith({
    String? id,
    String? entityType,
    String? entityId,
    DateTime? detectedAt,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    ConflictResolution? resolution,
    DateTime? resolvedAt,
  }) {
    return SyncConflict(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      detectedAt: detectedAt ?? this.detectedAt,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      resolution: resolution ?? this.resolution,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        detectedAt,
        localData,
        remoteData,
        resolution,
        resolvedAt,
      ];
}
