import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/reminder_repository.dart';

class DeleteReminder implements UseCase<void, String> {
  final ReminderRepository repository;

  DeleteReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(String reminderId) async {
    if (reminderId.trim().isEmpty) {
      return Left(ValidationFailure('ID do lembrete é obrigatório'));
    }

    return await repository.deleteReminder(reminderId);
  }
}