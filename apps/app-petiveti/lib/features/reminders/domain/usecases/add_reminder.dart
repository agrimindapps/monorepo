import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class AddReminder implements UseCase<void, Reminder> {
  final ReminderRepository repository;

  AddReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(Reminder reminder) async {
    if (reminder.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Título do lembrete é obrigatório'));
    }

    if (reminder.scheduledDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return const Left(ValidationFailure(message: 'Data do lembrete não pode ser no passado'));
    }

    if (reminder.isRecurring && (reminder.recurringDays == null || reminder.recurringDays! <= 0)) {
      return const Left(ValidationFailure(message: 'Intervalo de recorrência deve ser maior que zero'));
    }

    return await repository.addReminder(reminder);
  }
}
