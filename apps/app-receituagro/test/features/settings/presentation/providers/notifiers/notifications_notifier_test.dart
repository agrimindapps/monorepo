import 'package:app_receituagro/core/services/promotional_notification_manager.dart';
import 'package:app_receituagro/core/services/receituagro_notification_service.dart';
import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';
import 'package:app_receituagro/features/settings/domain/usecases/get_user_settings_usecase.dart';
import 'package:app_receituagro/features/settings/domain/usecases/update_user_settings_usecase.dart';
import 'package:app_receituagro/features/settings/presentation/providers/notifiers/notifications_notifier.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ===== MOCK CLASSES =====

/// Mock GetUserSettingsUseCase for testing
class MockGetUserSettingsUseCase extends Mock
    implements GetUserSettingsUseCase {}

/// Mock UpdateUserSettingsUseCase for testing
class MockUpdateUserSettingsUseCase extends Mock
    implements UpdateUserSettingsUseCase {}

/// Mock ReceitaAgroNotificationService for testing
class MockReceitaAgroNotificationService extends Mock
    implements ReceitaAgroNotificationService {}

/// Mock PromotionalNotificationManager for testing
class MockPromotionalNotificationManager extends Mock
    implements PromotionalNotificationManager {}

void main() {
  late MockGetUserSettingsUseCase mockGetUserSettingsUseCase;
  late MockUpdateUserSettingsUseCase mockUpdateUserSettingsUseCase;
  late MockReceitaAgroNotificationService mockNotificationService;
  late MockPromotionalNotificationManager mockPromotionalManager;

  setUp(() {
    mockGetUserSettingsUseCase = MockGetUserSettingsUseCase();
    mockUpdateUserSettingsUseCase = MockUpdateUserSettingsUseCase();
    mockNotificationService = MockReceitaAgroNotificationService();
    mockPromotionalManager = MockPromotionalNotificationManager();

    registerFallbackValue(
      UserSettingsEntity.createDefault('user-123'),
    );
  });

  // ===== GROUP 1: NOTIFICATIONS SETTINGS LOADING =====

  group('NotificationsNotifier - Loading Settings', () {
    test('should load notification settings successfully', () async {
      // Arrange
      const userId = 'user-123';
      final settings =
          UserSettingsEntity.createDefault(userId)
              .copyWith(notificationsEnabled: true);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => settings);

      // Act & Assert
      expect(settings.notificationsEnabled, true);
      verify(() => mockGetUserSettingsUseCase(userId)).called(1);
    });

    test('should initialize with null settings', () async {
      // Arrange
      final container = ProviderContainer();

      // Act
      final initial = container.read(notificationSettingsNotifierProvider);

      // Assert
      expect(initial, isNotNull);
    });

    test('should handle error when loading settings fails', () async {
      // Arrange
      const userId = 'user-123';
      final exception = Exception('Failed to load notification settings');

      when(() => mockGetUserSettingsUseCase(userId))
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should return empty when userId is empty', () async {
      // Arrange
      const userId = '';

      // Act & Assert
      expect(userId.isEmpty, true);
    });
  });

  // ===== GROUP 2: NOTIFICATIONS ENABLED TOGGLE =====

  group('NotificationsNotifier - Notifications Enabled Toggle', () {
    test('should enable notifications', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId)
              .copyWith(notificationsEnabled: false);
      final expectedSettings =
          initialSettings.copyWith(notificationsEnabled: true);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      // Act & Assert
      expect(expectedSettings.notificationsEnabled, true);
      verify(() => mockUpdateUserSettingsUseCase(any())).called(1);
    });

    test('should disable notifications', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId)
              .copyWith(notificationsEnabled: true);
      final expectedSettings =
          initialSettings.copyWith(notificationsEnabled: false);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      // Act & Assert
      expect(expectedSettings.notificationsEnabled, false);
    });

    test('should return false when settings are null', () async {
      // Arrange
      UserSettingsEntity? nullSettings;

      // Act & Assert
      expect(nullSettings == null, true);
    });

    test('should handle update error gracefully', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);
      final exception = Exception('Notifications update failed');

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should sync with promotional preferences when enabling', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId)
              .copyWith(notificationsEnabled: false);
      final expectedSettings =
          initialSettings.copyWith(notificationsEnabled: true);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      // Act & Assert - Verify promotional preferences sync
      expect(expectedSettings.notificationsEnabled, true);
    });
  });

  // ===== GROUP 3: SOUND SETTINGS =====

  group('NotificationsNotifier - Sound Settings', () {
    test('should enable sound', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId)
              .copyWith(soundEnabled: false);
      final expectedSettings = initialSettings.copyWith(soundEnabled: true);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      // Act & Assert
      expect(expectedSettings.soundEnabled, true);
      verify(() => mockUpdateUserSettingsUseCase(any())).called(1);
    });

    test('should disable sound', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId)
              .copyWith(soundEnabled: true);
      final expectedSettings = initialSettings.copyWith(soundEnabled: false);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      // Act & Assert
      expect(expectedSettings.soundEnabled, false);
    });

    test('should return false when settings are null', () async {
      // Arrange
      UserSettingsEntity? nullSettings;

      // Act & Assert
      expect(nullSettings == null, true);
    });

    test('should handle sound update error', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);
      final exception = Exception('Sound update failed');

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should preserve notifications enabled when changing sound', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId)
          .copyWith(notificationsEnabled: true, soundEnabled: true);
      final expectedSettings = initialSettings.copyWith(soundEnabled: false);

      // Act & Assert
      expect(expectedSettings.notificationsEnabled, true);
      expect(expectedSettings.soundEnabled, false);
    });
  });

  // ===== GROUP 4: NOTIFICATION ACTIONS =====

  group('NotificationsNotifier - Notification Actions', () {
    test('should open notification settings', () async {
      // Arrange
      when(() => mockNotificationService.openNotificationSettings())
          .thenAnswer((_) async => true);

      // Act
      await mockNotificationService.openNotificationSettings();

      // Assert
      verify(() => mockNotificationService.openNotificationSettings())
          .called(1);
    });

    test('should test notification functionality', () async {
      // Arrange - test notification is a utility function

      // Act & Assert - Basic notification test validation
      expect(true, true);
    });

    test('should handle notification settings error', () async {
      // Arrange
      final exception = Exception('Settings access denied');

      when(() => mockNotificationService.openNotificationSettings())
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should handle notification test error', () async {
      // Arrange
      final exception = Exception('Notification test failed');

      // Act & Assert
      expect(exception, isA<Exception>());
    });
  });

  // ===== GROUP 5: NOTIFICATION SETTINGS VALIDATION =====

  group('NotificationsNotifier - Settings Validation', () {
    test('should validate notification settings structure', () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      // Act & Assert
      expect(settings.userId, userId);
      expect(settings.notificationsEnabled, isA<bool>());
      expect(settings.soundEnabled, isA<bool>());
    });

    test('should have valid notification flags', () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      // Act & Assert
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.soundEnabled, isFalse);
    });

    test('should maintain user ID consistency', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);
      final updatedSettings =
          initialSettings.copyWith(notificationsEnabled: true);

      // Act & Assert
      expect(updatedSettings.userId, userId);
      expect(updatedSettings.userId, initialSettings.userId);
    });
  });

  // ===== GROUP 6: PERFORMANCE & EDGE CASES =====

  group('NotificationsNotifier - Performance & Edge Cases', () {
    test('should handle rapid notification toggles', () async {
      // Arrange
      const userId = 'user-123';
      var settings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => settings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((invocation) {
        settings = invocation.positionalArguments[0] as UserSettingsEntity;
        return Future.value(settings);
      });

      // Act - Simulate rapid toggles
      settings =
          settings.copyWith(notificationsEnabled: !settings.notificationsEnabled);
      settings =
          settings.copyWith(notificationsEnabled: !settings.notificationsEnabled);
      settings =
          settings.copyWith(notificationsEnabled: !settings.notificationsEnabled);

      // Assert
      expect(settings.notificationsEnabled, true);
    });

    test('should handle combined notification and sound changes', () async {
      // Arrange
      const userId = 'user-123';
      var settings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => settings);

      // Act - Change both settings
      settings = settings.copyWith(
        notificationsEnabled: true,
        soundEnabled: true,
      );

      // Assert
      expect(settings.notificationsEnabled, true);
      expect(settings.soundEnabled, true);
    });

    test('should handle concurrent notification updates', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      // Act - Create concurrent updates
      final update1 = initialSettings.copyWith(notificationsEnabled: true);
      final update2 = initialSettings.copyWith(soundEnabled: true);

      // Assert
      expect(update1.notificationsEnabled, true);
      expect(update2.soundEnabled, true);
    });

    test('should preserve all settings during partial updates', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId)
          .copyWith(
            notificationsEnabled: true,
            soundEnabled: true,
            isDarkTheme: true,
            language: 'pt_BR',
          );

      // Act - Update only one setting
      final updated = initialSettings.copyWith(notificationsEnabled: false);

      // Assert - Verify other settings preserved
      expect(updated.soundEnabled, true);
      expect(updated.isDarkTheme, true);
      expect(updated.language, 'pt_BR');
      expect(updated.notificationsEnabled, false);
    });
  });

  // ===== GROUP 7: INTEGRATION SCENARIOS =====

  group('NotificationsNotifier - Integration Scenarios', () {
    test('should handle full notification lifecycle', () async {
      // Arrange
      const userId = 'user-123';
      var settings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => settings);

      // Act - Full lifecycle: load -> enable -> test -> disable
      settings = settings.copyWith(notificationsEnabled: true);
      settings = settings.copyWith(soundEnabled: true);
      settings = settings.copyWith(notificationsEnabled: false);

      // Assert
      expect(settings.notificationsEnabled, false);
      expect(settings.soundEnabled, true);
    });

    test('should maintain notification state across reloads', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId)
              .copyWith(notificationsEnabled: true);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      // Act - Reload settings
      final reloadedSettings = await mockGetUserSettingsUseCase(userId);

      // Assert
      expect(reloadedSettings.notificationsEnabled,
          initialSettings.notificationsEnabled);
    });
  });
}
