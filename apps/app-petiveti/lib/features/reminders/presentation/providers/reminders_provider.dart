import 'package:core/core.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/add_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/get_reminders.dart';
import '../../domain/usecases/update_reminder.dart';

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

class RemindersNotifier extends StateNotifier<RemindersState> {
  final GetReminders _getReminders;
  final GetTodayReminders _getTodayReminders;
  final GetOverdueReminders _getOverdueReminders;
  final AddReminder _addReminder;
  final UpdateReminder _updateReminder;
  final CompleteReminder _completeReminder;
  final SnoozeReminder _snoozeReminder;
  final DeleteReminder _deleteReminder;

  RemindersNotifier(
    this._getReminders,
    this._getTodayReminders,
    this._getOverdueReminders,
    this._addReminder,
    this._updateReminder,
    this._completeReminder,
    this._snoozeReminder,
    this._deleteReminder,
  ) : super(const RemindersState());

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

final remindersProvider = StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier(
    di.getIt<GetReminders>(),
    di.getIt<GetTodayReminders>(),
    di.getIt<GetOverdueReminders>(),
    di.getIt<AddReminder>(),
    di.getIt<UpdateReminder>(),
    di.getIt<CompleteReminder>(),
    di.getIt<SnoozeReminder>(),
    di.getIt<DeleteReminder>(),
  );
});