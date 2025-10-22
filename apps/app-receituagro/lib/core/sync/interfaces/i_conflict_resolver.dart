import '../../data/models/base_sync_model.dart';
import '../conflict_resolution_strategy.dart';

/// Interface for conflict resolution during synchronization
abstract class IConflictResolver<T extends BaseSyncModel> {
  /// Resolve conflict between local and remote entities
  T resolveConflict(T local, T remote);

  /// Resolve conflict using specific strategy
  T resolveConflictWithStrategy(
    T local,
    T remote,
    ConflictResolutionStrategy strategy,
  );
}
