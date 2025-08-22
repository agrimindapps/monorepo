import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class AddMedication implements UseCase<void, Medication> {
  final MedicationRepository repository;

  AddMedication(this.repository);

  @override
  Future<Either<Failure, void>> call(Medication medication) async {
    // Validate medication data
    if (medication.name.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Nome do medicamento é obrigatório'));
    }
    
    if (medication.dosage.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Dosagem é obrigatória'));
    }
    
    if (medication.frequency.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Frequência é obrigatória'));
    }
    
    if (medication.animalId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }
    
    if (medication.startDate.isAfter(medication.endDate)) {
      return Left(ValidationFailure(message: 'Data de início deve ser anterior à data de fim'));
    }

    // Check for potential conflicts
    final conflictsResult = await repository.checkMedicationConflicts(medication);
    
    return conflictsResult.fold(
      (failure) => Left(failure),
      (conflicts) {
        if (conflicts.isNotEmpty) {
          final conflictNames = conflicts.map((m) => m.name).join(', ');
          return Left(ValidationFailure(
            message: 'Conflito detectado com medicamentos: $conflictNames. Verifique horários e interações.'
          ));
        }
        
        return repository.addMedication(medication);
      },
    );
  }
}