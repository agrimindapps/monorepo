import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/entities/log_entry.dart';
import '../../../../core/logging/mixins/loggable_repository_mixin.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_local_datasource.dart';
import '../datasources/animal_remote_datasource.dart';
import '../models/animal_model.dart';

class AnimalRepositoryHybridImpl with LoggableRepositoryMixin implements AnimalRepository {
  final AnimalLocalDataSource localDataSource;
  final AnimalRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  AnimalRepositoryHybridImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi) || 
           result.contains(ConnectivityResult.mobile);
  }

  String get userId {
    // TODO: Get actual user ID from auth service
    return 'user1';
  }

  @override
  Future<Either<Failure, List<Animal>>> getAnimals() async {
    return await logTimedOperation<Either<Failure, List<Animal>>>(
      category: LogCategory.animals,
      operation: LogOperation.read,
      message: 'get all animals',
      operationFunction: () async {
        try {
          await logLocalStorageOperation(
            category: LogCategory.animals,
            operation: LogOperation.read,
            message: 'fetching animals from local storage',
          );
          
          final localAnimals = await localDataSource.getAnimals();
          
          if (await isConnected) {
            try {
              await logRemoteStorageOperation(
                category: LogCategory.animals,
                operation: LogOperation.read,
                message: 'fetching animals from remote storage',
                metadata: {'user_id': userId},
              );
              
              final remoteAnimals = await remoteDataSource.getAnimals(userId);
              
              await logSyncStart(
                category: LogCategory.animals,
                message: 'syncing remote animals to local',
                metadata: {
                  'local_count': localAnimals.length,
                  'remote_count': remoteAnimals.length,
                },
              );
              
              // Sync remote data to local
              int syncedCount = 0;
              for (final remoteAnimal in remoteAnimals) {
                final localAnimal = localAnimals.firstWhere(
                  (local) => local.id == remoteAnimal.id,
                  orElse: () => remoteAnimal, // Use remote if not found locally
                );
                
                // Update local if remote is newer
                if (remoteAnimal.updatedAt.isAfter(localAnimal.updatedAt)) {
                  await localDataSource.updateAnimal(remoteAnimal);
                  syncedCount++;
                }
              }
              
              await logSyncSuccess(
                category: LogCategory.animals,
                message: 'synced animals to local storage',
                metadata: {'synced_count': syncedCount},
              );
              
              // Get updated local data
              final updatedLocalAnimals = await localDataSource.getAnimals();
              final result = updatedLocalAnimals.map((model) => model.toEntity()).toList();
              
              await logOperationSuccess(
                category: LogCategory.animals,
                operation: LogOperation.read,
                message: 'get all animals with sync',
                metadata: {'total_count': result.length},
              );
              
              return Right(result);
              
            } catch (e, stackTrace) {
              await logSyncError(
                category: LogCategory.animals,
                message: 'sync from remote failed, using local data',
                error: e,
                stackTrace: stackTrace,
              );
              
              final result = localAnimals.map((model) => model.toEntity()).toList();
              
              await logOperationSuccess(
                category: LogCategory.animals,
                operation: LogOperation.read,
                message: 'get all animals from local only',
                metadata: {'total_count': result.length},
              );
              
              return Right(result);
            }
          }
          
          final result = localAnimals.map((model) => model.toEntity()).toList();
          
          await logOperationSuccess(
            category: LogCategory.animals,
            operation: LogOperation.read,
            message: 'get all animals offline',
            metadata: {'total_count': result.length, 'offline_mode': true},
          );
          
          return Right(result);
        } on CacheException catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.read,
            message: 'get all animals',
            error: e,
            stackTrace: stackTrace,
          );
          return Left(CacheFailure(message: e.message));
        } catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.read,
            message: 'get all animals',
            error: e,
            stackTrace: stackTrace,
          );
          return Left(CacheFailure(message: 'Erro inesperado: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, Animal?>> getAnimalById(String id) async {
    try {
      final localAnimal = await localDataSource.getAnimalById(id);
      
      if (await isConnected) {
        try {
          final remoteAnimal = await remoteDataSource.getAnimalById(id);
          
          if (remoteAnimal != null) {
            // Update local if remote is newer
            if (localAnimal == null || remoteAnimal.updatedAt.isAfter(localAnimal.updatedAt)) {
              await localDataSource.updateAnimal(remoteAnimal);
              return Right(remoteAnimal.toEntity());
            }
          }
        } catch (e) {
          // If remote fails, use local data
        }
      }
      
      return Right(localAnimal?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addAnimal(Animal animal) async {
    return await logTimedOperation<Either<Failure, void>>(
      category: LogCategory.animals,
      operation: LogOperation.create,
      message: 'add animal',
      metadata: createMetadata(
        entityId: animal.id,
        entityType: 'Animal',
        additional: {
          'name': animal.name,
          'species': animal.species,
          'breed': animal.breed,
        },
      ),
      operationFunction: () async {
        try {
          final animalModel = AnimalModel.fromEntity(animal);
          
          await logLocalStorageOperation(
            category: LogCategory.animals,
            operation: LogOperation.create,
            message: 'saving animal to local storage',
            metadata: {'animal_id': animal.id, 'name': animal.name},
          );
          
          // Always save locally first (offline-first)
          await localDataSource.addAnimal(animalModel);
          
          if (await isConnected) {
            try {
              await logRemoteStorageOperation(
                category: LogCategory.animals,
                operation: LogOperation.create,
                message: 'syncing animal to remote storage',
                metadata: {'animal_id': animal.id, 'user_id': userId},
              );
              
              // Try to sync to remote
              final remoteId = await remoteDataSource.addAnimal(animalModel, userId);
              
              // Update local with remote ID if different
              if (remoteId != animalModel.id) {
                await logLocalStorageOperation(
                  category: LogCategory.animals,
                  operation: LogOperation.update,
                  message: 'updating local animal with remote ID',
                  metadata: {'old_id': animalModel.id, 'new_id': remoteId},
                );
                
                final updatedModel = animalModel.copyWith(id: remoteId);
                await localDataSource.updateAnimal(updatedModel);
              }
              
              await logOperationSuccess(
                category: LogCategory.animals,
                operation: LogOperation.create,
                message: 'add animal with sync',
                metadata: {'animal_id': remoteId, 'synced': true},
              );
              
            } catch (e, stackTrace) {
              await logSyncError(
                category: LogCategory.animals,
                message: 'failed to sync new animal to remote',
                error: e,
                stackTrace: stackTrace,
                metadata: {'animal_id': animal.id},
              );
              
              // Mark for later sync if remote fails
              // TODO: Implement sync queue
              
              await logOperationSuccess(
                category: LogCategory.animals,
                operation: LogOperation.create,
                message: 'add animal local only',
                metadata: {'animal_id': animal.id, 'synced': false},
              );
            }
          } else {
            await logOperationSuccess(
              category: LogCategory.animals,
              operation: LogOperation.create,
              message: 'add animal offline',
              metadata: {'animal_id': animal.id, 'offline_mode': true},
            );
          }
          
          return const Right(null);
        } on CacheException catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.create,
            message: 'add animal',
            error: e,
            stackTrace: stackTrace,
            metadata: {'animal_id': animal.id},
          );
          return Left(CacheFailure(message: e.message));
        } catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.create,
            message: 'add animal',
            error: e,
            stackTrace: stackTrace,
            metadata: {'animal_id': animal.id},
          );
          return Left(CacheFailure(message: 'Erro inesperado: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> updateAnimal(Animal animal) async {
    return await logTimedOperation<Either<Failure, void>>(
      category: LogCategory.animals,
      operation: LogOperation.update,
      message: 'update animal',
      metadata: createMetadata(
        entityId: animal.id,
        entityType: 'Animal',
        additional: {'name': animal.name},
      ),
      operationFunction: () async {
        try {
          final animalModel = AnimalModel.fromEntity(animal);
          
          await logLocalStorageOperation(
            category: LogCategory.animals,
            operation: LogOperation.update,
            message: 'updating animal in local storage',
            metadata: {'animal_id': animal.id},
          );
          
          // Always save locally first (offline-first)
          await localDataSource.updateAnimal(animalModel);
          
          if (await isConnected) {
            try {
              await logRemoteStorageOperation(
                category: LogCategory.animals,
                operation: LogOperation.update,
                message: 'syncing updated animal to remote',
                metadata: {'animal_id': animal.id},
              );
              
              // Try to sync to remote
              await remoteDataSource.updateAnimal(animalModel);
              
              await logOperationSuccess(
                category: LogCategory.animals,
                operation: LogOperation.update,
                message: 'update animal with sync',
                metadata: {'animal_id': animal.id, 'synced': true},
              );
            } catch (e, stackTrace) {
              await logSyncError(
                category: LogCategory.animals,
                message: 'failed to sync updated animal to remote',
                error: e,
                stackTrace: stackTrace,
                metadata: {'animal_id': animal.id},
              );
              // TODO: Implement sync queue
            }
          }
          
          return const Right(null);
        } on CacheException catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.update,
            message: 'update animal',
            error: e,
            stackTrace: stackTrace,
            metadata: {'animal_id': animal.id},
          );
          return Left(CacheFailure(message: e.message));
        } catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.update,
            message: 'update animal',
            error: e,
            stackTrace: stackTrace,
            metadata: {'animal_id': animal.id},
          );
          return Left(CacheFailure(message: 'Erro inesperado: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteAnimal(String id) async {
    return await logTimedOperation<Either<Failure, void>>(
      category: LogCategory.animals,
      operation: LogOperation.delete,
      message: 'delete animal',
      metadata: createMetadata(entityId: id, entityType: 'Animal'),
      operationFunction: () async {
        try {
          await logLocalStorageOperation(
            category: LogCategory.animals,
            operation: LogOperation.delete,
            message: 'deleting animal from local storage',
            metadata: {'animal_id': id},
          );
          
          // Always delete locally first (offline-first)
          await localDataSource.deleteAnimal(id);
          
          if (await isConnected) {
            try {
              await logRemoteStorageOperation(
                category: LogCategory.animals,
                operation: LogOperation.delete,
                message: 'syncing animal deletion to remote',
                metadata: {'animal_id': id},
              );
              
              // Try to sync to remote
              await remoteDataSource.deleteAnimal(id);
              
              await logOperationSuccess(
                category: LogCategory.animals,
                operation: LogOperation.delete,
                message: 'delete animal with sync',
                metadata: {'animal_id': id, 'synced': true},
              );
            } catch (e, stackTrace) {
              await logSyncError(
                category: LogCategory.animals,
                message: 'failed to sync animal deletion to remote',
                error: e,
                stackTrace: stackTrace,
                metadata: {'animal_id': id},
              );
              // TODO: Implement sync queue
            }
          }
          
          return const Right(null);
        } on CacheException catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.delete,
            message: 'delete animal',
            error: e,
            stackTrace: stackTrace,
            metadata: {'animal_id': id},
          );
          return Left(CacheFailure(message: e.message));
        } catch (e, stackTrace) {
          await logOperationError(
            category: LogCategory.animals,
            operation: LogOperation.delete,
            message: 'delete animal',
            error: e,
            stackTrace: stackTrace,
            metadata: {'animal_id': id},
          );
          return Left(CacheFailure(message: 'Erro inesperado: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> syncAnimals() async {
    try {
      if (!(await isConnected)) {
        return const Left(ServerFailure(message: 'Sem conexão com a internet'));
      }

      // Get local and remote data
      final localAnimals = await localDataSource.getAnimals();
      final remoteAnimals = await remoteDataSource.getAnimals(userId);

      // Sync remote to local (conflict resolution: remote wins)
      for (final remoteAnimal in remoteAnimals) {
        final localAnimal = localAnimals.firstWhere(
          (local) => local.id == remoteAnimal.id,
          orElse: () => remoteAnimal,
        );

        if (remoteAnimal.updatedAt.isAfter(localAnimal.updatedAt)) {
          await localDataSource.updateAnimal(remoteAnimal);
        }
      }

      // Sync local to remote (only newer local changes)
      for (final localAnimal in localAnimals) {
        final remoteAnimal = remoteAnimals.firstWhere(
          (remote) => remote.id == localAnimal.id,
          orElse: () => localAnimal,
        );

        if (localAnimal.updatedAt.isAfter(remoteAnimal.updatedAt)) {
          await remoteDataSource.updateAnimal(localAnimal);
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Stream<List<Animal>> watchAnimals() {
    // Always watch local data for real-time updates
    return localDataSource.watchAnimals().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}