import 'package:core/core.dart' hide SyncConflict, ConflictResolution;

import '../entities/petiveti_sync_status.dart';
import '../entities/sync_conflict.dart';
import '../entities/sync_operation.dart';

/// Repository interface for sync operations
abstract class ISyncRepository {
  /// Get current sync status with entity-level details
  Future<Either<Failure, PetivetiSyncStatus>> getCurrentStatus();

  /// Watch sync status changes in real-time
  Stream<PetivetiSyncStatus> watchStatus();

  /// Trigger manual sync for all entities
  Future<Either<Failure, void>> triggerFullSync();

  /// Trigger sync for specific entity type
  Future<Either<Failure, void>> triggerEntitySync(PetCareEntityType entityType);

  /// Force emergency sync (medications, appointments)
  Future<Either<Failure, void>> forceEmergencySync();

  /// Get sync operation history
  Future<Either<Failure, List<SyncOperation>>> getOperationHistory({
    int limit = 50,
    PetCareEntityType? entityType,
  });

  /// Get pending conflicts
  Future<Either<Failure, List<SyncConflict>>> getPendingConflicts();

  /// Resolve a sync conflict
  Future<Either<Failure, void>> resolveConflict(
    String conflictId,
    ConflictResolution resolution,
  );

  /// Clear sync queue (remove pending operations)
  Future<Either<Failure, void>> clearSyncQueue();

  /// Retry failed sync operations
  Future<Either<Failure, int>> retryFailedOperations();

  /// Get sync configuration/settings
  Future<Either<Failure, Map<String, dynamic>>> getSyncSettings();

  /// Update sync configuration
  Future<Either<Failure, void>> updateSyncSettings(
    Map<String, dynamic> settings,
  );
}
