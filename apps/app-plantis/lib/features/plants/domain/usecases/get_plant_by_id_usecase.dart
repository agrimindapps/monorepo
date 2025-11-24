import 'package:core/core.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class GetPlantByIdUseCase implements UseCase<Plant, String> {
  final PlantsRepository repository;

  GetPlantByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Plant>> call(String id) {
    return repository.getPlantById(id);
  }
}
