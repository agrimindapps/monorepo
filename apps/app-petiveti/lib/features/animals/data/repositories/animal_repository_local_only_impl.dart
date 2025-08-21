import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_local_datasource.dart';
import '../models/animal_model.dart';

class AnimalRepositoryLocalOnlyImpl implements AnimalRepository {
  final AnimalLocalDataSource localDataSource;

  AnimalRepositoryLocalOnlyImpl({
    required this.localDataSource,
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
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncAnimals() async {
    // No remote sync in local-only implementation
    return const Right(null);
  }

  @override
  Stream<List<Animal>> watchAnimals() {
    return localDataSource.watchAnimals().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}