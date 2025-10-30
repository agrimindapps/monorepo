import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animal_repository.dart';
import '../services/animal_validation_service.dart';

/// Use case for adding a new animal
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles adding animals
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
/// - **Open/Closed**: Validation logic extracted to service
@lazySingleton
class AddAnimal extends UseCase<void, Animal> {
  final AnimalRepository repository;
  final AnimalValidationService validationService;

  AddAnimal(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, void>> call(Animal params) async {
    // Validate using centralized service
    final validationResult = validationService.validateForAdd(params);
    if (validationResult.isLeft()) return validationResult;

    return await repository.addAnimal(params);
  }
}
