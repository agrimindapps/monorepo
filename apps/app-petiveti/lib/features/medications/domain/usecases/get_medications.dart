import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Use case for retrieving all medications
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves medications
/// - **Dependency Inversion**: Depends on repository abstraction
class GetMedications implements UseCase<List<Medication>, NoParams> {
  final MedicationRepository repository;

  GetMedications(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(NoParams params) async {
    return await repository.getMedications();
  }
}
