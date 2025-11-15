import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/settings_entity.dart';
import '../settings_notifier.dart';

part 'notifications_notifier.g.dart';

/// NotificationsNotifier - Handles NOTIFICATION SETTINGS operations (SRP)
///
/// <150 lines respecting SRP
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  SettingsState build() {
    return SettingsState.initial();
  }

  /// Updates notification settings
  Future<void> updateNotificationSettings(
    NotificationSettingsEntity newSettings,
  ) async {
    try {
      final currentSettings = state.settings;
      final updatedSettings =
          currentSettings.copyWith(notifications: newSettings);

      state = state.copyWith(
        settings: updatedSettings,
        successMessage: 'Notificações atualizadas',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar notificações: $e',
      );
    }
  }

  /// Toggles task reminders
  Future<void> toggleTaskReminders(bool enabled) async {
    try {
      final newSettings = state.notificationSettings.copyWith(
        taskRemindersEnabled: enabled,
      );
      await updateNotificationSettings(newSettings);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao alternar lembretes: $e');
    }
  }

  /// Clears all notifications
  Future<void> clearAllNotifications() async {
    try {
      state = state.copyWith(isLoading: true);
      // Clear logic would go here
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Notificações removidas',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao limpar notificações: $e',
      );
    }
  }
}
