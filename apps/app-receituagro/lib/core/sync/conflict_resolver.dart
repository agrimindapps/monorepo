// TEMPORARILY DISABLED: Hive to Drift migration in progress
/// Conflict resolution for sync operations
/// Implements strategies for resolving conflicts between local and remote data
import 'package:core/core.dart' hide ConflictResolutionStrategy, Column;

import 'conflict_resolution_strategy.dart';

@injectable
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
