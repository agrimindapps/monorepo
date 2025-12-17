import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/sync_conflict.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/sync_status.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/sync_local_datasource.dart';
import '../datasources/sync_remote_datasource.dart';
import '../models/sync_operation_model.dart';

/// Implementation of ISyncRepository
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Coordinates sync operations between local and remote
/// - **Dependency Inversion**: Depends on datasource abstractions
class SyncRepositoryImpl implements ISyncRepository {
  final SyncRemoteDataSource remoteDataSource;
  final SyncLocalDataSource localDataSource;

  SyncRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Map<String, SyncStatus>>> getSyncStatus() async {
    try {
      final statusMap = await remoteDataSource.getSyncStatus();
      return Right(statusMap);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get sync status: $e'));
    }
  }

  @override
  Future<Either<Failure, SyncStatus>> getSyncStatusByEntity(
    String entityType,
  ) async {
    try {
      final status = await remoteDataSource.getSyncStatusByEntity(entityType);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to get sync status for $entityType: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> forceSyncEntity(String entityType) async {
    try {
      await remoteDataSource.forceSyncEntity(entityType);

      // Log operation to history
      await localDataSource.saveSyncOperation(
        SyncOperationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          entityType: entityType,
          operationType: SyncOperationType.full,
          timestamp: DateTime.now(),
          success: true,
        ),
      );

      return const Right(null);
    } catch (e) {
      // Log failed operation
      await localDataSource.saveSyncOperation(
        SyncOperationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          entityType: entityType,
          operationType: SyncOperationType.full,
          timestamp: DateTime.now(),
          success: false,
          error: e.toString(),
        ),
      );

      return Left(ServerFailure(message: 'Failed to sync $entityType: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forceSyncAll() async {
    try {
      await remoteDataSource.forceSyncAll();

      // Log operation to history
      await localDataSource.saveSyncOperation(
        SyncOperationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          entityType: 'all',
          operationType: SyncOperationType.full,
          timestamp: DateTime.now(),
          success: true,
        ),
      );

      return const Right(null);
    } catch (e) {
      // Log failed operation
      await localDataSource.saveSyncOperation(
        SyncOperationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          entityType: 'all',
          operationType: SyncOperationType.full,
          timestamp: DateTime.now(),
          success: false,
          error: e.toString(),
        ),
      );

      return Left(ServerFailure(message: 'Failed to sync all entities: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncOperation>>> getSyncHistory({
    int limit = 50,
    String? entityType,
  }) async {
    try {
      // Get from local storage first
      final localHistory = await localDataSource.getSyncHistory(
        limit: limit,
        entityType: entityType,
      );

      // Could also merge with remote history if available
      final remoteHistory = await remoteDataSource.getSyncHistory(
        limit: limit,
        entityType: entityType,
      );

      // Combine and deduplicate
      final combined = {...localHistory, ...remoteHistory}.toList();
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return Right(combined.take(limit).toList());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get sync history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncConflict>>> getSyncConflicts({
    String? entityType,
  }) async {
    try {
      // Get from local storage first
      final localConflicts = await localDataSource.getSyncConflicts(
        entityType: entityType,
      );

      // Could also check remote conflicts if available
      final remoteConflicts = await remoteDataSource.getSyncConflicts(
        entityType: entityType,
      );

      // Combine and deduplicate by ID
      final Map<String, SyncConflict> conflictsMap = {};
      for (final conflict in [...localConflicts, ...remoteConflicts]) {
        conflictsMap[conflict.id] = conflict;
      }

      return Right(conflictsMap.values.toList());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get sync conflicts: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveConflict(
    String conflictId,
    ConflictResolution resolution,
  ) async {
    try {
      await remoteDataSource.resolveConflict(conflictId, resolution);
      await localDataSource.removeConflict(conflictId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to resolve conflict: $e',
      ));
    }
  }

  @override
  Stream<Map<String, SyncStatus>> watchSyncStatus() {
    return remoteDataSource.watchSyncStatus();
  }

  @override
  Future<Either<Failure, void>> cancelSync() async {
    try {
      await remoteDataSource.cancelSync();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to cancel sync: $e'));
    }
  }
}
