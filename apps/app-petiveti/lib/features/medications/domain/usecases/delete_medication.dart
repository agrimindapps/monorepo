import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/medication_repository.dart';
import '../services/medication_validation_service.dart';

/// Use case for deleting a medication
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles deleting medications
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
@lazySingleton
class DeleteMedication implements UseCase<void, String> {
  final MedicationRepository repository;
  final MedicationValidationService validationService;

  DeleteMedication(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, void>> call(String id) async {
    // Validate ID
    final validationResult = validationService.validateId(id);
    if (validationResult.isLeft()) return validationResult;

    return await repository.deleteMedication(id);
  }
}

/// Use case for discontinuing a medication with a reason
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles discontinuing medications
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
@lazySingleton
class DiscontinueMedication
    implements UseCase<void, DiscontinueMedicationParams> {
  final MedicationRepository repository;
  final MedicationValidationService validationService;

  DiscontinueMedication(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, void>> call(DiscontinueMedicationParams params) async {
    // Validate ID
    final idValidation = validationService.validateId(params.id);
    if (idValidation.isLeft()) return idValidation;

    // Validate reason
    final reasonValidation =
        validationService.validateDiscontinuationReason(params.reason);
    if (reasonValidation.isLeft()) return reasonValidation;

    return await repository.discontinueMedication(params.id, params.reason);
  }
}

class DiscontinueMedicationParams {
  final String id;
  final String reason;

  const DiscontinueMedicationParams({
    required this.id,
    required this.reason,
  });
}
