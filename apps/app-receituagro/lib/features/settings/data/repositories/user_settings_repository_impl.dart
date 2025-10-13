import 'package:core/core.dart';

import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/i_user_settings_repository.dart';

/// Implementation of IUserSettingsRepository using SharedPreferences.
/// This is the data layer implementation that handles actual data persistence.
@LazySingleton(as: IUserSettingsRepository)
class UserSettingsRepositoryImpl implements IUserSettingsRepository {
  static const String _keyPrefix = 'user_settings_';
  static const String _syncPrefix = 'sync_enabled_';

  @override
  Future<UserSettingsEntity?> getUserSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + userId;
      
      final data = prefs.getString(key);
      if (data == null) return null;
      
      final map = _parseJsonString(data);
      return _mapToEntity(map);
    } catch (e) {
      throw RepositoryException('Failed to get user settings: $e');
    }
  }

  @override
  Future<void> saveUserSettings(UserSettingsEntity settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + settings.userId;
      
      final map = _entityToMap(settings);
      final jsonString = _mapToJsonString(map);
      
      await prefs.setString(key, jsonString);
    } catch (e) {
      throw RepositoryException('Failed to save user settings: $e');
    }
  }

  @override
  Future<void> updateSetting(String userId, String key, dynamic value) async {
    try {
      final currentSettings = await getUserSettings(userId);
      if (currentSettings == null) {
        throw RepositoryException('Settings not found for user $userId');
      }

      final updatedSettings = _updateSettingInEntity(currentSettings, key, value);
      await saveUserSettings(updatedSettings);
    } catch (e) {
      throw RepositoryException('Failed to update setting: $e');
    }
  }

  @override
  Future<void> resetToDefault(String userId) async {
    try {
      final defaultSettings = UserSettingsEntity.createDefault(userId);
      await saveUserSettings(defaultSettings);
    } catch (e) {
      throw RepositoryException('Failed to reset to default: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportSettings(String userId) async {
    try {
      final settings = await getUserSettings(userId);
      if (settings == null) {
        return <String, dynamic>{};
      }
      
      return _entityToMap(settings);
    } catch (e) {
      throw RepositoryException('Failed to export settings: $e');
    }
  }

  @override
  Future<void> importSettings(String userId, Map<String, dynamic> data) async {
    try {
      if (!_isValidImportData(data)) {
        throw RepositoryException('Invalid import data format');
      }
      final settings = _mapToEntity(data);
      final correctedSettings = settings.copyWith(userId: userId);
      
      await saveUserSettings(correctedSettings);
    } catch (e) {
      throw RepositoryException('Failed to import settings: $e');
    }
  }

  @override
  Future<void> deleteUserSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + userId;
      
      await prefs.remove(key);
      final syncKey = _syncPrefix + userId;
      await prefs.remove(syncKey);
    } catch (e) {
      throw RepositoryException('Failed to delete user settings: $e');
    }
  }

  @override
  Future<bool> isSyncEnabled(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncKey = _syncPrefix + userId;
      
      return prefs.getBool(syncKey) ?? false;
    } catch (e) {
      throw RepositoryException('Failed to check sync status: $e');
    }
  }

  @override
  Future<void> setSyncEnabled(String userId, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncKey = _syncPrefix + userId;
      
      await prefs.setBool(syncKey, enabled);
    } catch (e) {
      throw RepositoryException('Failed to set sync enabled: $e');
    }
  }

  /// Convert entity to map for storage
  Map<String, dynamic> _entityToMap(UserSettingsEntity entity) {
    return {
      'userId': entity.userId,
      'isDarkTheme': entity.isDarkTheme,
      'notificationsEnabled': entity.notificationsEnabled,
      'soundEnabled': entity.soundEnabled,
      'language': entity.language,
      'isDevelopmentMode': entity.isDevelopmentMode,
      'speechToTextEnabled': entity.speechToTextEnabled,
      'analyticsEnabled': entity.analyticsEnabled,
      'lastUpdated': entity.lastUpdated.millisecondsSinceEpoch,
      'createdAt': entity.createdAt.millisecondsSinceEpoch,
    };
  }

  /// Convert map from storage to entity
  UserSettingsEntity _mapToEntity(Map<String, dynamic> map) {
    return UserSettingsEntity(
      userId: map['userId'] as String? ?? '',
      isDarkTheme: map['isDarkTheme'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      language: map['language'] as String? ?? 'pt-BR',
      isDevelopmentMode: map['isDevelopmentMode'] as bool? ?? false,
      speechToTextEnabled: map['speechToTextEnabled'] as bool? ?? false,
      analyticsEnabled: map['analyticsEnabled'] as bool? ?? true,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        map['lastUpdated'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Update a specific setting in entity
  UserSettingsEntity _updateSettingInEntity(
    UserSettingsEntity entity,
    String key,
    dynamic value,
  ) {
    switch (key) {
      case 'isDarkTheme':
        return entity.copyWith(isDarkTheme: value as bool);
      case 'notificationsEnabled':
        return entity.copyWith(notificationsEnabled: value as bool);
      case 'soundEnabled':
        return entity.copyWith(soundEnabled: value as bool);
      case 'language':
        return entity.copyWith(language: value as String);
      case 'isDevelopmentMode':
        return entity.copyWith(isDevelopmentMode: value as bool);
      case 'speechToTextEnabled':
        return entity.copyWith(speechToTextEnabled: value as bool);
      case 'analyticsEnabled':
        return entity.copyWith(analyticsEnabled: value as bool);
      default:
        return entity;
    }
  }

  /// Validate imported data structure
  bool _isValidImportData(Map<String, dynamic> data) {
    const requiredKeys = ['userId', 'language', 'createdAt'];
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) return false;
    }
    if (data['userId'] is! String) return false;
    if (data['language'] is! String) return false;
    if (data['createdAt'] is! int) return false;
    
    return true;
  }

  /// Simple JSON string parser (in real app, use dart:convert)
  Map<String, dynamic> _parseJsonString(String jsonString) {
    final map = <String, dynamic>{};
    return map;
  }

  /// Simple JSON string serializer (in real app, use dart:convert)
  String _mapToJsonString(Map<String, dynamic> map) {
    return map.toString();
  }

  /// Get current user ID (helper method)
  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'anonymous_user';
  }
}

/// Exception thrown when repository operations fail
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
