import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/weight.dart';
import '../repositories/weight_repository.dart';

class GetWeightsByAnimalId implements UseCase<List<Weight>, String> {
  final WeightRepository repository;

  GetWeightsByAnimalId(this.repository);

  @override
  Future<Either<Failure, List<Weight>>> call(String animalId) async {
    return await repository.getWeightsByAnimalId(animalId);
  }
}

class GetLatestWeightByAnimalId implements UseCase<Weight?, String> {
  final WeightRepository repository;

  GetLatestWeightByAnimalId(this.repository);

  @override
  Future<Either<Failure, Weight?>> call(String animalId) async {
    return await repository.getLatestWeightByAnimalId(animalId);
  }
}
