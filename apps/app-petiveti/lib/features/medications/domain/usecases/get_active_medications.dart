import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class GetActiveMedications implements UseCase<List<Medication>, NoParams> {
  final MedicationRepository repository;

  GetActiveMedications(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(NoParams params) async {
    return await repository.getActiveMedications();
  }
}

class GetActiveMedicationsByAnimalId implements UseCase<List<Medication>, String> {
  final MedicationRepository repository;

  GetActiveMedicationsByAnimalId(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(String animalId) async {
    return await repository.getActiveMedicationsByAnimalId(animalId);
  }
}
