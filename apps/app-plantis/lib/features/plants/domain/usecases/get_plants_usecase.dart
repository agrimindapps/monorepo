import 'package:core/core.dart';

import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class GetPlantsUseCase implements UseCase<List<Plant>, NoParams> {
  final PlantsRepository repository;

  GetPlantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Plant>>> call(NoParams params) {
    return repository.getPlants();
  }
}

class GetPlantByIdUseCase implements UseCase<Plant, String> {
  final PlantsRepository repository;

  GetPlantByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Plant>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('ID da planta é obrigatório')),
      );
    }
    return repository.getPlantById(id);
  }
}

class SearchPlantsUseCase implements UseCase<List<Plant>, SearchPlantsParams> {
  final PlantsRepository repository;

  SearchPlantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Plant>>> call(SearchPlantsParams params) {
    if (params.query.trim().isEmpty) {
      return repository.getPlants(); // Return all plants if query is empty
    }
    return repository.searchPlants(params.query);
  }
}

class SearchPlantsParams {
  final String query;

  const SearchPlantsParams(this.query);
}
