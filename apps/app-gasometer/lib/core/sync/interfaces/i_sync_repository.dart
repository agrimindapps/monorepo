import 'package:dartz/dartz.dart';

import '../../error/failures.dart';
import '../../data/models/base_sync_model.dart';

/// Repository interface for synchronization operations
abstract class ISyncRepository<T extends BaseSyncModel> {
  /// Synchronize a single entity with remote storage
  Future<Either<Failure, T>> sync(T entity);

  /// Synchronize multiple entities with remote storage
  Future<Either<Failure, List<T>>> syncBatch(List<T> entities);

  /// Retrieve remote entity by ID
  Future<Either<Failure, T>> getRemoteById(String id);

  /// Handle conflict resolution for synchronization
  Future<Either<Failure, T>> resolveConflict(T localEntity, T remoteEntity);

  /// Check if entity needs synchronization
  bool needsSync(T entity);

  /// Get all entities that need synchronization
  Future<Either<Failure, List<T>>> getUnsyncedEntities();

  /// Mark entity as synced
  Future<Either<Failure, T>> markAsSynced(T entity, {DateTime? syncTime});

  /// Check for conflicts between local and remote
  Future<Either<Failure, bool>> hasConflict(T localEntity, T remoteEntity);
}