import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../models/reminder_model.dart';
import '../services/reminder_error_handling_service.dart';

/// Reminder Repository Implementation
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles data operations for reminder feature
/// - **Dependency Inversion**: Depends on error handling service abstraction
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;
  final ReminderErrorHandlingService _errorHandlingService;

  ReminderRepositoryImpl({
    required this.localDataSource,
    required ReminderErrorHandlingService errorHandlingService,
  }) : _errorHandlingService = errorHandlingService;

  @override
  Future<Either<Failure, List<Reminder>>> getReminders(String userId) async {
    return _errorHandlingService.executeOperation(
      operation: () => localDataSource.getReminders(userId),
      operationName: 'buscar lembretes',
    );
  }

  @override
  Future<Either<Failure, List<Reminder>>> getRemindersByAnimal(
      String animalId) async {
    return _errorHandlingService.executeOperation(
      operation: () => localDataSource.getRemindersByAnimal(animalId),
      operationName: 'buscar lembretes do animal',
    );
  }

  @override
  Future<Either<Failure, List<Reminder>>> getTodayReminders(
      String userId) async {
    return _errorHandlingService.executeOperation(
      operation: () => localDataSource.getTodayReminders(userId),
      operationName: 'buscar lembretes de hoje',
    );
  }

  @override
  Future<Either<Failure, List<Reminder>>> getOverdueReminders(
      String userId) async {
    return _errorHandlingService.executeOperation(
      operation: () => localDataSource.getOverdueReminders(userId),
      operationName: 'buscar lembretes atrasados',
    );
  }

  @override
  Future<Either<Failure, List<Reminder>>> getUpcomingReminders(
      String userId, int days) async {
    return _errorHandlingService.executeOperation(
      operation: () => localDataSource.getUpcomingReminders(userId, days),
      operationName: 'buscar próximos lembretes',
    );
  }

  @override
  Future<Either<Failure, void>> addReminder(Reminder reminder) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        final reminderModel = ReminderModel.fromEntity(reminder);
        await localDataSource.addReminder(reminderModel);
      },
      operationName: 'adicionar lembrete',
    );
  }

  @override
  Future<Either<Failure, void>> updateReminder(Reminder reminder) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        final reminderModel = ReminderModel.fromEntity(reminder);
        await localDataSource.updateReminder(reminderModel);
      },
      operationName: 'atualizar lembrete',
    );
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () => localDataSource.deleteReminder(reminderId),
      operationName: 'deletar lembrete',
    );
  }

  @override
  Future<Either<Failure, void>> completeReminder(String reminderId) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        final reminders = await localDataSource.getReminders('');
        final reminder = reminders.firstWhere((r) => r.id == reminderId);

        final completedReminder = reminder.copyWith(
          status: ReminderStatus.completed,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await localDataSource.updateReminder(completedReminder);
      },
      operationName: 'completar lembrete',
    );
  }

  @override
  Future<Either<Failure, void>> snoozeReminder(
      String reminderId, DateTime snoozeUntil) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        final reminders = await localDataSource.getReminders('');
        final reminder = reminders.firstWhere((r) => r.id == reminderId);

        final snoozedReminder = reminder.copyWith(
          status: ReminderStatus.snoozed,
          snoozeUntil: snoozeUntil,
          updatedAt: DateTime.now(),
        );

        await localDataSource.updateReminder(snoozedReminder);
      },
      operationName: 'adiar lembrete',
    );
  }

  @override
  Stream<Either<Failure, List<Reminder>>> watchReminders(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getReminders(userId);
    }).asyncMap((future) => future);
  }

  @override
  Stream<Either<Failure, List<Reminder>>> watchTodayReminders(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getTodayReminders(userId);
    }).asyncMap((future) => future);
  }
}
