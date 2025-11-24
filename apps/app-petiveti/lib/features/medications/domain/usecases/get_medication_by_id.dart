import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import '../services/medication_validation_service.dart';

/// Use case for retrieving a medication by its ID
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves medication by ID
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
class GetMedicationById implements UseCase<Medication, String> {
  final MedicationRepository repository;
  final MedicationValidationService validationService;

  GetMedicationById(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, Medication>> call(String id) async {
    // Validate ID
    final validationResult = validationService.validateId(id);
    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unreachable'),
      );
    }

    return await repository.getMedicationById(id);
  }
}
