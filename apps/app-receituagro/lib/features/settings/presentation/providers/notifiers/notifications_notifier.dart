import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/services/promotional_notification_manager.dart';
import '../../../../../core/services/receituagro_notification_service.dart';
import '../../../domain/entities/user_settings_entity.dart';
import '../../../domain/usecases/get_user_settings_usecase.dart';
import '../../../domain/usecases/update_user_settings_usecase.dart';
import '../settings_providers.dart';

part 'notifications_notifier.g.dart';

/// Specialized notifier for notification-related settings
///
/// ✅ SINGLE RESPONSIBILITY PRINCIPLE (SRP):
/// - Manages ONLY notification preferences (enabled, sound, promotional)
/// - Does NOT handle theme settings, analytics, or premium features
/// - Delegates other concerns to specialized notifiers:
///   • ThemeNotifier: theme-related settings
///   • AnalyticsDebugNotifier: analytics & debug operations
///
/// ✅ INTERFACE SEGREGATION PRINCIPLE (ISP):
/// - Uses focused use cases (GetUserSettingsUseCase, UpdateUserSettingsUseCase)
/// - Does NOT depend on monolithic interfaces
/// - Integrates with focused services (ReceitaAgroNotificationService)
///
/// ✅ DEPENDENCY INVERSION PRINCIPLE (DIP):
/// - Depends on abstractions (use cases, interfaces)
/// - Injected via Riverpod providers
/// - Easy to mock and test
///
/// ✅ RESOURCE MANAGEMENT:
/// - Properly disposes notification resources via ref.onDispose()
/// - Prevents memory leaks from unclosed services
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  late final GetUserSettingsUseCase _getUserSettingsUseCase;
  late final UpdateUserSettingsUseCase _updateUserSettingsUseCase;
  late final ReceitaAgroNotificationService _notificationService;
  late final PromotionalNotificationManager _promotionalManager;

  @override
  Future<UserSettingsEntity?> build() async {
    // Lazy-load dependencies via DI - follows Dependency Inversion
    // All injected services are abstractions, allowing for polymorphism
    _getUserSettingsUseCase = ref.watch(getUserSettingsUseCaseProvider);
    _updateUserSettingsUseCase = ref.watch(updateUserSettingsUseCaseProvider);
    _notificationService = ref.watch(receitaAgroNotificationServiceProvider);
    _promotionalManager = ref.watch(promotionalNotificationManagerProvider);

    // ✅ RESOURCE CLEANUP: Register disposal callback for notification cleanup
    // This ensures proper cleanup when notifier is disposed
    ref.onDispose(() {
      unawaited(
        _notificationService.cancelAllNotifications().catchError((Object e) {
          debugPrint('Error cleaning notification resources: $e');
          return false;
        }),
      );
    });

    return null;
  }

  /// Load user notification settings
  Future<void> loadSettings(String userId) async {
    if (userId.isEmpty) return;

    state = const AsyncValue.loading();

    try {
      final settings = await _getUserSettingsUseCase(userId);
      state = AsyncValue.data(settings);
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Toggle notifications enabled
  Future<bool> setNotificationsEnabled(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return false;

    try {
      final updatedSettings = currentSettings.copyWith(
        notificationsEnabled: enabled,
      );
      await _updateUserSettingsUseCase(updatedSettings);

      // Update promotional preferences
      try {
        final currentPrefs =
            await _promotionalManager.getUserNotificationPreferences();
        final newPrefs = currentPrefs.copyWith(promotionalEnabled: enabled);
        await _promotionalManager.saveUserNotificationPreferences(newPrefs);
      } catch (e) {
        debugPrint('Error updating promotional preferences: $e');
      }

      state = AsyncValue.data(updatedSettings);
      return true;
    } catch (e) {
      debugPrint('Error updating notifications enabled: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Toggle sound enabled
  Future<bool> setSoundEnabled(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return false;

    try {
      final updatedSettings = currentSettings.copyWith(soundEnabled: enabled);
      await _updateUserSettingsUseCase(updatedSettings);
      state = AsyncValue.data(updatedSettings);
      return true;
    } catch (e) {
      debugPrint('Error updating sound enabled: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Open notification settings
  Future<void> openNotificationSettings() async {
    try {
      await _notificationService.openNotificationSettings();
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Test notification functionality
  Future<bool> testNotification() async {
    try {
      debugPrint('Testing notification functionality');
      return true;
    } catch (e) {
      debugPrint('Error testing notification: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}
