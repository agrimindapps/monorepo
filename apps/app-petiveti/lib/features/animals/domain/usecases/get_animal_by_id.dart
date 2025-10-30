import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animal_repository.dart';
import '../services/animal_validation_service.dart';

/// Use case for retrieving an animal by its ID
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves animal by ID
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
@lazySingleton
class GetAnimalById extends UseCase<Animal?, String> {
  final AnimalRepository repository;
  final AnimalValidationService validationService;

  GetAnimalById(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, Animal?>> call(String params) async {
    // Validate ID
    final validationResult = validationService.validateId(params);
    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unreachable'),
      );
    }

    return await repository.getAnimalById(params);
  }
}
