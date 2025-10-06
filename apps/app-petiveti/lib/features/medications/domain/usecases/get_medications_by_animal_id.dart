import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class GetMedicationsByAnimalId implements UseCase<List<Medication>, String> {
  final MedicationRepository repository;

  GetMedicationsByAnimalId(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(String animalId) async {
    return await repository.getMedicationsByAnimalId(animalId);
  }
}
