import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';
import '../services/vaccine_validation_service.dart';

/// Use case for updating an existing vaccine
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles updating vaccines
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
class UpdateVaccine implements UseCase<Vaccine, Vaccine> {
  final VaccineRepository repository;
  final VaccineValidationService validationService;

  UpdateVaccine(this.repository, this.validationService);

  @override
  Future<Either<Failure, Vaccine>> call(Vaccine vaccine) async {
    // Use centralized validation service
    final validationResult = validationService.validateForUpdate(vaccine);
    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => const Left(ValidationFailure(message: 'Erro de validação')),
      );
    }

    final updatedVaccine = vaccine.copyWith(updatedAt: DateTime.now());
    return await repository.updateVaccine(updatedVaccine);
  }
}
