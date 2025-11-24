import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Use case to check for potential medication conflicts
///
/// This use case verifies if a medication conflicts with existing medications
/// based on timing and potential drug interactions.
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only checks for conflicts
/// - **Dependency Inversion**: Depends on repository abstraction
class CheckMedicationConflicts
    implements UseCase<List<Medication>, Medication> {
  final MedicationRepository repository;

  CheckMedicationConflicts(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(Medication medication) async {
    return await repository.checkMedicationConflicts(medication);
  }
}
