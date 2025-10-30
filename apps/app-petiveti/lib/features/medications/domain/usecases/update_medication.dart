import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import '../services/medication_validation_service.dart';

/// Use case for updating an existing medication
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles updating medications
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
/// - **Open/Closed**: Validation logic extracted to service
@lazySingleton
class UpdateMedication implements UseCase<void, Medication> {
  final MedicationRepository repository;
  final MedicationValidationService validationService;

  UpdateMedication(
    this.repository,
    this.validationService,
  );

  @override
  Future<Either<Failure, void>> call(Medication medication) async {
    // Validate using centralized service
    final validationResult = validationService.validateForUpdate(medication);
    if (validationResult.isLeft()) return validationResult;

    return await repository.updateMedication(medication);
  }
}
