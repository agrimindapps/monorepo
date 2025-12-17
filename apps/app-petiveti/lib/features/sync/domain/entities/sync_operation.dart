import 'package:core/core.dart' show Equatable;

/// Types of sync operations
enum SyncOperationType {
  create,
  update,
  delete,
  full,
}

/// Represents a synchronization operation log entry
class SyncOperation extends Equatable {
  final String id;
  final String entityType;
  final SyncOperationType operationType;
  final DateTime timestamp;
  final bool success;
  final String? error;
  final int itemsAffected;
  final Map<String, dynamic>? metadata;

  const SyncOperation({
    required this.id,
    required this.entityType,
    required this.operationType,
    required this.timestamp,
    required this.success,
    this.error,
    this.itemsAffected = 0,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        entityType,
        operationType,
        timestamp,
        success,
        error,
        itemsAffected,
        metadata,
      ];
}
