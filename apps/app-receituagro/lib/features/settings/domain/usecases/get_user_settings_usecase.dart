import '../entities/user_settings_entity.dart';
import '../exceptions/settings_exceptions.dart';
import '../repositories/i_user_settings_repository.dart';

/// Use case for retrieving user settings with business logic applied.
/// Handles default creation, validation, and migration logic.
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

    // Try to get existing settings
    var settings = await _repository.getUserSettings(userId);

    // Create default settings if none exist
    if (settings == null) {
      settings = UserSettingsEntity.createDefault(userId);
      await _repository.saveUserSettings(settings);
      return settings;
    }

    // Apply business rules
    settings = await _applyBusinessRules(settings);

    return settings;
  }

  /// Apply business rules and migrations
  Future<UserSettingsEntity> _applyBusinessRules(UserSettingsEntity settings) async {
    var updatedSettings = settings;

    // Business rule: Migrate old settings
    if (settings.needsMigration) {
      updatedSettings = await _migrateSettings(settings);
    }

    // Business rule: Validate settings consistency
    if (!settings.isValid) {
      updatedSettings = _fixInvalidSettings(settings);
    }

    // Business rule: Apply security policies
    updatedSettings = _applySecurityPolicies(updatedSettings);

    // Save if settings were modified
    if (updatedSettings != settings) {
      await _repository.saveUserSettings(updatedSettings);
    }

    return updatedSettings;
  }

  /// Migrate settings from old versions
  Future<UserSettingsEntity> _migrateSettings(UserSettingsEntity settings) async {
    var migrated = settings;

    // Migration logic for different app versions
    if (settings.language.isEmpty) {
      migrated = migrated.copyWith(language: 'pt-BR');
    }

    // Add other migration logic as needed

    return migrated;
  }

  /// Fix invalid settings with safe defaults
  UserSettingsEntity _fixInvalidSettings(UserSettingsEntity settings) {
    var fixed = settings;

    if (settings.userId.isEmpty) {
      // Handle corrupted data by creating new default settings
      // This commonly happens with old cached data
      return UserSettingsEntity.createDefault(_currentUserId ?? 'anonymous-fallback');
    }

    if (settings.language.isEmpty) {
      fixed = fixed.copyWith(language: 'pt-BR');
    }

    return fixed.copyWith(lastUpdated: DateTime.now());
  }

  /// Apply security and privacy policies
  UserSettingsEntity _applySecurityPolicies(UserSettingsEntity settings) {
    var secured = settings;

    // Business rule: In development mode, disable analytics by default
    if (settings.isDevelopmentMode && settings.analyticsEnabled) {
      secured = secured.copyWith(analyticsEnabled: false);
    }

    // Business rule: Premium features require valid subscription
    // This would be checked against subscription service
    if (settings.speechToTextEnabled) {
      // For now, we'll assume it's allowed, but in real implementation
      // we would check subscription status here
    }

    return secured;
  }

  /// Get settings with specific business context
  Future<UserSettingsEntity> getForContext(String userId, SettingsContext context) async {
    final settings = await call(userId);

    return switch (context) {
      SettingsContext.accessibility => _optimizeForAccessibility(settings),
      SettingsContext.performance => _optimizeForPerformance(settings),
      SettingsContext.privacy => _optimizeForPrivacy(settings),
      SettingsContext.default_ => settings,
    };
  }

  /// Optimize settings for accessibility
  UserSettingsEntity _optimizeForAccessibility(UserSettingsEntity settings) {
    return settings.copyWith(
      soundEnabled: true,
      // Other accessibility optimizations
    );
  }

  /// Optimize settings for performance
  UserSettingsEntity _optimizeForPerformance(UserSettingsEntity settings) {
    return settings.copyWith(
      analyticsEnabled: false,
      // Other performance optimizations
    );
  }

  /// Optimize settings for privacy
  UserSettingsEntity _optimizeForPrivacy(UserSettingsEntity settings) {
    return settings.copyWith(
      analyticsEnabled: false,
      notificationsEnabled: false,
      // Other privacy optimizations
    );
  }
}

/// Settings context for different use cases
enum SettingsContext {
  accessibility,
  performance,
  privacy,
  default_,
}


/// Exception thrown when settings are invalid
class InvalidSettingsException implements Exception {
  final String message;
  InvalidSettingsException(this.message);

  @override
  String toString() => 'InvalidSettingsException: $message';
}