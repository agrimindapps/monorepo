import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../data/models/base_sync_model.dart';
import '../data/models/sync_queue_item.dart';
import './sync_queue.dart';
import './sync_operations.dart';
import 'interfaces/i_sync_repository.dart';
import 'interfaces/i_conflict_resolver.dart';
import 'sync_status.dart';

/// Service responsible for synchronization operations
@singleton
class SyncService<T extends BaseSyncModel> {
  final ISyncRepository<T> _repository;
  final IConflictResolver<T> _conflictResolver;
  final SyncQueue _syncQueue;
  final SyncOperations _syncOperations;

  SyncService({
    required ISyncRepository<T> repository,
    required IConflictResolver<T> conflictResolver,
    required SyncQueue syncQueue,
    required SyncOperations syncOperations,
  })  : _repository = repository,
        _conflictResolver = conflictResolver,
        _syncQueue = syncQueue,
        _syncOperations = syncOperations {
    // Initialize sync operations when service is created
    _initializeSyncQueue();
  }

  void _initializeSyncQueue() {
    // Start processing any pending offline items
    _syncOperations.processOfflineQueue();
  }

  /// Synchronize a single entity
  Future<Either<Exception, T>> syncEntity(T localEntity) async {
    if (!_repository.needsSync(localEntity)) {
      return Right(localEntity);
    }

    try {
      final remoteResult = await _repository.getRemoteById(localEntity.id);

      return await remoteResult.fold(
        (failure) async {
          // If no remote entity exists, create new
          // Add to sync queue for offline processing
          _addToSyncQueue(localEntity, 'create');
          final syncResult = await _repository.sync(localEntity);
          return syncResult.fold(
            (syncFailure) => Left(Exception(syncFailure.toString())),
            (syncedEntity) => Right(syncedEntity),
          );
        },
        (remoteEntity) async {
          // Conflict detection and resolution
          if (_hasConflict(localEntity, remoteEntity)) {
            final resolvedEntity = _resolveConflict(localEntity, remoteEntity);
            
            // Add resolved entity to sync queue
            _addToSyncQueue(resolvedEntity, 'update');
            
            final syncResult = await _repository.sync(resolvedEntity);
            return syncResult.fold(
              (syncFailure) => Left(Exception(syncFailure.toString())),
              (syncedEntity) => Right(syncedEntity),
            );
          }

          // No conflict, sync local entity
          _addToSyncQueue(localEntity, 'update');
          final syncResult = await _repository.sync(localEntity);
          return syncResult.fold(
            (syncFailure) => Left(Exception(syncFailure.toString())),
            (syncedEntity) => Right(syncedEntity),
          );
        },
      );
    } catch (e) {
      return Left(Exception('Sync failed: ${e.toString()}'));
    }
  }

  void _addToSyncQueue(T entity, String operation) {
    _syncQueue.addToQueue(
      modelType: entity.runtimeType.toString(),
      operation: operation,
      data: entity.toJson(),
    );
  }

  /// Synchronize multiple entities
  Future<Either<Exception, List<T>>> syncBatch(List<T> entities) async {
    final syncResults = <T>[];

    for (final entity in entities) {
      final result = await syncEntity(entity);
      result.fold(
        (failure) => null, // Handle or log individual sync failures
        (syncedEntity) => syncResults.add(syncedEntity),
      );
    }

    return Right(syncResults);
  }

  /// Detect conflicts between local and remote entities
  bool _hasConflict(T localEntity, T remoteEntity) {
    return localEntity.version != remoteEntity.version;
  }

  /// Resolve conflicts using conflict resolver
  T _resolveConflict(T localEntity, T remoteEntity) {
    return _conflictResolver.resolveConflict(localEntity, remoteEntity);
  }
}