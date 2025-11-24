import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Use case for retrieving all active medications
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves active medications
/// - **Dependency Inversion**: Depends on repository abstraction
class GetActiveMedications implements UseCase<List<Medication>, NoParams> {
  final MedicationRepository repository;

  GetActiveMedications(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(NoParams params) async {
    return await repository.getActiveMedications();
  }
}

/// Use case for retrieving active medications for a specific animal
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves active medications by animal
/// - **Dependency Inversion**: Depends on repository abstraction
class GetActiveMedicationsByAnimalId
    implements UseCase<List<Medication>, String> {
  final MedicationRepository repository;

  GetActiveMedicationsByAnimalId(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(String animalId) async {
    return await repository.getActiveMedicationsByAnimalId(animalId);
  }
}
