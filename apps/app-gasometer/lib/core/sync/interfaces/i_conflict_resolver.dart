import '../../data/models/base_sync_model.dart';
import '../models/conflict_data.dart';
import '../strategies/conflict_resolution_strategy.dart';

/// Interface for conflict resolution
abstract class IConflictResolver<T extends BaseSyncModel> {
  /// Resolve conflict between local and remote entities
  T resolveConflict(
    ConflictData<T> conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  });

  /// Merge two entities intelligently
  T mergeEntities(T localEntity, T remoteEntity);

  /// Check if two entities have conflicts
  bool hasConflict(T localEntity, T remoteEntity);

  /// Get conflict information
  ConflictData<T> getConflictData(T localEntity, T remoteEntity);
}