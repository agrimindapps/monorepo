import 'package:app_receituagro/core/services/promotional_notification_manager.dart';
import 'package:app_receituagro/core/services/receituagro_notification_service.dart';
import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';
import 'package:app_receituagro/features/settings/domain/usecases/get_user_settings_usecase.dart';
import 'package:app_receituagro/features/settings/domain/usecases/update_user_settings_usecase.dart';
import 'package:app_receituagro/features/settings/presentation/providers/notifiers/notifications_notifier.dart';
import 'package:app_receituagro/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ===== MOCK CLASSES =====

class MockGetUserSettingsUseCase extends Mock implements GetUserSettingsUseCase {}

class MockUpdateUserSettingsUseCase extends Mock implements UpdateUserSettingsUseCase {}

class MockReceitaAgroNotificationService extends Mock implements ReceitaAgroNotificationService {}

class MockPromotionalNotificationManager extends Mock implements PromotionalNotificationManager {}

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

    registerFallbackValue(UserSettingsEntity.createDefault('user-123'));
    registerFallbackValue(const NotificationPreferences(promotionalEnabled: true, seasonalAlertsEnabled: true, premiumOffersEnabled: true, newFeaturesEnabled: true, interestedCategories: []));
    
    // Mock cleanup
    when(() => mockNotificationService.cancelAllNotifications())
        .thenAnswer((_) async => true);
  });

  group('NotificationsNotifier - Loading Settings', () {
    test('should load notification settings successfully', () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => settings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider.overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider.overrideWithValue(mockUpdateUserSettingsUseCase),
        receitaAgroNotificationServiceProvider.overrideWithValue(mockNotificationService),
        promotionalNotificationManagerProvider.overrideWithValue(mockPromotionalManager),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);

      // Act
      await notifier.loadSettings(userId);

      // Assert
      final state = container.read(notificationsProvider);
      expect(state.value, settings);
      expect(state.value?.notificationsEnabled, true);
    });

    test('should initialize with null settings', () async {
      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider.overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider.overrideWithValue(mockUpdateUserSettingsUseCase),
        receitaAgroNotificationServiceProvider.overrideWithValue(mockNotificationService),
        promotionalNotificationManagerProvider.overrideWithValue(mockPromotionalManager),
      ]);
      addTearDown(container.dispose);

      final state = container.read(notificationsProvider);
      expect(state.value, isNull);
    });
  });

  group('NotificationsNotifier - Notifications Enabled Toggle', () {
    test('should disable notifications', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId); // Default is true
      final expectedSettings = initialSettings.copyWith(notificationsEnabled: false);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);
      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);
      when(() => mockPromotionalManager.getUserNotificationPreferences())
          .thenAnswer((_) async => const NotificationPreferences(promotionalEnabled: true, seasonalAlertsEnabled: true, premiumOffersEnabled: true, newFeaturesEnabled: true, interestedCategories: []));
      when(() => mockPromotionalManager.saveUserNotificationPreferences(any()))
          .thenAnswer((_) async => true);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider.overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider.overrideWithValue(mockUpdateUserSettingsUseCase),
        receitaAgroNotificationServiceProvider.overrideWithValue(mockNotificationService),
        promotionalNotificationManagerProvider.overrideWithValue(mockPromotionalManager),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setNotificationsEnabled(false);

      // Assert
      verify(() => mockUpdateUserSettingsUseCase(any())).called(1);
      final state = container.read(notificationsProvider);
      expect(state.value?.notificationsEnabled, false);
    });
  });

  group('NotificationsNotifier - Sound Settings', () {
    test('should disable sound', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId); // Default is true
      final expectedSettings = initialSettings.copyWith(soundEnabled: false);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);
      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider.overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider.overrideWithValue(mockUpdateUserSettingsUseCase),
        receitaAgroNotificationServiceProvider.overrideWithValue(mockNotificationService),
        promotionalNotificationManagerProvider.overrideWithValue(mockPromotionalManager),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setSoundEnabled(false);

      // Assert
      verify(() => mockUpdateUserSettingsUseCase(any())).called(1);
      final state = container.read(notificationsProvider);
      expect(state.value?.soundEnabled, false);
    });
  });
}
