import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class GetReminders implements UseCase<List<Reminder>, String> {
  final ReminderRepository repository;

  GetReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String userId) async {
    return await repository.getReminders(userId);
  }
}

class GetRemindersByAnimal implements UseCase<List<Reminder>, String> {
  final ReminderRepository repository;

  GetRemindersByAnimal(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String animalId) async {
    return await repository.getRemindersByAnimal(animalId);
  }
}

class GetTodayReminders implements UseCase<List<Reminder>, String> {
  final ReminderRepository repository;

  GetTodayReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String userId) async {
    return await repository.getTodayReminders(userId);
  }
}

class GetOverdueReminders implements UseCase<List<Reminder>, String> {
  final ReminderRepository repository;

  GetOverdueReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String userId) async {
    return await repository.getOverdueReminders(userId);
  }
}

class GetUpcomingRemindersParams {
  final String userId;
  final int days;

  GetUpcomingRemindersParams({
    required this.userId,
    required this.days,
  });
}

class GetUpcomingReminders implements UseCase<List<Reminder>, GetUpcomingRemindersParams> {
  final ReminderRepository repository;

  GetUpcomingReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(GetUpcomingRemindersParams params) async {
    return await repository.getUpcomingReminders(params.userId, params.days);
  }
}
