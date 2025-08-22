import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Reminder>>> getReminders(String userId) async {
    try {
      final reminders = await localDataSource.getReminders(userId);
      return Right(reminders);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar lembretes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getRemindersByAnimal(String animalId) async {
    try {
      final reminders = await localDataSource.getRemindersByAnimal(animalId);
      return Right(reminders);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar lembretes do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getTodayReminders(String userId) async {
    try {
      final reminders = await localDataSource.getTodayReminders(userId);
      return Right(reminders);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar lembretes de hoje: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getOverdueReminders(String userId) async {
    try {
      final reminders = await localDataSource.getOverdueReminders(userId);
      return Right(reminders);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar lembretes atrasados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getUpcomingReminders(String userId, int days) async {
    try {
      final reminders = await localDataSource.getUpcomingReminders(userId, days);
      return Right(reminders);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar próximos lembretes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addReminder(Reminder reminder) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      await localDataSource.addReminder(reminderModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReminder(Reminder reminder) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      await localDataSource.updateReminder(reminderModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    try {
      await localDataSource.deleteReminder(reminderId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> completeReminder(String reminderId) async {
    try {
      final reminders = await localDataSource.getReminders('');
      final reminder = reminders.firstWhere((r) => r.id == reminderId);
      
      final completedReminder = reminder.copyWith(
        status: ReminderStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.updateReminder(completedReminder);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao completar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> snoozeReminder(String reminderId, DateTime snoozeUntil) async {
    try {
      final reminders = await localDataSource.getReminders('');
      final reminder = reminders.firstWhere((r) => r.id == reminderId);
      
      final snoozedReminder = reminder.copyWith(
        status: ReminderStatus.snoozed,
        snoozeUntil: snoozeUntil,
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.updateReminder(snoozedReminder);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao adiar lembrete: ${e.toString()}'));
    }
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