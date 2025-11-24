import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animal_repository.dart';
import '../services/animal_validation_service.dart';

/// Use case for updating an existing animal
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles updating animals
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
/// - **Open/Closed**: Validation logic extracted to service
class UpdateAnimal extends UseCase<void, Animal> {
  final AnimalRepository repository;
  final AnimalValidationService validationService;

  UpdateAnimal(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, void>> call(Animal params) async {
    // Validate using centralized service
    final validationResult = validationService.validateForUpdate(params);
    if (validationResult.isLeft()) return validationResult;

    final updatedAnimal = params.copyWith(updatedAt: DateTime.now());

    return await repository.updateAnimal(updatedAnimal);
  }
}
