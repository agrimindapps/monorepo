// TEMPORARILY DISABLED: Hive to Drift migration in progress
// Minimal stub implementation - full implementation in conflict_resolver_original.dart
import 'package:core/core.dart' hide ConflictResolutionStrategy, Column;

import '../data/models/base_sync_model.dart';
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
