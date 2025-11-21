import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/reminder_local_datasource.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/services/reminder_error_handling_service.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/add_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/get_reminders.dart';
import '../../domain/usecases/update_reminder.dart';

part 'reminders_providers.g.dart';

@riverpod
ReminderLocalDataSource reminderLocalDataSource(ReminderLocalDataSourceRef ref) {
  final database = ref.watch(petivetiDatabaseProvider);
  return ReminderLocalDataSourceImpl(database);
}

@riverpod
ReminderErrorHandlingService reminderErrorHandlingService(ReminderErrorHandlingServiceRef ref) {
  return ReminderErrorHandlingService();
}

@riverpod
ReminderRepository reminderRepository(ReminderRepositoryRef ref) {
  final localDataSource = ref.watch(reminderLocalDataSourceProvider);
  final errorHandlingService = ref.watch(reminderErrorHandlingServiceProvider);
  return ReminderRepositoryImpl(
    localDataSource: localDataSource,
    errorHandlingService: errorHandlingService,
  );
}

@riverpod
GetReminders getReminders(GetRemindersRef ref) {
  return GetReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
GetTodayReminders getTodayReminders(GetTodayRemindersRef ref) {
  return GetTodayReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
GetOverdueReminders getOverdueReminders(GetOverdueRemindersRef ref) {
  return GetOverdueReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
AddReminder addReminder(AddReminderRef ref) {
  return AddReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
UpdateReminder updateReminder(UpdateReminderRef ref) {
  return UpdateReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
CompleteReminder completeReminder(CompleteReminderRef ref) {
  return CompleteReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
SnoozeReminder snoozeReminder(SnoozeReminderRef ref) {
  return SnoozeReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
DeleteReminder deleteReminder(DeleteReminderRef ref) {
  return DeleteReminder(ref.watch(reminderRepositoryProvider));
}
