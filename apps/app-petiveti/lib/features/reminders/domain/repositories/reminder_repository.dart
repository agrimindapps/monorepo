import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<Either<Failure, List<Reminder>>> getReminders(String userId);
  Future<Either<Failure, List<Reminder>>> getRemindersByAnimal(String animalId);
  Future<Either<Failure, List<Reminder>>> getTodayReminders(String userId);
  Future<Either<Failure, List<Reminder>>> getOverdueReminders(String userId);
  Future<Either<Failure, List<Reminder>>> getUpcomingReminders(String userId, int days);
  Future<Either<Failure, void>> addReminder(Reminder reminder);
  Future<Either<Failure, void>> updateReminder(Reminder reminder);
  Future<Either<Failure, void>> deleteReminder(String reminderId);
  Future<Either<Failure, void>> completeReminder(String reminderId);
  Future<Either<Failure, void>> snoozeReminder(String reminderId, DateTime snoozeUntil);
  Stream<Either<Failure, List<Reminder>>> watchReminders(String userId);
  Stream<Either<Failure, List<Reminder>>> watchTodayReminders(String userId);
}