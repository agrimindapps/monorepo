import 'package:app_receituagro/features/settings/data/repositories/user_settings_repository_impl.dart';
import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  late UserSettingsRepositoryImpl repository;

  setUp(() {
    repository = UserSettingsRepositoryImpl();
  });

  // ===== GROUP 1: SAVE AND RETRIEVE OPERATIONS =====

  group('UserSettingsRepositoryImpl - Save and Retrieve', () {
    test('should save and retrieve settings with JSON serialization', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId);

      // Act - Save
      await repository.saveUserSettings(settings);

      // Act - Retrieve
      final retrieved = await repository.getUserSettings(userId);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.userId, userId);
      expect(retrieved.isDarkTheme, settings.isDarkTheme);
      expect(retrieved.notificationsEnabled, settings.notificationsEnabled);
      expect(retrieved.language, settings.language);
    });

    test('should return null when settings do not exist', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'non-existent-user';

      // Act
      final result = await repository.getUserSettings(userId);

      // Assert
      expect(result, isNull);
    });

    test('should save multiple settings for different users', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final user1Settings = TestFixtures.createTestSettings(userId: 'user-1');
      final user2Settings = TestFixtures.createTestSettings(
        userId: 'user-2',
        isDarkTheme: true,
      );

      // Act
      await repository.saveUserSettings(user1Settings);
      await repository.saveUserSettings(user2Settings);

      // Retrieve
      final retrieved1 = await repository.getUserSettings('user-1');
      final retrieved2 = await repository.getUserSettings('user-2');

      // Assert
      expect(retrieved1!.userId, 'user-1');
      expect(retrieved1.isDarkTheme, false);
      expect(retrieved2!.userId, 'user-2');
      expect(retrieved2.isDarkTheme, true);
    });

    test('should overwrite existing settings on save', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final initialSettings = TestFixtures.createTestSettings(userId: userId);
      final updatedSettings = initialSettings.copyWith(isDarkTheme: true);

      // Act
      await repository.saveUserSettings(initialSettings);
      await repository.saveUserSettings(updatedSettings);

      // Retrieve
      final result = await repository.getUserSettings(userId);

      // Assert
      expect(result!.isDarkTheme, true);
    });
  });

  // ===== GROUP 2: UPDATE SPECIFIC SETTING =====

  group('UserSettingsRepositoryImpl - Update Setting', () {
    test('should update specific boolean setting', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId);
      await repository.saveUserSettings(settings);

      // Act
      await repository.updateSetting(userId, 'isDarkTheme', true);

      // Retrieve
      final result = await repository.getUserSettings(userId);

      // Assert
      expect(result!.isDarkTheme, true);
      expect(result.language, settings.language); // Other settings unchanged
    });

    test('should update language setting', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId);
      await repository.saveUserSettings(settings);

      // Act
      await repository.updateSetting(userId, 'language', 'en-US');

      // Retrieve
      final result = await repository.getUserSettings(userId);

      // Assert
      expect(result!.language, 'en-US');
    });

    test('should throw RepositoryException when settings not found for update',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'non-existent-user';

      // Act & Assert
      expect(
        () => repository.updateSetting(userId, 'isDarkTheme', true),
        throwsA(isA<RepositoryException>()),
      );
    });
  });

  // ===== GROUP 3: RESET TO DEFAULT =====

  group('UserSettingsRepositoryImpl - Reset to Default', () {
    test('should reset settings to default', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final customSettings = TestFixtures.createTestSettings(
        userId: userId,
        isDarkTheme: true,
        language: 'en-US',
      );
      await repository.saveUserSettings(customSettings);

      // Act
      await repository.resetToDefault(userId);

      // Retrieve
      final result = await repository.getUserSettings(userId);

      // Assert
      expect(result!.isDarkTheme, false); // Default
      expect(result.language, 'pt-BR'); // Default
      expect(result.notificationsEnabled, true); // Default
    });
  });

  // ===== GROUP 4: EXPORT AND IMPORT =====

  group('UserSettingsRepositoryImpl - Export and Import', () {
    test('should export settings as map', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId);
      await repository.saveUserSettings(settings);

      // Act
      final exported = await repository.exportSettings(userId);

      // Assert
      expect(exported, isNotEmpty);
      expect(exported['userId'], userId);
      expect(exported['isDarkTheme'], settings.isDarkTheme);
      expect(exported['language'], settings.language);
    });

    test('should return empty map when exporting non-existent settings',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'non-existent-user';

      // Act
      final exported = await repository.exportSettings(userId);

      // Assert
      expect(exported, isEmpty);
    });

    test('should import settings from map', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final importData = {
        'userId': 'original-user',
        'isDarkTheme': true,
        'notificationsEnabled': false,
        'soundEnabled': true,
        'language': 'en-US',
        'isDevelopmentMode': false,
        'speechToTextEnabled': false,
        'analyticsEnabled': true,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Act
      await repository.importSettings(userId, importData);

      // Retrieve
      final result = await repository.getUserSettings(userId);

      // Assert
      expect(result!.userId, userId); // Should use provided userId, not from data
      expect(result.isDarkTheme, true);
      expect(result.language, 'en-US');
    });

    test('should throw RepositoryException for invalid import data', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final invalidData = <String, dynamic>{
        'invalid': 'data'
      };

      // Act & Assert
      expect(
        () => repository.importSettings(userId, invalidData),
        throwsA(isA<RepositoryException>()),
      );
    });
  });

  // ===== GROUP 5: DELETE OPERATIONS =====

  group('UserSettingsRepositoryImpl - Delete', () {
    test('should delete user settings', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId);
      await repository.saveUserSettings(settings);

      // Act
      await repository.deleteUserSettings(userId);

      // Retrieve
      final result = await repository.getUserSettings(userId);

      // Assert
      expect(result, isNull);
    });

    test('should delete sync settings along with user settings', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId);
      await repository.saveUserSettings(settings);
      await repository.setSyncEnabled(userId, true);

      // Act
      await repository.deleteUserSettings(userId);

      // Retrieve
      final syncEnabled = await repository.isSyncEnabled(userId);

      // Assert
      expect(syncEnabled, false);
    });
  });

  // ===== GROUP 6: SYNC SETTINGS =====

  group('UserSettingsRepositoryImpl - Sync Settings', () {
    test('should set and get sync enabled status', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';

      // Act
      await repository.setSyncEnabled(userId, true);

      // Retrieve
      final result = await repository.isSyncEnabled(userId);

      // Assert
      expect(result, true);
    });

    test('should return false when sync setting does not exist', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'non-existent-user';

      // Act
      final result = await repository.isSyncEnabled(userId);

      // Assert
      expect(result, false);
    });

    test('should update sync enabled status', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      await repository.setSyncEnabled(userId, true);

      // Act
      await repository.setSyncEnabled(userId, false);

      // Retrieve
      final result = await repository.isSyncEnabled(userId);

      // Assert
      expect(result, false);
    });
  });

  // ===== GROUP 7: JSON SERIALIZATION =====

  group('UserSettingsRepositoryImpl - JSON Serialization', () {
    test('should properly serialize and deserialize DateTime fields', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final now = DateTime.now();
      final settings = TestFixtures.createTestSettings(userId: userId)
          .copyWith(lastUpdated: now, createdAt: now);

      // Act
      await repository.saveUserSettings(settings);
      final retrieved = await repository.getUserSettings(userId);

      // Assert
      expect(retrieved, isNotNull);
      // DateTime comparison with millisecond precision
      expect(
        retrieved!.lastUpdated.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      expect(
        retrieved.createdAt.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
    });

    test('should handle all boolean flags in serialization', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId).copyWith(
        isDarkTheme: true,
        notificationsEnabled: false,
        soundEnabled: false,
        isDevelopmentMode: true,
        speechToTextEnabled: true,
        analyticsEnabled: false,
      );

      // Act
      await repository.saveUserSettings(settings);
      final retrieved = await repository.getUserSettings(userId);

      // Assert
      expect(retrieved!.isDarkTheme, true);
      expect(retrieved.notificationsEnabled, false);
      expect(retrieved.soundEnabled, false);
      expect(retrieved.isDevelopmentMode, true);
      expect(retrieved.speechToTextEnabled, true);
      expect(retrieved.analyticsEnabled, false);
    });

    test('should handle special characters in language code', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      const userId = 'user-123';
      final settings = TestFixtures.createTestSettings(userId: userId)
          .copyWith(language: 'pt-BR');

      // Act
      await repository.saveUserSettings(settings);
      final retrieved = await repository.getUserSettings(userId);

      // Assert
      expect(retrieved!.language, 'pt-BR');
    });
  });

  // ===== GROUP 8: ERROR HANDLING =====

  group('UserSettingsRepositoryImpl - Error Handling', () {
    test('should throw RepositoryException on JSON parse error', () async {
      // Arrange
      const userId = 'user-123';
      SharedPreferences.setMockInitialValues({
        'user_settings_$userId': 'invalid-json-{{{',
      });

      // Act & Assert
      expect(
        () => repository.getUserSettings(userId),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('should handle corrupted settings data gracefully', () async {
      // Arrange
      const userId = 'user-123';
      SharedPreferences.setMockInitialValues({
        'user_settings_$userId': '{"userId": "user-123"}', // Missing required fields
      });

      // Act
      final result = await repository.getUserSettings(userId);

      // Assert - Should use defaults for missing fields
      expect(result, isNotNull);
      expect(result!.userId, userId);
      expect(result.language, 'pt-BR'); // Default
    });
  });
}
