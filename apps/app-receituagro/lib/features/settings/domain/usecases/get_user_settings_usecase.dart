import 'package:core/core.dart';

import '../entities/user_settings_entity.dart';
import '../exceptions/settings_exceptions.dart';
import '../repositories/i_user_settings_repository.dart';

/// Use case for retrieving user settings with business logic applied.
/// Handles default creation, validation, and migration logic.
@injectable
class GetUserSettingsUseCase {
  final IUserSettingsRepository _repository;
  String? _currentUserId; // Track current userId for fixing corrupted data

  GetUserSettingsUseCase(this._repository);

  /// Gets user settings, creating defaults if none exist
  Future<UserSettingsEntity> call(String userId) async {
    if (userId.isEmpty) {
      throw InvalidUserIdException('User ID cannot be empty');
    }

    _currentUserId = userId; // Store for use in fixing corrupted data
    var settings = await _repository.getUserSettings(userId);
    if (settings == null) {
      settings = UserSettingsEntity.createDefault(userId);
      await _repository.saveUserSettings(settings);
      return settings;
    }
    settings = await _applyBusinessRules(settings);

    return settings;
  }

  /// Apply business rules and migrations
  Future<UserSettingsEntity> _applyBusinessRules(
    UserSettingsEntity settings,
  ) async {
    var updatedSettings = settings;
    if (settings.needsMigration) {
      updatedSettings = await _migrateSettings(settings);
    }
    if (!settings.isValid) {
      updatedSettings = _fixInvalidSettings(settings);
    }
    updatedSettings = _applySecurityPolicies(updatedSettings);
    if (updatedSettings != settings) {
      await _repository.saveUserSettings(updatedSettings);
    }

    return updatedSettings;
  }

  /// Migrate settings from old versions
  Future<UserSettingsEntity> _migrateSettings(
    UserSettingsEntity settings,
  ) async {
    var migrated = settings;
    if (settings.language.isEmpty) {
      migrated = migrated.copyWith(language: 'pt-BR');
    }

    return migrated;
  }

  /// Fix invalid settings with safe defaults
  UserSettingsEntity _fixInvalidSettings(UserSettingsEntity settings) {
    var fixed = settings;

    if (settings.userId.isEmpty) {
      return UserSettingsEntity.createDefault(
        _currentUserId ?? 'anonymous-fallback',
      );
    }

    if (settings.language.isEmpty) {
      fixed = fixed.copyWith(language: 'pt-BR');
    }

    return fixed.copyWith(lastUpdated: DateTime.now());
  }

  /// Apply security and privacy policies
  UserSettingsEntity _applySecurityPolicies(UserSettingsEntity settings) {
    var secured = settings;
    if (settings.isDevelopmentMode && settings.analyticsEnabled) {
      secured = secured.copyWith(analyticsEnabled: false);
    }
    if (settings.speechToTextEnabled) {}

    return secured;
  }

  /// Get settings with specific business context
  Future<UserSettingsEntity> getForContext(
    String userId,
    SettingsContext context,
  ) async {
    final settings = await call(userId);

    switch (context) {
      case SettingsContext.accessibility:
        return _optimizeForAccessibility(settings);
      case SettingsContext.performance:
        return _optimizeForPerformance(settings);
      case SettingsContext.privacy:
        return _optimizeForPrivacy(settings);
      case SettingsContext.default_:
        return settings;
    }
  }

  /// Optimize settings for accessibility
  UserSettingsEntity _optimizeForAccessibility(UserSettingsEntity settings) {
    return settings.copyWith(soundEnabled: true);
  }

  /// Optimize settings for performance
  UserSettingsEntity _optimizeForPerformance(UserSettingsEntity settings) {
    return settings.copyWith(analyticsEnabled: false);
  }

  /// Optimize settings for privacy
  UserSettingsEntity _optimizeForPrivacy(UserSettingsEntity settings) {
    return settings.copyWith(
      analyticsEnabled: false,
      notificationsEnabled: false,
    );
  }
}

/// Settings context for different use cases
enum SettingsContext { accessibility, performance, privacy, default_ }

/// Exception thrown when settings are invalid
class InvalidSettingsException implements Exception {
  final String message;
  InvalidSettingsException(this.message);

  @override
  String toString() => 'InvalidSettingsException: $message';
}
