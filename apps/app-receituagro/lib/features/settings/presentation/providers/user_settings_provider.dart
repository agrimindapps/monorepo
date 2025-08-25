import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/user_settings_entity.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';

/// Provider for managing user settings state using Clean Architecture.
/// Handles all settings-related operations and state management.
class UserSettingsProvider extends ChangeNotifier {
  final GetUserSettingsUseCase _getUserSettingsUseCase;
  final UpdateUserSettingsUseCase _updateUserSettingsUseCase;

  UserSettingsProvider({
    required GetUserSettingsUseCase getUserSettingsUseCase,
    required UpdateUserSettingsUseCase updateUserSettingsUseCase,
  })  : _getUserSettingsUseCase = getUserSettingsUseCase,
        _updateUserSettingsUseCase = updateUserSettingsUseCase;

  // State
  UserSettingsEntity? _settings;
  bool _isLoading = false;
  String? _error;
  String _currentUserId = '';

  // Getters
  UserSettingsEntity? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSettings => _settings != null;
  
  // Settings getters for easier access
  bool get isDarkTheme => _settings?.isDarkTheme ?? false;
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get soundEnabled => _settings?.soundEnabled ?? true;
  String get language => _settings?.language ?? 'pt-BR';
  bool get isDevelopmentMode => _settings?.isDevelopmentMode ?? false;
  bool get speechToTextEnabled => _settings?.speechToTextEnabled ?? false;
  bool get analyticsEnabled => _settings?.analyticsEnabled ?? true;
  
  // Computed properties
  String get accessibilityLevel => _settings?.accessibilityLevel ?? 'basic';
  bool get hasPremiumFeatures => _settings?.hasPremiumFeatures ?? false;
  bool get needsMigration => _settings?.needsMigration ?? false;

  /// Initialize provider and load settings for user
  Future<void> initialize(String userId) async {
    if (userId.isEmpty) {
      _setError('Invalid user ID');
      return;
    }

    _currentUserId = userId;
    await loadSettings();
  }

  /// Load user settings
  Future<void> loadSettings() async {
    if (_currentUserId.isEmpty) {
      _setError('User not initialized');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);
      
      _settings = await _getUserSettingsUseCase(_currentUserId);
      
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update complete settings
  Future<bool> updateSettings(UserSettingsEntity newSettings) async {
    try {
      _setError(null);
      
      _settings = await _updateUserSettingsUseCase(newSettings);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating settings: $e');
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
    if (_currentUserId.isEmpty) {
      _setError('User not initialized');
      return false;
    }

    try {
      _setError(null);
      
      _settings = await _updateUserSettingsUseCase.batchUpdate(
        _currentUserId, 
        updates
      );
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error batch updating settings: $e');
      return false;
    }
  }

  /// Reset settings to default
  Future<bool> resetToDefault() async {
    if (_currentUserId.isEmpty) {
      _setError('User not initialized');
      return false;
    }

    try {
      _setError(null);
      
      final defaultSettings = UserSettingsEntity.createDefault(_currentUserId);
      _settings = await _updateUserSettingsUseCase(defaultSettings);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error resetting settings: $e');
      return false;
    }
  }

  /// Get settings optimized for specific context
  Future<UserSettingsEntity?> getSettingsForContext(SettingsContext context) async {
    if (_currentUserId.isEmpty) return null;
    
    try {
      return await _getUserSettingsUseCase.getForContext(_currentUserId, context);
    } catch (e) {
      debugPrint('Error getting settings for context: $e');
      return _settings;
    }
  }

  /// Export settings for backup
  Future<Map<String, dynamic>?> exportSettings() async {
    if (_settings == null) return null;
    
    try {
      // In a real implementation, this would use repository export method
      return {
        'userId': _settings!.userId,
        'isDarkTheme': _settings!.isDarkTheme,
        'notificationsEnabled': _settings!.notificationsEnabled,
        'soundEnabled': _settings!.soundEnabled,
        'language': _settings!.language,
        'isDevelopmentMode': _settings!.isDevelopmentMode,
        'speechToTextEnabled': _settings!.speechToTextEnabled,
        'analyticsEnabled': _settings!.analyticsEnabled,
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error exporting settings: $e');
      return null;
    }
  }

  /// Import settings from backup
  Future<bool> importSettings(Map<String, dynamic> data) async {
    if (_currentUserId.isEmpty) {
      _setError('User not initialized');
      return false;
    }

    try {
      _setError(null);
      
      // Basic validation
      if (!data.containsKey('isDarkTheme') || !data.containsKey('language')) {
        _setError('Invalid import data format');
        return false;
      }

      // Create settings entity from import data
      final importedSettings = UserSettingsEntity(
        userId: _currentUserId, // Use current user, not imported user
        isDarkTheme: data['isDarkTheme'] as bool? ?? false,
        notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
        soundEnabled: data['soundEnabled'] as bool? ?? true,
        language: data['language'] as String? ?? 'pt-BR',
        isDevelopmentMode: data['isDevelopmentMode'] as bool? ?? false,
        speechToTextEnabled: data['speechToTextEnabled'] as bool? ?? false,
        analyticsEnabled: data['analyticsEnabled'] as bool? ?? true,
        lastUpdated: DateTime.now(),
        createdAt: _settings?.createdAt ?? DateTime.now(),
      );

      _settings = await _updateUserSettingsUseCase(importedSettings);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error importing settings: $e');
      return false;
    }
  }

  /// Refresh settings from repository
  Future<void> refresh() async {
    await loadSettings();
  }

  /// Clear error
  void clearError() {
    _setError(null);
  }

  /// Update a single setting
  Future<bool> _updateSingleSetting(String key, dynamic value) async {
    if (_currentUserId.isEmpty) {
      _setError('User not initialized');
      return false;
    }

    try {
      _setError(null);
      
      _settings = await _updateUserSettingsUseCase.updateSingle(
        _currentUserId,
        key,
        value,
      );
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating single setting: $e');
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Get supported languages
  List<String> get supportedLanguages => ['pt-BR', 'en-US', 'es-ES'];

  /// Get language display name
  String getLanguageDisplayName(String languageCode) {
    return switch (languageCode) {
      'pt-BR' => 'Português (Brasil)',
      'en-US' => 'English (US)',
      'es-ES' => 'Español (España)',
      _ => languageCode,
    };
  }

  /// Check if a feature is available
  bool isFeatureAvailable(String feature) {
    return switch (feature) {
      'speechToText' => speechToTextEnabled,
      'darkTheme' => true,
      'notifications' => true,
      'analytics' => true,
      'sound' => true,
      'developmentMode' => true,
      _ => false,
    };
  }

  @override
  void dispose() {
    _settings = null;
    super.dispose();
  }
}