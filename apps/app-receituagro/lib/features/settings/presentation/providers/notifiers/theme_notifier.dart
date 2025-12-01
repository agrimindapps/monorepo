import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/user_settings_entity.dart';
import '../../../domain/usecases/get_user_settings_usecase.dart';
import '../../../domain/usecases/update_user_settings_usecase.dart';
import '../settings_providers.dart';

part 'theme_notifier.g.dart';

/// Specialized notifier for theme and visual settings
///
/// ✅ SINGLE RESPONSIBILITY PRINCIPLE (SRP):
/// - Manages ONLY theme-related user settings (dark mode, language)
/// - Does NOT handle notifications, analytics, premium features
/// - Each responsibility is delegated to specialized notifiers:
///   • NotificationsNotifier: notification settings
///   • AnalyticsDebugNotifier: analytics & debug operations
///
/// ✅ DEPENDENCY INVERSION PRINCIPLE (DIP):
/// - Depends on use case abstractions (GetUserSettingsUseCase, UpdateUserSettingsUseCase)
/// - Not on concrete repositories or services
/// - Allows easy testing and implementation swapping
///
/// ✅ RIVERPOD PATTERNS:
/// - Uses AsyncValue<T> for state management
/// - Handles loading/error/data states automatically
/// - ref.onDispose() for cleanup if needed
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late final GetUserSettingsUseCase _getUserSettingsUseCase;
  late final UpdateUserSettingsUseCase _updateUserSettingsUseCase;

  @override
  Future<UserSettingsEntity?> build() async {
    // Lazy-load use cases via DI container only when notifier is used
    // This follows DIP: depend on abstractions, not concrete implementations
    _getUserSettingsUseCase = ref.watch(getUserSettingsUseCaseProvider);
    _updateUserSettingsUseCase = ref.watch(updateUserSettingsUseCaseProvider);
    return null;
  }

  /// Load user theme settings
  Future<void> loadSettings(String userId) async {
    if (userId.isEmpty) return;

    state = const AsyncValue.loading();

    try {
      final settings = await _getUserSettingsUseCase(userId);
      state = AsyncValue.data(settings);
    } catch (e) {
      debugPrint('Error loading theme settings: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Toggle dark theme
  Future<bool> setDarkTheme(bool isDark) async {
    final currentSettings = state.value;
    if (currentSettings == null) return false;

    try {
      final updatedSettings = currentSettings.copyWith(isDarkTheme: isDark);
      await _updateUserSettingsUseCase(updatedSettings);
      state = AsyncValue.data(updatedSettings);
      return true;
    } catch (e) {
      debugPrint('Error updating dark theme: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Update language setting
  Future<bool> setLanguage(String language) async {
    final currentSettings = state.value;
    if (currentSettings == null) return false;

    try {
      final updatedSettings = currentSettings.copyWith(language: language);
      await _updateUserSettingsUseCase(updatedSettings);
      state = AsyncValue.data(updatedSettings);
      return true;
    } catch (e) {
      debugPrint('Error updating language: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}
