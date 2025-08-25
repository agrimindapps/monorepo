import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_local_datasource.dart';
import '../datasources/animal_remote_datasource.dart';
import '../models/animal_model.dart';

class AnimalRepositoryHybridImpl implements AnimalRepository {
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
    try {
      final localAnimals = await localDataSource.getAnimals();
      
      if (await isConnected) {
        try {
          final remoteAnimals = await remoteDataSource.getAnimals(userId);
          
          // Sync remote data to local
          for (final remoteAnimal in remoteAnimals) {
            final localAnimal = localAnimals.firstWhere(
              (local) => local.id == remoteAnimal.id,
              orElse: () => remoteAnimal, // Use remote if not found locally
            );
            
            // Update local if remote is newer
            if (remoteAnimal.updatedAt.isAfter(localAnimal.updatedAt)) {
              await localDataSource.updateAnimal(remoteAnimal);
            }
          }
          
          // Get updated local data
          final updatedLocalAnimals = await localDataSource.getAnimals();
          return Right(updatedLocalAnimals.map((model) => model.toEntity()).toList());
          
        } catch (e) {
          // If remote fails, use local data
          return Right(localAnimals.map((model) => model.toEntity()).toList());
        }
      }
      
      return Right(localAnimals.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
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
    try {
      final animalModel = AnimalModel.fromEntity(animal);
      
      // Always save locally first (offline-first)
      await localDataSource.addAnimal(animalModel);
      
      if (await isConnected) {
        try {
          // Try to sync to remote
          final remoteId = await remoteDataSource.addAnimal(animalModel, userId);
          
          // Update local with remote ID if different
          if (remoteId != animalModel.id) {
            final updatedModel = animalModel.copyWith(id: remoteId);
            await localDataSource.updateAnimal(updatedModel);
          }
        } catch (e) {
          // Mark for later sync if remote fails
          // TODO: Implement sync queue
        }
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAnimal(Animal animal) async {
    try {
      final animalModel = AnimalModel.fromEntity(animal);
      
      // Always save locally first (offline-first)
      await localDataSource.updateAnimal(animalModel);
      
      if (await isConnected) {
        try {
          // Try to sync to remote
          await remoteDataSource.updateAnimal(animalModel);
        } catch (e) {
          // Mark for later sync if remote fails
          // TODO: Implement sync queue
        }
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnimal(String id) async {
    try {
      // Always delete locally first (offline-first)
      await localDataSource.deleteAnimal(id);
      
      if (await isConnected) {
        try {
          // Try to sync to remote
          await remoteDataSource.deleteAnimal(id);
        } catch (e) {
          // Mark for later sync if remote fails
          // TODO: Implement sync queue
        }
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
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