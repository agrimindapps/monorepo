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
    // Business validation
    _validateSettings(settings);
    
    // Apply business rules for updates
    final validatedSettings = await _applyUpdateRules(settings);
    
    // Save to repository
    await _repository.saveUserSettings(validatedSettings);
    
    // Handle side effects
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

    // Get current settings
    final currentSettings = await _repository.getUserSettings(userId);
    if (currentSettings == null) {
      throw SettingsNotFoundException('Settings not found for user $userId');
    }

    // Validate the specific update
    _validateSingleUpdate(key, value);

    // Create updated settings
    final updatedSettings = _applySingleUpdate(currentSettings, key, value);

    // Use the main update flow
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

    // Get current settings
    final currentSettings = await _repository.getUserSettings(userId);
    if (currentSettings == null) {
      throw SettingsNotFoundException('Settings not found for user $userId');
    }

    // Apply all updates
    var updatedSettings = currentSettings;
    for (final entry in updates.entries) {
      _validateSingleUpdate(entry.key, entry.value);
      updatedSettings = _applySingleUpdate(updatedSettings, entry.key, entry.value);
    }

    // Use the main update flow
    return await call(updatedSettings);
  }

  /// Validate settings before saving
  void _validateSettings(UserSettingsEntity settings) {
    if (!settings.isValid) {
      throw InvalidSettingsException('Settings validation failed');
    }

    // Business rule: Language must be supported
    const supportedLanguages = ['pt-BR', 'en-US', 'es-ES'];
    if (!supportedLanguages.contains(settings.language)) {
      throw UnsupportedLanguageException('Language ${settings.language} is not supported');
    }

    // Business rule: User ID must be consistent
    if (settings.userId.isEmpty) {
      throw InvalidUserIdException('User ID cannot be empty in settings');
    }
  }

  /// Apply business rules for settings updates
  Future<UserSettingsEntity> _applyUpdateRules(UserSettingsEntity settings) async {
    var updatedSettings = settings.copyWith(lastUpdated: DateTime.now());

    // Business rule: Development mode restrictions
    if (settings.isDevelopmentMode) {
      updatedSettings = updatedSettings.copyWith(analyticsEnabled: false);
    }

    // Business rule: Premium features validation
    if (settings.speechToTextEnabled) {
      // In a real app, check subscription status
      final hasValidSubscription = await _checkSubscriptionStatus(settings.userId);
      if (!hasValidSubscription) {
        updatedSettings = updatedSettings.copyWith(speechToTextEnabled: false);
      }
    }

    // Business rule: Accessibility consistency
    if (!settings.soundEnabled && !settings.notificationsEnabled) {
      // Warn or adjust for accessibility
      // For now, we'll allow this configuration
    }

    return updatedSettings;
  }

  /// Handle side effects of settings changes
  Future<void> _handleSideEffects(UserSettingsEntity settings) async {
    // Side effect: Update theme in app
    if (settings.isDarkTheme) {
      // Trigger theme change event
      await _notifyThemeChange(settings.isDarkTheme);
    }

    // Side effect: Update analytics preferences
    if (!settings.analyticsEnabled) {
      await _disableAnalytics(settings.userId);
    }

    // Side effect: Update notification preferences
    if (!settings.notificationsEnabled) {
      await _disableNotifications(settings.userId);
    }

    // Side effect: Update speech recognition
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
    return switch (key) {
      'isDarkTheme' => currentSettings.copyWith(isDarkTheme: value as bool),
      'notificationsEnabled' => currentSettings.copyWith(notificationsEnabled: value as bool),
      'soundEnabled' => currentSettings.copyWith(soundEnabled: value as bool),
      'language' => currentSettings.copyWith(language: value as String),
      'isDevelopmentMode' => currentSettings.copyWith(isDevelopmentMode: value as bool),
      'speechToTextEnabled' => currentSettings.copyWith(speechToTextEnabled: value as bool),
      'analyticsEnabled' => currentSettings.copyWith(analyticsEnabled: value as bool),
      _ => throw InvalidUpdateException('Cannot update setting: $key'),
    };
  }

  /// Check subscription status (mock implementation)
  Future<bool> _checkSubscriptionStatus(String userId) async {
    // In real implementation, check with subscription service
    return true; // For now, assume all users have premium
  }

  /// Notify theme change (mock implementation)
  Future<void> _notifyThemeChange(bool isDark) async {
    // In real implementation, notify theme service
  }

  /// Disable analytics (mock implementation)
  Future<void> _disableAnalytics(String userId) async {
    // In real implementation, disable analytics tracking
  }

  /// Disable notifications (mock implementation)
  Future<void> _disableNotifications(String userId) async {
    // In real implementation, unregister notification tokens
  }

  /// Initialize speech recognition (mock implementation)
  Future<void> _initializeSpeechRecognition(String language) async {
    // In real implementation, configure speech service
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