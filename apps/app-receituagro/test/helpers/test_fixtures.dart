import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';

class TestFixtures {
  static UserSettingsEntity createTestSettings({
    String userId = 'test-user-123',
    bool isDarkTheme = false,
    bool notificationsEnabled = true,
    String language = 'pt-BR',
  }) {
    return UserSettingsEntity(
      userId: userId,
      isDarkTheme: isDarkTheme,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: true,
      language: language,
      isDevelopmentMode: false,
      speechToTextEnabled: false,
      analyticsEnabled: true,
      lastUpdated: DateTime(2024, 1, 1, 12, 0),
      createdAt: DateTime(2024, 1, 1, 10, 0),
    );
  }

  static UserSettingsEntity createInvalidSettings() {
    return UserSettingsEntity(
      userId: '',
      isDarkTheme: false,
      notificationsEnabled: true,
      soundEnabled: true,
      language: '',
      isDevelopmentMode: false,
      speechToTextEnabled: false,
      analyticsEnabled: true,
      lastUpdated: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
    );
  }
}
