import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class UpdateVaccine implements UseCase<Vaccine, Vaccine> {
  final VaccineRepository repository;

  UpdateVaccine(this.repository);

  @override
  Future<Either<Failure, Vaccine>> call(Vaccine vaccine) async {
    // Comprehensive validation
    if (!vaccine.isValid) {
      return const Left(ValidationFailure(message: 'Dados da vacina inválidos'));
    }
    
    if (vaccine.id.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID da vacina é obrigatório'));
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

    // Validate next due date if present
    if (vaccine.nextDueDate != null && vaccine.nextDueDate!.isBefore(vaccine.date)) {
      return const Left(ValidationFailure(message: 'Data da próxima dose deve ser posterior à data de aplicação'));
    }

    // Validate reminder date if present
    if (vaccine.reminderDate != null && vaccine.reminderDate!.isBefore(DateTime.now())) {
      return const Left(ValidationFailure(message: 'Data do lembrete deve ser no futuro'));
    }

    // Ensure updatedAt is current
    final updatedVaccine = vaccine.copyWith(updatedAt: DateTime.now());

    return await repository.updateVaccine(updatedVaccine);
  }
}