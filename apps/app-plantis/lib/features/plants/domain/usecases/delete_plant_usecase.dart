import 'package:core/core.dart';

import '../repositories/plants_repository.dart';

@injectable
class DeletePlantUseCase implements UseCase<void, String> {
  const DeletePlantUseCase(this.repository);

  final PlantsRepository repository;

  @override
  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID da planta é obrigatório'));
    }
    final existingResult = await repository.getPlantById(id);

    return existingResult.fold(
      (failure) => Left(failure),
      (_) => repository.deletePlant(id),
    );
  }
}
