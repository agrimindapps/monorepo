// TEMPORARILY DISABLED: Migration in progress
/// Conflict resolution for sync operations
/// Implements strategies for resolving conflicts between local and remote data
library;

import 'conflict_resolution_strategy.dart';


class ConflictResolver {
  /// Resolve conflito baseado na estratégia definida (stub during migration)
  dynamic resolveConflict(
    ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) {
    // Stub implementation - just return local data during migration
    return conflictData.localData;
  }
}
