import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

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
      await localDataSource.addAnimal(animalModel);
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi) || 
          connectivityResult.contains(ConnectivityResult.mobile)) {
        try {
          await remoteDataSource.addAnimal(animalModel, _currentUserId);
        } catch (e) {
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
      await localDataSource.updateAnimal(animalModel);
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi) || 
          connectivityResult.contains(ConnectivityResult.mobile)) {
        try {
          await remoteDataSource.updateAnimal(animalModel);
        } catch (e) {
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
      await localDataSource.deleteAnimal(id);
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi) || 
          connectivityResult.contains(ConnectivityResult.mobile)) {
        try {
          await remoteDataSource.deleteAnimal(id);
        } catch (e) {
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
      if (!connectivityResult.contains(ConnectivityResult.wifi) && 
          !connectivityResult.contains(ConnectivityResult.mobile)) {
        return const Left(NetworkFailure(message: 'Sem conexão com internet'));
      }
      final remoteAnimals = await remoteDataSource.getAnimals(_currentUserId);
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
