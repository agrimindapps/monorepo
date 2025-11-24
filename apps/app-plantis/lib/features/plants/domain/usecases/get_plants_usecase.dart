import 'package:core/core.dart' hide Column;

import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class GetPlantsUseCase implements UseCase<List<Plant>, NoParams> {
  const GetPlantsUseCase(this.repository);

  final PlantsRepository repository;

  @override
  Future<Either<Failure, List<Plant>>> call(NoParams params) {
    return repository.getPlants();
  }
}
