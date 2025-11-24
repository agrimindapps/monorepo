import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import '../services/medication_validation_service.dart';
import 'check_medication_conflicts.dart';

/// Use case to add a new medication
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles adding medications
/// - **Dependency Inversion**: Depends on abstractions (repository, services)
/// - **Open/Closed**: Validation logic extracted to service
class AddMedication implements UseCase<void, Medication> {
  final MedicationRepository repository;
  final CheckMedicationConflicts checkConflicts;
  final MedicationValidationService validationService;

  AddMedication(
    this.repository,
    this.checkConflicts,
    this.validationService,
  );

  @override
  Future<Either<Failure, void>> call(Medication medication) async {
    // Validate using centralized service
    final validationResult = validationService.validateForAdd(medication);
    if (validationResult.isLeft()) return validationResult;
    final conflictsResult = await checkConflicts(medication);

    return conflictsResult.fold(
      (failure) => Left(failure),
      (conflicts) {
        if (conflicts.isNotEmpty) {
          final conflictNames = conflicts.map((m) => m.name).join(', ');
          return Left(ValidationFailure(
              message:
                  'Conflito detectado com medicamentos: $conflictNames. Verifique horários e interações.'));
        }

        return repository.addMedication(medication);
      },
    );
  }
}
