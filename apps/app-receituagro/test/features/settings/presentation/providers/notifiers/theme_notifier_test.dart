import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';
import 'package:app_receituagro/features/settings/domain/usecases/get_user_settings_usecase.dart';
import 'package:app_receituagro/features/settings/domain/usecases/update_user_settings_usecase.dart';
import 'package:app_receituagro/features/settings/presentation/providers/notifiers/theme_notifier.dart';
import 'package:app_receituagro/features/settings/presentation/providers/settings_providers.dart';
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

void main() {
  late MockGetUserSettingsUseCase mockGetUserSettingsUseCase;
  late MockUpdateUserSettingsUseCase mockUpdateUserSettingsUseCase;

  setUp(() {
    mockGetUserSettingsUseCase = MockGetUserSettingsUseCase();
    mockUpdateUserSettingsUseCase = MockUpdateUserSettingsUseCase();

    // Register fallback value for UserSettingsEntity
    registerFallbackValue(
      UserSettingsEntity.createDefault('user-123'),
    );
  });

  // ===== GROUP 1: THEME SETTINGS LOADING =====

  group('ThemeNotifier - Loading Settings', () {
    test('should load theme settings successfully', () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => settings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);

      // Act
      await notifier.loadSettings(userId);

      // Assert
      final state = container.read(themeProvider);
      expect(state.value, settings);
      expect(state.value?.isDarkTheme, false);
      expect(state.value?.language, isNotEmpty);
    });

    test('should initialize with null settings', () async {
      // Arrange
      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      // Act
      final state = container.read(themeProvider);

      // Assert
      expect(state.value, isNull);
    });

    test('should handle error when loading settings fails', () async {
      // Arrange
      const userId = 'user-123';
      final exception = Exception('Failed to load settings');

      when(() => mockGetUserSettingsUseCase(userId)).thenAnswer((_) async => throw exception);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);

      // Act
      await notifier.loadSettings(userId);

      // Assert
      final state = container.read(themeProvider);
      expect(state.hasError, true);
      expect(state.error, exception);
    });

    test('should not load settings when userId is empty', () async {
      // Arrange
      const userId = '';
      
      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);

      // Act
      await notifier.loadSettings(userId);

      // Assert
      verifyNever(() => mockGetUserSettingsUseCase(any()));
      final state = container.read(themeProvider);
      expect(state.value, isNull);
    });
  });

  // ===== GROUP 2: DARK THEME TOGGLE =====

  group('ThemeNotifier - Dark Theme Toggle', () {
    test('should toggle dark theme to true', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);
      final expectedSettings = initialSettings.copyWith(isDarkTheme: true);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setDarkTheme(true);

      // Assert
      verify(() => mockUpdateUserSettingsUseCase(any())).called(1);
      final state = container.read(themeProvider);
      expect(state.value?.isDarkTheme, true);
    });

    test('should toggle dark theme to false', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId).copyWith(isDarkTheme: true);
      final expectedSettings = initialSettings.copyWith(isDarkTheme: false);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setDarkTheme(false);

      // Assert
      verify(() => mockUpdateUserSettingsUseCase(any())).called(1);
      final state = container.read(themeProvider);
      expect(state.value?.isDarkTheme, false);
    });

    test('should handle null settings scenario for dark theme', () async {
      // Arrange
      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      // Not loading settings, so state is null

      // Act
      final result = await notifier.setDarkTheme(true);

      // Assert
      expect(result, false);
      verifyNever(() => mockUpdateUserSettingsUseCase(any()));
    });

    test('should handle update error gracefully', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);
      final exception = Exception('Update failed');

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any())).thenThrow(exception);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      final result = await notifier.setDarkTheme(true);

      // Assert
      expect(result, false);
      final state = container.read(themeProvider);
      expect(state.hasError, true);
      expect(state.error, exception);
    });

    test('should preserve other settings when toggling dark theme', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId)
          .copyWith(language: 'pt_BR', isDarkTheme: false);
      final expectedSettings = initialSettings.copyWith(isDarkTheme: true);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);
      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setDarkTheme(true);

      // Assert
      final state = container.read(themeProvider);
      expect(state.value?.language, 'pt_BR');
      expect(state.value?.isDarkTheme, true);
    });
  });

  // ===== GROUP 3: LANGUAGE SETTING =====

  group('ThemeNotifier - Language Setting', () {
    test('should update language to Portuguese', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId).copyWith(language: 'en_US');
      final expectedSettings = initialSettings.copyWith(language: 'pt_BR');

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setLanguage('pt_BR');

      // Assert
      verify(() => mockUpdateUserSettingsUseCase(any())).called(1);
      final state = container.read(themeProvider);
      expect(state.value?.language, 'pt_BR');
    });

    test('should update language to English', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings =
          UserSettingsEntity.createDefault(userId).copyWith(language: 'pt_BR');
      final expectedSettings = initialSettings.copyWith(language: 'en_US');

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((_) async => expectedSettings);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setLanguage('en_US');

      // Assert
      final state = container.read(themeProvider);
      expect(state.value?.language, 'en_US');
    });

    test('should handle null settings scenario for language', () async {
      // Arrange
      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);

      // Act
      final result = await notifier.setLanguage('pt_BR');

      // Assert
      expect(result, false);
      verifyNever(() => mockUpdateUserSettingsUseCase(any()));
    });

    test('should handle language update error', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);
      final exception = Exception('Language update failed');

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any())).thenThrow(exception);

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      final result = await notifier.setLanguage('pt_BR');

      // Assert
      expect(result, false);
      final state = container.read(themeProvider);
      expect(state.hasError, true);
      expect(state.error, exception);
    });
  });

  // ===== GROUP 4: SETTINGS VALIDATION (Entity Tests) =====

  group('ThemeNotifier - Settings Validation', () {
    test('should validate theme settings structure', () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      // Act & Assert
      expect(settings.userId, userId);
      expect(settings.isDarkTheme, isA<bool>());
      expect(settings.language, isA<String>());
    });

    test('should have valid default language', () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      // Act & Assert
      expect(settings.language.isNotEmpty, true);
    });

    test('should have valid dark theme flag', () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      // Act & Assert
      expect(settings.isDarkTheme, isFalse);
    });
  });

  // ===== GROUP 5: PERFORMANCE & EDGE CASES =====

  group('ThemeNotifier - Performance & Edge Cases', () {
    test('should handle rapid theme toggles', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((invocation) async {
        return invocation.positionalArguments[0] as UserSettingsEntity;
      });

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act - Simulate rapid toggles
      await notifier.setDarkTheme(true);
      await notifier.setDarkTheme(false);
      await notifier.setDarkTheme(true);

      // Assert
      final state = container.read(themeProvider);
      expect(state.value?.isDarkTheme, true);
      verify(() => mockUpdateUserSettingsUseCase(any())).called(3);
    });

    test('should handle multiple language changes', () async {
      // Arrange
      const userId = 'user-123';
      final initialSettings = UserSettingsEntity.createDefault(userId);

      when(() => mockGetUserSettingsUseCase(userId))
          .thenAnswer((_) async => initialSettings);

      when(() => mockUpdateUserSettingsUseCase(any()))
          .thenAnswer((invocation) async {
        return invocation.positionalArguments[0] as UserSettingsEntity;
      });

      final container = ProviderContainer(overrides: [
        getUserSettingsUseCaseProvider
            .overrideWithValue(mockGetUserSettingsUseCase),
        updateUserSettingsUseCaseProvider
            .overrideWithValue(mockUpdateUserSettingsUseCase),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      await notifier.loadSettings(userId);

      // Act
      await notifier.setLanguage('pt_BR');
      await notifier.setLanguage('en_US');
      await notifier.setLanguage('es_ES');

      // Assert
      final state = container.read(themeProvider);
      expect(state.value?.language, 'es_ES');
      verify(() => mockUpdateUserSettingsUseCase(any())).called(3);
    });
  });
}
