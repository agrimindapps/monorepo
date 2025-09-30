import 'package:core/core.dart';

import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

@injectable
class GetPlantsUseCase implements UseCase<List<Plant>, NoParams> {
  const GetPlantsUseCase(this.repository);

  final PlantsRepository repository;

  @override
  Future<Either<Failure, List<Plant>>> call(NoParams params) {
    return repository.getPlants();
  }
}

@injectable
class GetPlantByIdUseCase implements UseCase<Plant, String> {
  const GetPlantByIdUseCase(this.repository);

  final PlantsRepository repository;

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

@injectable
class SearchPlantsUseCase implements UseCase<List<Plant>, SearchPlantsParams> {
  const SearchPlantsUseCase(this.repository);

  final PlantsRepository repository;

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
