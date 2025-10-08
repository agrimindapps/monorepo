import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../error/exceptions.dart';
import '../../error/failures.dart';

/// Base repository that provides common connectivity and sync logic
/// Eliminates duplication across feature repositories
abstract class BaseRepository {
  final Connectivity connectivity;

  BaseRepository(this.connectivity);

  /// Executes an operation with automatic connectivity handling and local/remote fallback
  ///
  /// **Strategy**: Network-first with local fallback
  /// - If online: try remote → cache locally → return
  /// - If remote fails: fallback to local data
  /// - If offline: use local data only
  ///
  /// **Type Parameters**:
  /// - [T]: Entity type (domain layer)
  /// - [M]: Model type (data layer)
  ///
  /// **Parameters**:
  /// - [remoteOperation]: Fetches data from remote source (Firebase)
  /// - [localOperation]: Fetches data from local source (Hive)
  /// - [cacheOperation]: Caches remote data locally
  /// - [toEntity]: Converts model to entity
  Future<Either<Failure, List<T>>> executeWithSync<T, M>({
    required Future<List<M>> Function() remoteOperation,
    required Future<List<M>> Function() localOperation,
    required Future<void> Function(List<M>) cacheOperation,
    required T Function(M) toEntity,
  }) async {
    try {
      final isConnected = await checkConnectivity();

      if (isConnected) {
        return await _executeSyncStrategy(
          remoteOperation,
          localOperation,
          cacheOperation,
          toEntity,
        );
      }

      return await _executeLocalOnly(localOperation, toEntity);
    } catch (e) {
      if (e is CacheException) {
        return Left(CacheFailure(message: e.message));
      } else if (e is ServerException) {
        return Left(ServerFailure(message: e.message));
      } else {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  /// Executes single item operation with sync
  Future<Either<Failure, T?>> executeWithSyncSingle<T, M>({
    required Future<M?> Function() remoteOperation,
    required Future<M?> Function() localOperation,
    required Future<void> Function(M) cacheOperation,
    required T Function(M) toEntity,
  }) async {
    try {
      final isConnected = await checkConnectivity();

      if (isConnected) {
        return await _executeSyncStrategySingle(
          remoteOperation,
          localOperation,
          cacheOperation,
          toEntity,
        );
      }

      return await _executeLocalOnlySingle(localOperation, toEntity);
    } catch (e) {
      if (e is CacheException) {
        return Left(CacheFailure(message: e.message));
      } else if (e is ServerException) {
        return Left(ServerFailure(message: e.message));
      } else {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  /// Checks network connectivity
  ///
  /// Protected method accessible by subclasses for custom sync strategies
  @protected
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      // If connectivity check fails, assume offline
      return false;
    }
  }

  /// Sync strategy: try remote, cache locally, fallback to local if fails
  Future<Either<Failure, List<T>>> _executeSyncStrategy<T, M>(
    Future<List<M>> Function() remoteOperation,
    Future<List<M>> Function() localOperation,
    Future<void> Function(List<M>) cacheOperation,
    T Function(M) toEntity,
  ) async {
    try {
      // Try remote first
      final remoteData = await remoteOperation();

      // Cache locally for offline access
      try {
        await cacheOperation(remoteData);
      } catch (cacheError) {
        // Log cache failure but don't fail the operation
        // TODO: Add logging service
      }

      // Convert and return
      return Right(remoteData.map((model) => toEntity(model)).toList());
    } catch (remoteError) {
      // Remote failed, fallback to local
      try {
        final localData = await localOperation();
        return Right(localData.map((model) => toEntity(model)).toList());
      } catch (localError) {
        // Both failed
        if (remoteError is ServerException) {
          return Left(ServerFailure(message: remoteError.message));
        }
        return Left(CacheFailure(message: remoteError.toString()));
      }
    }
  }

  /// Sync strategy for single item
  Future<Either<Failure, T?>> _executeSyncStrategySingle<T, M>(
    Future<M?> Function() remoteOperation,
    Future<M?> Function() localOperation,
    Future<void> Function(M) cacheOperation,
    T Function(M) toEntity,
  ) async {
    try {
      // Try remote first
      final remoteData = await remoteOperation();

      if (remoteData == null) {
        // Try local if remote returns null
        final localData = await localOperation();
        return Right(localData != null ? toEntity(localData) : null);
      }

      // Cache locally
      try {
        await cacheOperation(remoteData);
      } catch (cacheError) {
        // Log but don't fail
      }

      return Right(toEntity(remoteData));
    } catch (remoteError) {
      // Remote failed, fallback to local
      try {
        final localData = await localOperation();
        return Right(localData != null ? toEntity(localData) : null);
      } catch (localError) {
        if (remoteError is ServerException) {
          return Left(ServerFailure(message: remoteError.message));
        }
        return Left(CacheFailure(message: remoteError.toString()));
      }
    }
  }

  /// Local-only strategy: use cached data
  Future<Either<Failure, List<T>>> _executeLocalOnly<T, M>(
    Future<List<M>> Function() localOperation,
    T Function(M) toEntity,
  ) async {
    try {
      final localData = await localOperation();
      return Right(localData.map((model) => toEntity(model)).toList());
    } catch (e) {
      if (e is CacheException) {
        return Left(CacheFailure(message: e.message));
      }
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Local-only strategy for single item
  Future<Either<Failure, T?>> _executeLocalOnlySingle<T, M>(
    Future<M?> Function() localOperation,
    T Function(M) toEntity,
  ) async {
    try {
      final localData = await localOperation();
      return Right(localData != null ? toEntity(localData) : null);
    } catch (e) {
      if (e is CacheException) {
        return Left(CacheFailure(message: e.message));
      }
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
