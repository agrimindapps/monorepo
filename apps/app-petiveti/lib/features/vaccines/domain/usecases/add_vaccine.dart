import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class AddVaccine implements UseCase<Vaccine, Vaccine> {
  final VaccineRepository repository;

  AddVaccine(this.repository);

  @override
  Future<Either<Failure, Vaccine>> call(Vaccine vaccine) async {
    if (!vaccine.isValid) {
      return const Left(ValidationFailure(message: 'Dados da vacina inválidos'));
    }
    
    if (vaccine.name.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Nome da vacina é obrigatório'));
    }
    
    if (vaccine.veterinarian.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Nome do veterinário é obrigatório'));
    }
    
    if (vaccine.animalId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Animal deve ser selecionado'));
    }

    if (vaccine.date.isAfter(DateTime.now())) {
      return const Left(ValidationFailure(message: 'Data de aplicação não pode ser no futuro'));
    }
    if (vaccine.nextDueDate != null && vaccine.nextDueDate!.isBefore(vaccine.date)) {
      return const Left(ValidationFailure(message: 'Data da próxima dose deve ser posterior à data de aplicação'));
    }
    if (vaccine.reminderDate != null && vaccine.reminderDate!.isBefore(DateTime.now())) {
      return const Left(ValidationFailure(message: 'Data do lembrete deve ser no futuro'));
    }

    return await repository.addVaccine(vaccine);
  }
}
