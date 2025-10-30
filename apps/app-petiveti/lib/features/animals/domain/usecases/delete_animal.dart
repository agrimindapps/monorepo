import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/animal_repository.dart';
import '../services/animal_validation_service.dart';

/// Use case for deleting an animal
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles deleting animals
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
@lazySingleton
class DeleteAnimal extends UseCase<void, String> {
  final AnimalRepository repository;
  final AnimalValidationService validationService;

  DeleteAnimal(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, void>> call(String params) async {
    // Validate ID
    final validationResult = validationService.validateId(params);
    if (validationResult.isLeft()) return validationResult;

    return await repository.deleteAnimal(params);
  }
}
