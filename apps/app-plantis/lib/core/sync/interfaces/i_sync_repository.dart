import 'package:core/core.dart';

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
}
