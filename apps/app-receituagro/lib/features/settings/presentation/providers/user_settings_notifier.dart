import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_settings_entity.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import 'settings_providers.dart';

part 'user_settings_notifier.g.dart';

/// User settings state
class UserSettingsState {
  final UserSettingsEntity? settings;
  final bool isLoading;
  final String? error;
  final String currentUserId;

  const UserSettingsState({
    this.settings,
    required this.isLoading,
    this.error,
    required this.currentUserId,
  });

  factory UserSettingsState.initial() {
    return const UserSettingsState(
      settings: null,
      isLoading: false,
      error: null,
      currentUserId: '',
    );
  }

  UserSettingsState copyWith({
    UserSettingsEntity? settings,
    bool? isLoading,
    String? error,
    String? currentUserId,
  }) {
    return UserSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  UserSettingsState clearError() {
    return copyWith(error: null);
  }

  bool get hasSettings => settings != null;
  bool get isDarkTheme => settings?.isDarkTheme ?? false;
  bool get notificationsEnabled => settings?.notificationsEnabled ?? true;
  bool get soundEnabled => settings?.soundEnabled ?? true;
  String get language => settings?.language ?? 'pt-BR';
  bool get isDevelopmentMode => settings?.isDevelopmentMode ?? false;
  bool get speechToTextEnabled => settings?.speechToTextEnabled ?? false;
  bool get analyticsEnabled => settings?.analyticsEnabled ?? true;
  String get accessibilityLevel => settings?.accessibilityLevel ?? 'basic';
  bool get hasPremiumFeatures => settings?.hasPremiumFeatures ?? false;
  bool get needsMigration => settings?.needsMigration ?? false;
}

/// Notifier for managing user settings state using Clean Architecture
@riverpod
class UserSettingsNotifier extends _$UserSettingsNotifier {
  late final GetUserSettingsUseCase _getUserSettingsUseCase;
  late final UpdateUserSettingsUseCase _updateUserSettingsUseCase;

  @override
  Future<UserSettingsState> build() async {
    _getUserSettingsUseCase = ref.watch(getUserSettingsUseCaseProvider);
    _updateUserSettingsUseCase = ref.watch(updateUserSettingsUseCaseProvider);

    return UserSettingsState.initial();
  }

  /// Initialize provider and load settings for user
  Future<void> initialize(String userId) async {
    final currentState = state.value;
    if (currentState == null) return;

    if (userId.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(error: 'Invalid user ID'));
      return;
    }

    state = AsyncValue.data(currentState.copyWith(currentUserId: userId));
    await loadSettings();
  }

  /// Load user settings
  Future<void> loadSettings() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.currentUserId.isEmpty) {
      state =
          AsyncValue.data(currentState.copyWith(error: 'User not initialized'));
      return;
    }

    try {
      state =
          AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

      final settings =
          await _getUserSettingsUseCase(currentState.currentUserId);

      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, settings: settings),
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Update complete settings
  Future<bool> updateSettings(UserSettingsEntity newSettings) async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      state = AsyncValue.data(currentState.clearError());

      final updatedSettings = await _updateUserSettingsUseCase(newSettings);

      state = AsyncValue.data(currentState.copyWith(settings: updatedSettings));

      return true;
    } catch (e) {
      debugPrint('Error updating settings: $e');
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Update theme setting
  Future<bool> setDarkTheme(bool isDark) async {
    return await _updateSingleSetting('isDarkTheme', isDark);
  }

  /// Update notifications setting
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _updateSingleSetting('notificationsEnabled', enabled);
  }

  /// Update sound setting
  Future<bool> setSoundEnabled(bool enabled) async {
    return await _updateSingleSetting('soundEnabled', enabled);
  }

  /// Update language setting
  Future<bool> setLanguage(String language) async {
    return await _updateSingleSetting('language', language);
  }

  /// Update development mode setting
  Future<bool> setDevelopmentMode(bool enabled) async {
    return await _updateSingleSetting('isDevelopmentMode', enabled);
  }

  /// Update speech to text setting
  Future<bool> setSpeechToTextEnabled(bool enabled) async {
    return await _updateSingleSetting('speechToTextEnabled', enabled);
  }

  /// Update analytics setting
  Future<bool> setAnalyticsEnabled(bool enabled) async {
    return await _updateSingleSetting('analyticsEnabled', enabled);
  }

  /// Batch update multiple settings
  Future<bool> batchUpdateSettings(Map<String, dynamic> updates) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (currentState.currentUserId.isEmpty) {
      state =
          AsyncValue.data(currentState.copyWith(error: 'User not initialized'));
      return false;
    }

    try {
      state = AsyncValue.data(currentState.clearError());

      final updatedSettings = await _updateUserSettingsUseCase.batchUpdate(
        currentState.currentUserId,
        updates,
      );

      state = AsyncValue.data(currentState.copyWith(settings: updatedSettings));

      return true;
    } catch (e) {
      debugPrint('Error batch updating settings: $e');
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Reset settings to default
  Future<bool> resetToDefault() async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (currentState.currentUserId.isEmpty) {
      state =
          AsyncValue.data(currentState.copyWith(error: 'User not initialized'));
      return false;
    }

    try {
      state = AsyncValue.data(currentState.clearError());

      final defaultSettings =
          UserSettingsEntity.createDefault(currentState.currentUserId);
      final updatedSettings = await _updateUserSettingsUseCase(defaultSettings);

      state = AsyncValue.data(currentState.copyWith(settings: updatedSettings));

      return true;
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Get settings optimized for specific context
  Future<UserSettingsEntity?> getSettingsForContext(
      SettingsContext context) async {
    final currentState = state.value;
    if (currentState == null || currentState.currentUserId.isEmpty) return null;

    try {
      return await _getUserSettingsUseCase.getForContext(
        currentState.currentUserId,
        context,
      );
    } catch (e) {
      debugPrint('Error getting settings for context: $e');
      return currentState.settings;
    }
  }

  /// Export settings for backup
  Future<Map<String, dynamic>?> exportSettings() async {
    final currentState = state.value;
    if (currentState?.settings == null) return null;

    try {
      final settings = currentState!.settings!;
      return {
        'userId': settings.userId,
        'isDarkTheme': settings.isDarkTheme,
        'notificationsEnabled': settings.notificationsEnabled,
        'soundEnabled': settings.soundEnabled,
        'language': settings.language,
        'isDevelopmentMode': settings.isDevelopmentMode,
        'speechToTextEnabled': settings.speechToTextEnabled,
        'analyticsEnabled': settings.analyticsEnabled,
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error exporting settings: $e');
      return null;
    }
  }

  /// Import settings from backup
  Future<bool> importSettings(Map<String, dynamic> data) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (currentState.currentUserId.isEmpty) {
      state =
          AsyncValue.data(currentState.copyWith(error: 'User not initialized'));
      return false;
    }

    try {
      state = AsyncValue.data(currentState.clearError());
      if (!data.containsKey('isDarkTheme') || !data.containsKey('language')) {
        state = AsyncValue.data(
          currentState.copyWith(error: 'Invalid import data format'),
        );
        return false;
      }
      final importedSettings = UserSettingsEntity(
        userId:
            currentState.currentUserId, // Use current user, not imported user
        isDarkTheme: data['isDarkTheme'] as bool? ?? false,
        notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
        soundEnabled: data['soundEnabled'] as bool? ?? true,
        language: data['language'] as String? ?? 'pt-BR',
        isDevelopmentMode: data['isDevelopmentMode'] as bool? ?? false,
        speechToTextEnabled: data['speechToTextEnabled'] as bool? ?? false,
        analyticsEnabled: data['analyticsEnabled'] as bool? ?? true,
        lastUpdated: DateTime.now(),
        createdAt: currentState.settings?.createdAt ?? DateTime.now(),
      );

      final updatedSettings =
          await _updateUserSettingsUseCase(importedSettings);

      state = AsyncValue.data(currentState.copyWith(settings: updatedSettings));

      return true;
    } catch (e) {
      debugPrint('Error importing settings: $e');
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Refresh settings from repository
  Future<void> refresh() async {
    await loadSettings();
  }

  /// Clear error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Update a single setting
  Future<bool> _updateSingleSetting(String key, dynamic value) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (currentState.currentUserId.isEmpty) {
      state =
          AsyncValue.data(currentState.copyWith(error: 'User not initialized'));
      return false;
    }

    try {
      state = AsyncValue.data(currentState.clearError());

      final updatedSettings = await _updateUserSettingsUseCase.updateSingle(
        currentState.currentUserId,
        key,
        value,
      );

      state = AsyncValue.data(currentState.copyWith(settings: updatedSettings));

      return true;
    } catch (e) {
      debugPrint('Error updating single setting: $e');
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Get supported languages
  List<String> get supportedLanguages => ['pt-BR', 'en-US', 'es-ES'];

  /// Get language display name
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'pt-BR':
        return 'Português (Brasil)';
      case 'en-US':
        return 'English (US)';
      case 'es-ES':
        return 'Español (España)';
      default:
        return languageCode;
    }
  }

  /// Check if a feature is available
  bool isFeatureAvailable(String feature) {
    final currentState = state.value;
    if (currentState == null) return false;

    switch (feature) {
      case 'speechToText':
        return currentState.speechToTextEnabled;
      case 'darkTheme':
        return true;
      case 'notifications':
        return true;
      case 'analytics':
        return true;
      case 'sound':
        return true;
      case 'developmentMode':
        return true;
      default:
        return false;
    }
  }
}
