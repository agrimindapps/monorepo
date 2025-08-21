import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/animal.dart';

abstract class AnimalRepository {
  Future<Either<Failure, List<Animal>>> getAnimals();
  Future<Either<Failure, Animal?>> getAnimalById(String id);
  Future<Either<Failure, void>> addAnimal(Animal animal);
  Future<Either<Failure, void>> updateAnimal(Animal animal);
  Future<Either<Failure, void>> deleteAnimal(String id);
  Future<Either<Failure, void>> syncAnimals();
  Stream<List<Animal>> watchAnimals();
}