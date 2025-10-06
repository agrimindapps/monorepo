import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class MarkVaccineCompleted implements UseCase<Vaccine, String> {
  final VaccineRepository repository;

  MarkVaccineCompleted(this.repository);

  @override
  Future<Either<Failure, Vaccine>> call(String vaccineId) async {
    if (vaccineId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID da vacina é obrigatório'));
    }
    final vaccineResult = await repository.getVaccineById(vaccineId);
    
    return vaccineResult.fold(
      (failure) => Left(failure),
      (vaccine) {
        if (vaccine == null) {
          return const Left(ValidationFailure(message: 'Vacina não encontrada'));
        }

        if (!vaccine.canBeMarkedAsCompleted()) {
          return const Left(ValidationFailure(message: 'Esta vacina não pode ser marcada como concluída'));
        }

        final completedVaccine = vaccine.markAsCompleted();
        return repository.updateVaccine(completedVaccine);
      },
    );
  }
}
