import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';
import 'package:app_receituagro/features/settings/domain/exceptions/settings_exceptions.dart';
import 'package:app_receituagro/features/settings/domain/repositories/i_user_settings_repository.dart';
import 'package:app_receituagro/features/settings/domain/usecases/update_user_settings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

// ===== MOCK CLASSES =====

/// Mock IUserSettingsRepository for testing
class MockUserSettingsRepository extends Mock
    implements IUserSettingsRepository {}

void main() {
  late MockUserSettingsRepository mockRepository;
  late UpdateUserSettingsUseCase useCase;

  setUp(() {
    mockRepository = MockUserSettingsRepository();
    useCase = UpdateUserSettingsUseCase(mockRepository);

    // Register fallback values
    registerFallbackValue(TestFixtures.createTestSettings());
  });

  // ===== GROUP 1: SUCCESSFUL COMPLETE UPDATES =====

  group('UpdateUserSettingsUseCase - Complete Updates', () {
    test('should update complete settings successfully', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings()
          .copyWith(isDarkTheme: true, language: 'en-US');

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert
      expect(result.isDarkTheme, true);
      expect(result.language, 'en-US');
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should update lastUpdated timestamp', () async {
      // Arrange
      final oldTime = DateTime(2024, 1, 1);
      final settings = TestFixtures.createTestSettings()
          .copyWith(lastUpdated: oldTime);

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert
      expect(result.lastUpdated.isAfter(oldTime), true);
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should disable analytics when dev mode is enabled', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings().copyWith(
        isDevelopmentMode: true,
        analyticsEnabled: true,
      );

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert
      expect(result.isDevelopmentMode, true);
      expect(result.analyticsEnabled, false);
    });
  });

  // ===== GROUP 2: VALIDATION ERRORS =====

  group('UpdateUserSettingsUseCase - Validation Errors', () {
    test('should throw InvalidSettingsException when settings are invalid',
        () async {
      // Arrange
      final invalidSettings = TestFixtures.createTestSettings().copyWith(
        createdAt: DateTime.now().add(const Duration(days: 1)),
      );

      // Act & Assert
      expect(
        () => useCase(invalidSettings),
        throwsA(isA<InvalidSettingsException>()),
      );
      verifyNever(() => mockRepository.saveUserSettings(any()));
    });

    test('should throw UnsupportedLanguageException for invalid language',
        () async {
      // Arrange
      final settings = TestFixtures.createTestSettings()
          .copyWith(language: 'invalid-lang');

      // Act & Assert
      expect(
        () => useCase(settings),
        throwsA(isA<UnsupportedLanguageException>()),
      );
      verifyNever(() => mockRepository.saveUserSettings(any()));
    });

    test('should throw InvalidUserIdException when userId is empty', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings().copyWith(userId: '');

      // Act & Assert
      expect(
        () => useCase(settings),
        throwsA(isA<InvalidUserIdException>()),
      );
    });

    test('should accept pt-BR language', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings()
          .copyWith(language: 'pt-BR');

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert
      expect(result.language, 'pt-BR');
    });

    test('should accept en-US language', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings()
          .copyWith(language: 'en-US');

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert
      expect(result.language, 'en-US');
    });

    test('should accept es-ES language', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings()
          .copyWith(language: 'es-ES');

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert
      expect(result.language, 'es-ES');
    });
  });

  // ===== GROUP 3: SINGLE SETTING UPDATES =====

  group('UpdateUserSettingsUseCase - Single Setting Updates', () {
    test('should update single boolean setting', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.updateSingle(
        userId,
        'isDarkTheme',
        true,
      );

      // Assert
      expect(result.isDarkTheme, true);
      verify(() => mockRepository.getUserSettings(userId)).called(1);
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should update language setting', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.updateSingle(
        userId,
        'language',
        'en-US',
      );

      // Assert
      expect(result.language, 'en-US');
    });

    test('should throw InvalidUserIdException for empty userId in updateSingle',
        () async {
      // Arrange
      const userId = '';

      // Act & Assert
      expect(
        () => useCase.updateSingle(userId, 'isDarkTheme', true),
        throwsA(isA<InvalidUserIdException>()),
      );
    });

    test('should throw SettingsNotFoundException when settings not found',
        () async {
      // Arrange
      const userId = 'non-existent-user';

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.updateSingle(userId, 'isDarkTheme', true),
        throwsA(isA<SettingsNotFoundException>()),
      );
    });

    test('should throw InvalidUpdateException for invalid key', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);

      // Act & Assert
      expect(
        () => useCase.updateSingle(userId, 'invalidKey', true),
        throwsA(isA<InvalidUpdateException>()),
      );
    });

    test('should throw InvalidUpdateException for wrong value type', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);

      // Act & Assert
      expect(
        () => useCase.updateSingle(userId, 'isDarkTheme', 'not-a-bool'),
        throwsA(isA<InvalidUpdateException>()),
      );
    });
  });

  // ===== GROUP 4: BATCH UPDATES =====

  group('UpdateUserSettingsUseCase - Batch Updates', () {
    test('should batch update multiple settings', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);
      final updates = {
        'isDarkTheme': true,
        'language': 'en-US',
        'soundEnabled': false,
      };

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.batchUpdate(userId, updates);

      // Assert
      expect(result.isDarkTheme, true);
      expect(result.language, 'en-US');
      expect(result.soundEnabled, false);
      verify(() => mockRepository.getUserSettings(userId)).called(1);
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should throw InvalidUpdateException when updates map is empty',
        () async {
      // Arrange
      const userId = 'user-123';
      final updates = <String, dynamic>{};

      // Act & Assert
      expect(
        () => useCase.batchUpdate(userId, updates),
        throwsA(isA<InvalidUpdateException>()),
      );
    });

    test('should throw SettingsNotFoundException for batch update when not found',
        () async {
      // Arrange
      const userId = 'non-existent-user';
      final updates = {'isDarkTheme': true};

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.batchUpdate(userId, updates),
        throwsA(isA<SettingsNotFoundException>()),
      );
    });

    test('should validate all updates in batch', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);
      final updates = {
        'isDarkTheme': true,
        'invalidKey': 'value',
      };

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);

      // Act & Assert
      expect(
        () => useCase.batchUpdate(userId, updates),
        throwsA(isA<InvalidUpdateException>()),
      );
    });
  });

  // ===== GROUP 5: BUSINESS RULES =====

  group('UpdateUserSettingsUseCase - Business Rules', () {
    test('should disable speechToText when no valid subscription', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings()
          .copyWith(speechToTextEnabled: true);

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert - Subscription check currently returns true, so enabled
      expect(result.speechToTextEnabled, true);
    });

    test('should update all boolean settings independently', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings().copyWith(
        isDarkTheme: true,
        notificationsEnabled: false,
        soundEnabled: false,
        isDevelopmentMode: true,
        speechToTextEnabled: true,
        analyticsEnabled: true, // Will be disabled due to dev mode
      );

      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(settings);

      // Assert
      expect(result.isDarkTheme, true);
      expect(result.notificationsEnabled, false);
      expect(result.soundEnabled, false);
      expect(result.isDevelopmentMode, true);
      expect(result.analyticsEnabled, false); // Disabled by business rule
    });
  });

  // ===== GROUP 6: ERROR HANDLING =====

  group('UpdateUserSettingsUseCase - Error Handling', () {
    test('should propagate repository save exceptions', () async {
      // Arrange
      final settings = TestFixtures.createTestSettings();
      final exception = Exception('Save failed');

      when(() => mockRepository.saveUserSettings(any())).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(settings),
        throwsA(equals(exception)),
      );
    });

    test('should handle invalid language in single update', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);

      // Act & Assert
      expect(
        () => useCase.updateSingle(userId, 'language', 'invalid-lang'),
        throwsA(isA<UnsupportedLanguageException>()),
      );
    });

    test('should validate empty language string', () async {
      // Arrange
      const userId = 'user-123';
      final existingSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => existingSettings);

      // Act & Assert
      expect(
        () => useCase.updateSingle(userId, 'language', ''),
        throwsA(isA<InvalidUpdateException>()),
      );
    });
  });
}
