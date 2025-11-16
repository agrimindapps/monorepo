import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/notification_settings_entity.dart';

part 'notification_notifier.g.dart';

/// State class for notification settings
class NotificationState {
  final NotificationSettingsEntity settings;
  final bool isLoading;
  final String? error;

  const NotificationState({
    required this.settings,
    required this.isLoading,
    this.error,
  });

  factory NotificationState.initial() {
    return NotificationState(
      settings: NotificationSettingsEntity.defaults(),
      isLoading: false,
      error: null,
    );
  }

  NotificationState copyWith({
    NotificationSettingsEntity? settings,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  NotificationState clearError() {
    return copyWith(error: null);
  }
}

/// Notifier for managing notification-related user settings
/// Handles push notifications, sounds, and promotional settings
///
/// Responsibilities:
/// - Toggle notifications on/off
/// - Toggle sound on/off
/// - Toggle promotional notifications on/off
/// - Load/save notification settings
/// - Validate notification configuration
/// - Persist to storage
///
/// State: NotificationState
/// - settings: Current NotificationSettingsEntity
/// - isLoading: Whether operations are in progress
/// - error: Error message if any
@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  NotificationState build() => NotificationState.initial();

  /// Toggles all notifications on/off
  ///
  /// Impact:
  /// - When disabled: no notifications sent, sound setting becomes irrelevant
  /// - When enabled: respects sound and promotional settings
  Future<void> toggleNotifications() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(
        notificationsEnabled: !state.settings.notificationsEnabled,
      );

      // TODO: Persist to storage and notify backend
      // await _persistNotificationSettings(updated);
      // await _notifyBackendOfPreferenceChange(updated);

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error toggling notifications: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao alternar notificações',
      );
    }
  }

  /// Toggles notification sound on/off
  ///
  /// Only applies if notificationsEnabled is true
  Future<void> toggleSound() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(
        soundEnabled: !state.settings.soundEnabled,
      );

      // TODO: Persist to storage
      // await _persistNotificationSettings(updated);

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error toggling sound: $e\n$stack');
      state = state.copyWith(isLoading: false, error: 'Erro ao alternar som');
    }
  }

  /// Toggles promotional notifications on/off
  ///
  /// Only applies if notificationsEnabled is true
  Future<void> togglePromotional() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(
        promotionalNotificationsEnabled:
            !state.settings.promotionalNotificationsEnabled,
      );

      // TODO: Persist to storage and notify backend
      // await _persistNotificationSettings(updated);
      // await _updatePromotionalConsent(updated.promotionalNotificationsEnabled);

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error toggling promotional: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao alternar promoções',
      );
    }
  }

  /// Resets notification settings to defaults
  ///
  /// Useful for clearing user preferences and restoring system defaults
  Future<void> resetToDefaults() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final defaults = NotificationSettingsEntity.defaults();

      // TODO: Persist to storage
      // await _persistNotificationSettings(defaults);

      state = state.copyWith(settings: defaults, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error resetting to defaults: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao redefinir padrões',
      );
    }
  }

  /// Loads notification settings from storage
  /// Useful for app initialization
  Future<void> loadNotificationSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Load from storage
      // final result = await _notificationRepository.getNotificationSettings();
      // result.fold(
      //   (failure) => state = state.copyWith(
      //     isLoading: false,
      //     error: failure.message,
      //   ),
      //   (settings) => state = NotificationState(
      //     settings: settings,
      //     isLoading: false,
      //     error: null,
      //   ),
      // );

      // For now, use defaults
      state = state.copyWith(isLoading: false);
    } catch (e, stack) {
      debugPrint('Error loading notification settings: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar configurações de notificações',
      );
    }
  }

  // Getters for easy access

  /// Get current notification settings
  NotificationSettingsEntity get currentSettings => state.settings;

  /// Check if notifications are enabled
  bool get notificationsEnabled => state.settings.notificationsEnabled;

  /// Check if sound is enabled
  bool get soundEnabled => state.settings.soundEnabled;

  /// Check if promotional notifications are enabled
  bool get promotionalEnabled => state.settings.promotionalNotificationsEnabled;

  /// Check if sound will actually play
  bool get willPlaySound => state.settings.willPlaySound;

  /// Check if promotional notifications will be received
  bool get willReceivePromotional => state.settings.willReceivePromotional;

  /// Get notification level
  NotificationLevel get notificationLevel => state.settings.notificationLevel;

  /// Get user preference summary for display
  String get preferenceSummary => state.settings.preferenceSummary;

  /// Check if currently loading
  bool get isLoading => state.isLoading;

  /// Check if there's an error
  bool get hasError => state.error != null;

  /// Get error message if any
  String? get errorMessage => state.error;
}
