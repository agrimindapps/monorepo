import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

/// Use case for retrieving all reminders for a user
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles reminder retrieval flow
/// - **Dependency Inversion**: Depends on repository abstraction
class GetReminders implements UseCase<List<Reminder>, String> {
  final ReminderRepository _repository;

  GetReminders(this._repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String userId) async {
    return await _repository.getReminders(userId);
  }
}

/// Use case for retrieving reminders for a specific animal
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles animal-specific reminder retrieval
/// - **Dependency Inversion**: Depends on repository abstraction
class GetRemindersByAnimal implements UseCase<List<Reminder>, String> {
  final ReminderRepository _repository;

  GetRemindersByAnimal(this._repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String animalId) async {
    return await _repository.getRemindersByAnimal(animalId);
  }
}

/// Use case for retrieving today's reminders
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles today's reminder retrieval
/// - **Dependency Inversion**: Depends on repository abstraction
class GetTodayReminders implements UseCase<List<Reminder>, String> {
  final ReminderRepository _repository;

  GetTodayReminders(this._repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String userId) async {
    return await _repository.getTodayReminders(userId);
  }
}

/// Use case for retrieving overdue reminders
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles overdue reminder retrieval
/// - **Dependency Inversion**: Depends on repository abstraction
class GetOverdueReminders implements UseCase<List<Reminder>, String> {
  final ReminderRepository _repository;

  GetOverdueReminders(this._repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String userId) async {
    return await _repository.getOverdueReminders(userId);
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

/// Use case for retrieving upcoming reminders within a specified number of days
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles upcoming reminder retrieval
/// - **Dependency Inversion**: Depends on repository abstraction
class GetUpcomingReminders
    implements UseCase<List<Reminder>, GetUpcomingRemindersParams> {
  final ReminderRepository _repository;

  GetUpcomingReminders(this._repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(
      GetUpcomingRemindersParams params) async {
    return await _repository.getUpcomingReminders(params.userId, params.days);
  }
}
