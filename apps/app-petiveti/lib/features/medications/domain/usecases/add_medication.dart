import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import 'check_medication_conflicts.dart';

/// Use case to add a new medication
///
/// This use case validates medication data and delegates conflict checking
/// to CheckMedicationConflicts use case, following Single Responsibility Principle.
class AddMedication implements UseCase<void, Medication> {
  final MedicationRepository repository;
  final CheckMedicationConflicts checkConflicts;

  AddMedication(this.repository, this.checkConflicts);

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
    final conflictsResult = await checkConflicts(medication);

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
