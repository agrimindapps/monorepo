import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class UpdateReminder implements UseCase<void, Reminder> {
  final ReminderRepository repository;

  UpdateReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(Reminder reminder) async {
    if (reminder.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Título do lembrete é obrigatório'));
    }

    if (reminder.isRecurring && (reminder.recurringDays == null || reminder.recurringDays! <= 0)) {
      return const Left(ValidationFailure(message: 'Intervalo de recorrência deve ser maior que zero'));
    }

    return await repository.updateReminder(reminder);
  }
}

class CompleteReminder implements UseCase<void, String> {
  final ReminderRepository repository;

  CompleteReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(String reminderId) async {
    return await repository.completeReminder(reminderId);
  }
}

class SnoozeReminderParams {
  final String reminderId;
  final DateTime snoozeUntil;

  SnoozeReminderParams({
    required this.reminderId,
    required this.snoozeUntil,
  });
}

class SnoozeReminder implements UseCase<void, SnoozeReminderParams> {
  final ReminderRepository repository;

  SnoozeReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(SnoozeReminderParams params) async {
    if (params.snoozeUntil.isBefore(DateTime.now())) {
      return const Left(ValidationFailure(message: 'Data de adiamento deve ser futura'));
    }

    return await repository.snoozeReminder(params.reminderId, params.snoozeUntil);
  }
}
