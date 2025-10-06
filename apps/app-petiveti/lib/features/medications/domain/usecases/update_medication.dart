import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class UpdateMedication implements UseCase<void, Medication> {
  final MedicationRepository repository;

  UpdateMedication(this.repository);

  @override
  Future<Either<Failure, void>> call(Medication medication) async {
    if (medication.name.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Nome do medicamento é obrigatório'));
    }
    
    if (medication.dosage.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Dosagem é obrigatória'));
    }
    
    if (medication.frequency.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Frequência é obrigatória'));
    }
    
    if (medication.animalId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }
    
    if (medication.startDate.isAfter(medication.endDate)) {
      return const Left(ValidationFailure(message: 'Data de início deve ser anterior à data de fim'));
    }

    return await repository.updateMedication(medication);
  }
}