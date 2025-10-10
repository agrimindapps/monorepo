import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/local/example_local_datasource.dart';
import '../datasources/remote/example_remote_datasource.dart';
import '../models/example_model.dart';

/// Implementation of ExampleRepository
/// Follows offline-first pattern: local data first, then sync with remote
@LazySingleton(as: ExampleRepository)
class ExampleRepositoryImpl implements ExampleRepository {
  ExampleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final ExampleLocalDataSource localDataSource;
  final ExampleRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<ExampleEntity>>> getExamples() async {
    try {
      // Get from local storage first (offline-first)
      final localModels = await localDataSource.getAll();
      final localEntities = localModels.map((m) => m.toEntity()).toList();

      // Try to fetch fresh data from remote
      try {
        final remoteModels = await remoteDataSource.getAll();

        // Save to local storage
        await localDataSource.saveAll(remoteModels);

        final remoteEntities = remoteModels.map((m) => m.toEntity()).toList();
        return Right(remoteEntities);
      } catch (e) {
        // Remote fetch failed, return local data
        return Right(localEntities);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> getExampleById(String id) async {
    try {
      // Try local first
      final localModel = await localDataSource.getById(id);

      if (localModel != null) {
        // Try to fetch fresh data from remote
        try {
          final remoteModel = await remoteDataSource.getById(id);
          if (remoteModel != null) {
            await localDataSource.update(remoteModel);
            return Right(remoteModel.toEntity());
          }
        } catch (e) {
          // Remote fetch failed, return local data
          return Right(localModel.toEntity());
        }

        return Right(localModel.toEntity());
      }

      // Not in local, try remote
      final remoteModel = await remoteDataSource.getById(id);
      if (remoteModel == null) {
        return const Left(CacheFailure('Example not found'));
      }

      // Save to local
      await localDataSource.add(remoteModel);
      return Right(remoteModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> addExample(
    ExampleEntity example,
  ) async {
    try {
      final model = ExampleModel.fromEntity(example);

      // Save to local first (offline-first)
      await localDataSource.add(model);

      // Try to sync with remote
      try {
        await remoteDataSource.add(model);

        // Mark as synced (not dirty)
        final syncedModel = ExampleModel.fromEntity(
          example.copyWith(isDirty: false),
        );
        await localDataSource.update(syncedModel);

        return Right(syncedModel.toEntity());
      } catch (e) {
        // Remote save failed, but local succeeded
        // Keep isDirty = true for later sync
        return Right(example);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> updateExample(
    ExampleEntity example,
  ) async {
    try {
      final model = ExampleModel.fromEntity(example);

      // Update local first
      await localDataSource.update(model);

      // Try to sync with remote
      try {
        await remoteDataSource.update(model);

        // Mark as synced (not dirty)
        final syncedModel = ExampleModel.fromEntity(
          example.copyWith(isDirty: false),
        );
        await localDataSource.update(syncedModel);

        return Right(syncedModel.toEntity());
      } catch (e) {
        // Remote update failed, but local succeeded
        return Right(example);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExample(String id) async {
    try {
      // Delete from local first
      await localDataSource.delete(id);

      // Try to delete from remote
      try {
        await remoteDataSource.delete(id);
      } catch (e) {
        // Remote delete failed, but local succeeded
        // This is acceptable for offline-first pattern
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Sync dirty (unsynced) examples with remote
  /// This can be called periodically or on network reconnection
  Future<Either<Failure, void>> syncDirtyExamples() async {
    try {
      final dirtyModels = await localDataSource.getDirty();

      for (final model in dirtyModels) {
        try {
          // Check if exists on remote
          final remoteModel = await remoteDataSource.getById(model.id);

          if (remoteModel != null) {
            // Update existing
            await remoteDataSource.update(model);
          } else {
            // Add new
            await remoteDataSource.add(model);
          }

          // Mark as synced
          model.isDirty = false;
          await localDataSource.update(model);
        } catch (e) {
          // Skip this item, continue with others
          continue;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
