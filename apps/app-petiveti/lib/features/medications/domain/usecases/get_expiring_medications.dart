import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class GetExpiringSoonMedications implements UseCase<List<Medication>, NoParams> {
  final MedicationRepository repository;

  GetExpiringSoonMedications(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(NoParams params) async {
    return await repository.getExpiringSoonMedications();
  }
}
