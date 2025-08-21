import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../repositories/plants_repository.dart';

class DeletePlantUseCase implements UseCase<void, String> {
  final PlantsRepository repository;

  DeletePlantUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Left(ValidationFailure('ID da planta é obrigatório'));
    }

    // Check if plant exists first
    final existingResult = await repository.getPlantById(id);

    return existingResult.fold(
      (failure) => Left(failure),
      (_) => repository.deletePlant(id),
    );
  }
}
