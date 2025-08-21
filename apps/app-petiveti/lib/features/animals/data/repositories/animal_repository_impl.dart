import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_local_datasource.dart';
import '../datasources/animal_remote_datasource.dart';
import '../models/animal_model.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalLocalDataSource localDataSource;
  final AnimalRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  
  // TODO: Get from auth service
  String get _currentUserId => 'temp_user_id';

  AnimalRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<Animal>>> getAnimals() async {
    try {
      final localAnimals = await localDataSource.getAnimals();
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
      
      // Save locally first
      await localDataSource.addAnimal(animalModel);
      
      // Try to sync to remote if online
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          await remoteDataSource.addAnimal(_currentUserId, animalModel);
        } catch (e) {
          // Mark for sync later if remote fails
          print('Remote sync failed, will retry later: $e');
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
      
      // Update locally first
      await localDataSource.updateAnimal(animalModel);
      
      // Try to sync to remote if online
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          await remoteDataSource.updateAnimal(_currentUserId, animalModel);
        } catch (e) {
          // Mark for sync later if remote fails
          print('Remote sync failed, will retry later: $e');
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
      // Delete locally first (soft delete)
      await localDataSource.deleteAnimal(id);
      
      // Try to sync to remote if online
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          await remoteDataSource.deleteAnimal(_currentUserId, id);
        } catch (e) {
          // Mark for sync later if remote fails
          print('Remote sync failed, will retry later: $e');
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
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure(message: 'Sem conexão com internet'));
      }

      // Get remote animals
      final remoteAnimals = await remoteDataSource.getAnimals(_currentUserId);
      
      // Update local cache with remote data
      for (final remoteAnimal in remoteAnimals) {
        await localDataSource.updateAnimal(remoteAnimal);
      }
      
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(NetworkFailure(message: 'Erro na sincronização: $e'));
    }
  }

  @override
  Stream<List<Animal>> watchAnimals() {
    return localDataSource.watchAnimals().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}