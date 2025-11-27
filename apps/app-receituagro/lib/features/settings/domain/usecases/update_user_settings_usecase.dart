import '../entities/user_settings_entity.dart';
import '../exceptions/settings_exceptions.dart';
import '../repositories/i_user_settings_repository.dart';

/// Use case for updating user settings with business validation.
/// Handles business rules, validation, and side effects of settings changes.
class UpdateUserSettingsUseCase {
  final IUserSettingsRepository _repository;

  UpdateUserSettingsUseCase(this._repository);

  /// Updates complete user settings
  Future<UserSettingsEntity> call(UserSettingsEntity settings) async {
    _validateSettings(settings);
    final validatedSettings = await _applyUpdateRules(settings);
    await _repository.saveUserSettings(validatedSettings);
    await _handleSideEffects(validatedSettings);
    
    return validatedSettings;
  }

  /// Updates a single setting by key
  Future<UserSettingsEntity> updateSingle(
    String userId, 
    String key, 
    dynamic value
  ) async {
    if (userId.isEmpty) {
      throw InvalidUserIdException('User ID cannot be empty');
    }
    final currentSettings = await _repository.getUserSettings(userId);
    if (currentSettings == null) {
      throw SettingsNotFoundException('Settings not found for user $userId');
    }
    _validateSingleUpdate(key, value);
    final updatedSettings = _applySingleUpdate(currentSettings, key, value);
    return await call(updatedSettings);
  }

  /// Batch update multiple settings
  Future<UserSettingsEntity> batchUpdate(
    String userId,
    Map<String, dynamic> updates
  ) async {
    if (updates.isEmpty) {
      throw InvalidUpdateException('No updates provided');
    }
    final currentSettings = await _repository.getUserSettings(userId);
    if (currentSettings == null) {
      throw SettingsNotFoundException('Settings not found for user $userId');
    }
    var updatedSettings = currentSettings;
    for (final entry in updates.entries) {
      _validateSingleUpdate(entry.key, entry.value);
      updatedSettings = _applySingleUpdate(updatedSettings, entry.key, entry.value);
    }
    return await call(updatedSettings);
  }

  /// Validate settings before saving
  void _validateSettings(UserSettingsEntity settings) {
    if (!settings.isValid) {
      throw InvalidSettingsException('Settings validation failed');
    }
    const supportedLanguages = ['pt-BR', 'en-US', 'es-ES'];
    if (!supportedLanguages.contains(settings.language)) {
      throw UnsupportedLanguageException('Language ${settings.language} is not supported');
    }
    if (settings.userId.isEmpty) {
      throw InvalidUserIdException('User ID cannot be empty in settings');
    }
  }

  /// Apply business rules for settings updates
  Future<UserSettingsEntity> _applyUpdateRules(UserSettingsEntity settings) async {
    var updatedSettings = settings.copyWith(lastUpdated: DateTime.now());
    if (settings.isDevelopmentMode) {
      updatedSettings = updatedSettings.copyWith(analyticsEnabled: false);
    }
    if (settings.speechToTextEnabled) {
      final hasValidSubscription = await _checkSubscriptionStatus(settings.userId);
      if (!hasValidSubscription) {
        updatedSettings = updatedSettings.copyWith(speechToTextEnabled: false);
      }
    }
    if (!settings.soundEnabled && !settings.notificationsEnabled) {
    }

    return updatedSettings;
  }

  /// Handle side effects of settings changes
  Future<void> _handleSideEffects(UserSettingsEntity settings) async {
    if (settings.isDarkTheme) {
      await _notifyThemeChange(settings.isDarkTheme);
    }
    if (!settings.analyticsEnabled) {
      await _disableAnalytics(settings.userId);
    }
    if (!settings.notificationsEnabled) {
      await _disableNotifications(settings.userId);
    }
    if (settings.speechToTextEnabled) {
      await _initializeSpeechRecognition(settings.language);
    }
  }

  /// Validate a single setting update
  void _validateSingleUpdate(String key, dynamic value) {
    switch (key) {
      case 'isDarkTheme':
      case 'notificationsEnabled':
      case 'soundEnabled':
      case 'isDevelopmentMode':
      case 'speechToTextEnabled':
      case 'analyticsEnabled':
        if (value is! bool) {
          throw InvalidUpdateException('$key must be a boolean');
        }
        break;
      
      case 'language':
        if (value is! String || value.isEmpty) {
          throw InvalidUpdateException('Language must be a non-empty string');
        }
        const supportedLanguages = ['pt-BR', 'en-US', 'es-ES'];
        if (!supportedLanguages.contains(value)) {
          throw UnsupportedLanguageException('Language $value is not supported');
        }
        break;
      
      default:
        throw InvalidUpdateException('Unknown setting key: $key');
    }
  }

  /// Apply a single update to settings
  UserSettingsEntity _applySingleUpdate(
    UserSettingsEntity currentSettings,
    String key,
    dynamic value
  ) {
    switch (key) {
      case 'isDarkTheme':
        return currentSettings.copyWith(isDarkTheme: value as bool);
      case 'notificationsEnabled':
        return currentSettings.copyWith(notificationsEnabled: value as bool);
      case 'soundEnabled':
        return currentSettings.copyWith(soundEnabled: value as bool);
      case 'language':
        return currentSettings.copyWith(language: value as String);
      case 'isDevelopmentMode':
        return currentSettings.copyWith(isDevelopmentMode: value as bool);
      case 'speechToTextEnabled':
        return currentSettings.copyWith(speechToTextEnabled: value as bool);
      case 'analyticsEnabled':
        return currentSettings.copyWith(analyticsEnabled: value as bool);
      default:
        throw InvalidUpdateException('Cannot update setting: $key');
    }
  }

  /// Check subscription status (mock implementation)
  Future<bool> _checkSubscriptionStatus(String userId) async {
    return true; // For now, assume all users have premium
  }

  /// Notify theme change (mock implementation)
  Future<void> _notifyThemeChange(bool isDark) async {
  }

  /// Disable analytics (mock implementation)
  Future<void> _disableAnalytics(String userId) async {
  }

  /// Disable notifications (mock implementation)
  Future<void> _disableNotifications(String userId) async {
  }

  /// Initialize speech recognition (mock implementation)
  Future<void> _initializeSpeechRecognition(String language) async {
  }
}

/// Exception thrown when settings are not found
class SettingsNotFoundException implements Exception {
  final String message;
  SettingsNotFoundException(this.message);

  @override
  String toString() => 'SettingsNotFoundException: $message';
}

/// Exception thrown when update is invalid
class InvalidUpdateException implements Exception {
  final String message;
  InvalidUpdateException(this.message);

  @override
  String toString() => 'InvalidUpdateException: $message';
}

/// Exception thrown when language is not supported
class UnsupportedLanguageException implements Exception {
  final String message;
  UnsupportedLanguageException(this.message);

  @override
  String toString() => 'UnsupportedLanguageException: $message';
}
/// Exception thrown when settings are invalid
class InvalidSettingsException implements Exception {
  final String message;
  InvalidSettingsException(this.message);

  @override
  String toString() => 'InvalidSettingsException: $message';
}
