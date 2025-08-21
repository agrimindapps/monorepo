import '../../../core/data/models/base_sync_model.dart';

/// Interface for resolving synchronization conflicts
abstract class IConflictResolver<T extends BaseSyncModel> {
  /// Resolve conflict between local and remote entities
  T resolveConflict(T localEntity, T remoteEntity);

  /// Determine which version of the entity should take precedence
  bool shouldUseRemoteVersion(T localEntity, T remoteEntity);

  /// Merge conflicting entities
  T mergeEntities(T localEntity, T remoteEntity);
}
