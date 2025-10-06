import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class GetMedicationById implements UseCase<Medication, String> {
  final MedicationRepository repository;

  GetMedicationById(this.repository);

  @override
  Future<Either<Failure, Medication>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do medicamento é obrigatório'));
    }
    
    return await repository.getMedicationById(id);
  }
}
