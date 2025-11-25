import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/reminder_local_datasource.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/services/reminder_error_handling_service.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/services/reminder_validation_service.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/add_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/get_reminders.dart';
import '../../domain/usecases/update_reminder.dart';

part 'reminders_providers.g.dart';

@riverpod
ReminderLocalDataSource reminderLocalDataSource(Ref ref) {
  final database = ref.watch(petivetiDatabaseProvider);
  return ReminderLocalDataSourceImpl(database);
}

@riverpod
ReminderErrorHandlingService reminderErrorHandlingService(Ref ref) {
  return ReminderErrorHandlingService();
}

@riverpod
ReminderValidationService reminderValidationService(Ref ref) {
  return ReminderValidationService();
}

@riverpod
ReminderRepository reminderRepository(Ref ref) {
  final localDataSource = ref.watch(reminderLocalDataSourceProvider);
  final errorHandlingService = ref.watch(reminderErrorHandlingServiceProvider);
  return ReminderRepositoryImpl(
    localDataSource: localDataSource,
    errorHandlingService: errorHandlingService,
  );
}

@riverpod
GetReminders getReminders(Ref ref) {
  return GetReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
GetTodayReminders getTodayReminders(Ref ref) {
  return GetTodayReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
GetOverdueReminders getOverdueReminders(Ref ref) {
  return GetOverdueReminders(ref.watch(reminderRepositoryProvider));
}

@riverpod
AddReminder addReminder(Ref ref) {
  return AddReminder(
    ref.watch(reminderRepositoryProvider),
    ref.watch(reminderValidationServiceProvider),
  );
}

@riverpod
UpdateReminder updateReminder(Ref ref) {
  return UpdateReminder(
    ref.watch(reminderRepositoryProvider),
    ref.watch(reminderValidationServiceProvider),
  );
}

@riverpod
CompleteReminder completeReminder(Ref ref) {
  return CompleteReminder(ref.watch(reminderRepositoryProvider));
}

@riverpod
SnoozeReminder snoozeReminder(Ref ref) {
  return SnoozeReminder(
    ref.watch(reminderRepositoryProvider),
    ref.watch(reminderValidationServiceProvider),
  );
}

@riverpod
DeleteReminder deleteReminder(Ref ref) {
  return DeleteReminder(
    ref.watch(reminderRepositoryProvider),
    ref.watch(reminderValidationServiceProvider),
  );
}

// ============================================================================
// NOTIFIER & STATE
// ============================================================================

class RemindersState {
  final List<Reminder> reminders;
  final List<Reminder> todayReminders;
  final List<Reminder> overdueReminders;
  final bool isLoading;
  final String? error;

  const RemindersState({
    this.reminders = const [],
    this.todayReminders = const [],
    this.overdueReminders = const [],
    this.isLoading = false,
    this.error,
  });

  RemindersState copyWith({
    List<Reminder>? reminders,
    List<Reminder>? todayReminders,
    List<Reminder>? overdueReminders,
    bool? isLoading,
    String? error,
  }) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      todayReminders: todayReminders ?? this.todayReminders,
      overdueReminders: overdueReminders ?? this.overdueReminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class RemindersNotifier extends _$RemindersNotifier {
  late final GetReminders _getReminders;
  late final GetTodayReminders _getTodayReminders;
  late final GetOverdueReminders _getOverdueReminders;
  late final AddReminder _addReminder;
  late final UpdateReminder _updateReminder;
  late final CompleteReminder _completeReminder;
  late final SnoozeReminder _snoozeReminder;
  late final DeleteReminder _deleteReminder;

  @override
  RemindersState build() {
    _getReminders = ref.watch(getRemindersProvider);
    _getTodayReminders = ref.watch(getTodayRemindersProvider);
    _getOverdueReminders = ref.watch(getOverdueRemindersProvider);
    _addReminder = ref.watch(addReminderProvider);
    _updateReminder = ref.watch(updateReminderProvider);
    _completeReminder = ref.watch(completeReminderProvider);
    _snoozeReminder = ref.watch(snoozeReminderProvider);
    _deleteReminder = ref.watch(deleteReminderProvider);

    return const RemindersState();
  }

  Future<void> loadReminders(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getReminders(userId);
    final todayResult = await _getTodayReminders(userId);
    final overdueResult = await _getOverdueReminders(userId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (reminders) {
        todayResult.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            error: failure.message,
          ),
          (todayReminders) {
            overdueResult.fold(
              (failure) => state = state.copyWith(
                isLoading: false,
                error: failure.message,
              ),
              (overdueReminders) => state = state.copyWith(
                reminders: reminders,
                todayReminders: todayReminders,
                overdueReminders: overdueReminders,
                isLoading: false,
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> addReminder(Reminder reminder) async {
    final result = await _addReminder(reminder);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        loadReminders(reminder.userId);
        return true;
      },
    );
  }

  Future<bool> updateReminder(Reminder reminder) async {
    final result = await _updateReminder(reminder);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        loadReminders(reminder.userId);
        return true;
      },
    );
  }

  Future<bool> completeReminder(String reminderId, String userId) async {
    final result = await _completeReminder(reminderId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        loadReminders(userId);
        return true;
      },
    );
  }

  Future<bool> snoozeReminder(String reminderId, DateTime snoozeUntil, String userId) async {
    final params = SnoozeReminderParams(
      reminderId: reminderId,
      snoozeUntil: snoozeUntil,
    );

    final result = await _snoozeReminder(params);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        loadReminders(userId);
        return true;
      },
    );
  }

  Future<bool> deleteReminder(String reminderId, String userId) async {
    final result = await _deleteReminder(reminderId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        loadReminders(userId);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
