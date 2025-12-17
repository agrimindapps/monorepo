import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/sync_conflict.dart';
import '../entities/sync_operation.dart';
import '../entities/sync_status.dart';

/// Repository interface for sync operations
/// 
/// **SOLID Principles:**
/// - **Interface Segregation**: Specific sync operations only
/// - **Dependency Inversion**: Domain depends on abstraction
abstract class ISyncRepository {
  /// Get sync status for all entities
  Future<Either<Failure, Map<String, SyncStatus>>> getSyncStatus();

  /// Get sync status for a specific entity type
  Future<Either<Failure, SyncStatus>> getSyncStatusByEntity(String entityType);

  /// Force sync for a specific entity type
  Future<Either<Failure, void>> forceSyncEntity(String entityType);

  /// Force sync for all entities
  Future<Either<Failure, void>> forceSyncAll();

  /// Get sync history (recent operations)
  Future<Either<Failure, List<SyncOperation>>> getSyncHistory({
    int limit = 50,
    String? entityType,
  });

  /// Get unresolved sync conflicts
  Future<Either<Failure, List<SyncConflict>>> getSyncConflicts({
    String? entityType,
  });

  /// Resolve a sync conflict
  Future<Either<Failure, void>> resolveConflict(
    String conflictId,
    ConflictResolution resolution,
  );

  /// Watch sync status changes (stream)
  Stream<Map<String, SyncStatus>> watchSyncStatus();

  /// Cancel ongoing sync operations
  Future<Either<Failure, void>> cancelSync();
}
