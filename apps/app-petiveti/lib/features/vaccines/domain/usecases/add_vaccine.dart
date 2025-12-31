import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';
import '../services/vaccine_validation_service.dart';

/// Use case for adding a new vaccine
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles adding vaccines
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
class AddVaccine implements UseCase<Vaccine, Vaccine> {
  final VaccineRepository repository;
  final VaccineValidationService validationService;

  AddVaccine(this.repository, this.validationService);

  @override
  Future<Either<Failure, Vaccine>> call(Vaccine vaccine) async {
    // Use centralized validation service
    final validationResult = validationService.validateForAdd(vaccine);
    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => const Left(ValidationFailure(message: 'Erro de validação')),
      );
    }

    return await repository.addVaccine(vaccine);
  }
}
