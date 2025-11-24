import 'package:core/core.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class SearchPlantsUseCase implements UseCase<List<Plant>, SearchPlantsParams> {
  final PlantsRepository repository;

  SearchPlantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Plant>>> call(SearchPlantsParams params) {
    return repository.searchPlants(params.query);
  }
}

class SearchPlantsParams {
  final String query;

  const SearchPlantsParams(this.query);
}
