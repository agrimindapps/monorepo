import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class ScheduleVaccineReminder implements UseCase<Vaccine, ScheduleVaccineReminderParams> {
  final VaccineRepository repository;

  ScheduleVaccineReminder(this.repository);

  @override
  Future<Either<Failure, Vaccine>> call(ScheduleVaccineReminderParams params) async {
    if (params.vaccineId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID da vacina é obrigatório'));
    }

    if (params.reminderDate.isBefore(DateTime.now())) {
      return const Left(ValidationFailure(message: 'Data do lembrete deve ser no futuro'));
    }

    return await repository.scheduleVaccineReminder(
      params.vaccineId,
      params.reminderDate,
    );
  }
}

class ScheduleVaccineReminderParams {
  final String vaccineId;
  final DateTime reminderDate;
  
  const ScheduleVaccineReminderParams({
    required this.vaccineId,
    required this.reminderDate,
  });
}