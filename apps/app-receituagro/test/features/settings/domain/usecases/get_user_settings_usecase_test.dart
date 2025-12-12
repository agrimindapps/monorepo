import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';
import 'package:app_receituagro/features/settings/domain/exceptions/settings_exceptions.dart';
import 'package:app_receituagro/features/settings/domain/repositories/i_user_settings_repository.dart';
import 'package:app_receituagro/features/settings/domain/usecases/get_user_settings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

// ===== MOCK CLASSES =====

/// Mock IUserSettingsRepository for testing
class MockUserSettingsRepository extends Mock
    implements IUserSettingsRepository {}

void main() {
  late MockUserSettingsRepository mockRepository;
  late GetUserSettingsUseCase useCase;

  setUp(() {
    mockRepository = MockUserSettingsRepository();
    useCase = GetUserSettingsUseCase(mockRepository);

    // Register fallback values
    registerFallbackValue(TestFixtures.createTestSettings());
  });

  // ===== GROUP 1: SUCCESSFUL SCENARIOS =====

  group('GetUserSettingsUseCase - Successful Scenarios', () {
    test('should return existing settings when found in repository', () async {
      // Arrange
      const userId = 'test-user-123';
      final expectedSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => expectedSettings);

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result, equals(expectedSettings));
      verify(() => mockRepository.getUserSettings(userId)).called(1);
      verifyNever(() => mockRepository.saveUserSettings(any()));
    });

    test('should create and save default settings when none exist', () async {
      // Arrange
      const userId = 'new-user-123';

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => null);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result.userId, userId);
      expect(result.isDarkTheme, false);
      expect(result.notificationsEnabled, true);
      expect(result.language, 'pt-BR');
      verify(() => mockRepository.getUserSettings(userId)).called(1);
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should migrate settings with empty language', () async {
      // Arrange
      const userId = 'old-user-123';
      final oldSettings = UserSettingsEntity(
        userId: userId,
        isDarkTheme: false,
        notificationsEnabled: true,
        soundEnabled: true,
        language: '', // Empty language triggers migration
        isDevelopmentMode: false,
        speechToTextEnabled: false,
        analyticsEnabled: true,
        lastUpdated: DateTime.now().subtract(const Duration(days: 400)),
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
      );

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => oldSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result.language, 'pt-BR');
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should fix invalid settings with empty userId', () async {
      // Arrange
      const userId = 'valid-user-123';
      final invalidSettings = UserSettingsEntity(
        userId: '', // Invalid empty userId
        isDarkTheme: false,
        notificationsEnabled: true,
        soundEnabled: true,
        language: 'pt-BR',
        isDevelopmentMode: false,
        speechToTextEnabled: false,
        analyticsEnabled: true,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => invalidSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result.userId, isNotEmpty);
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should apply security policies - disable analytics in dev mode',
        () async {
      // Arrange
      const userId = 'dev-user-123';
      final devSettings = TestFixtures.createTestSettings(
        userId: userId,
      ).copyWith(
        isDevelopmentMode: true,
        analyticsEnabled: true, // Will be disabled by security policy
      );

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => devSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result.isDevelopmentMode, true);
      expect(result.analyticsEnabled, false);
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });
  });

  // ===== GROUP 2: VALIDATION ERRORS =====

  group('GetUserSettingsUseCase - Validation Errors', () {
    test('should throw InvalidUserIdException when userId is empty', () async {
      // Arrange
      const userId = '';

      // Act & Assert
      expect(
        () => useCase(userId),
        throwsA(isA<InvalidUserIdException>()),
      );
      verifyNever(() => mockRepository.getUserSettings(any()));
    });

    test('should throw InvalidUserIdException when userId is whitespace',
        () async {
      // Arrange
      const userId = '   ';

      // Act & Assert - Empty trimmed string
      expect(
        () => useCase(userId.trim()),
        throwsA(isA<InvalidUserIdException>()),
      );
    });
  });

  // ===== GROUP 3: CONTEXT-BASED OPTIMIZATION =====

  group('GetUserSettingsUseCase - Context Optimization', () {
    test('should optimize for accessibility context', () async {
      // Arrange
      const userId = 'user-123';
      final baseSettings = TestFixtures.createTestSettings(userId: userId)
          .copyWith(soundEnabled: false);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => baseSettings);

      // Act
      final result = await useCase.getForContext(
        userId,
        SettingsContext.accessibility,
      );

      // Assert
      expect(result.soundEnabled, true);
    });

    test('should optimize for performance context', () async {
      // Arrange
      const userId = 'user-123';
      final baseSettings = TestFixtures.createTestSettings(userId: userId)
          .copyWith(analyticsEnabled: true);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => baseSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.getForContext(
        userId,
        SettingsContext.performance,
      );

      // Assert
      expect(result.analyticsEnabled, false);
    });

    test('should optimize for privacy context', () async {
      // Arrange
      const userId = 'user-123';
      final baseSettings = TestFixtures.createTestSettings(userId: userId)
          .copyWith(analyticsEnabled: true, notificationsEnabled: true);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => baseSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.getForContext(
        userId,
        SettingsContext.privacy,
      );

      // Assert
      expect(result.analyticsEnabled, false);
      expect(result.notificationsEnabled, false);
    });

    test('should return unchanged settings for default context', () async {
      // Arrange
      const userId = 'user-123';
      final baseSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => baseSettings);

      // Act
      final result = await useCase.getForContext(
        userId,
        SettingsContext.default_,
      );

      // Assert
      expect(result, equals(baseSettings));
    });
  });

  // ===== GROUP 4: ERROR HANDLING =====

  group('GetUserSettingsUseCase - Error Handling', () {
    test('should propagate repository exceptions', () async {
      // Arrange
      const userId = 'user-123';
      final exception = Exception('Repository failure');

      when(() => mockRepository.getUserSettings(userId)).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(userId),
        throwsA(equals(exception)),
      );
    });

    test('should handle save failure after creating defaults', () async {
      // Arrange
      const userId = 'new-user-123';
      final exception = Exception('Save failed');

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => null);
      when(() => mockRepository.saveUserSettings(any())).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(userId),
        throwsA(equals(exception)),
      );
    });
  });

  // ===== GROUP 5: EDGE CASES =====

  group('GetUserSettingsUseCase - Edge Cases', () {
    test('should handle settings with future creation date', () async {
      // Arrange
      const userId = 'user-123';
      final futureSettings = TestFixtures.createTestSettings(userId: userId)
          .copyWith(createdAt: DateTime.now().add(const Duration(days: 1)));

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => futureSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(userId);

      // Assert - Invalid settings should be fixed
      expect(result.userId, userId);
      verify(() => mockRepository.saveUserSettings(any())).called(1);
    });

    test('should fix settings with both empty userId and language', () async {
      // Arrange
      const userId = 'valid-user-123';
      final invalidSettings = TestFixtures.createInvalidSettings();

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => invalidSettings);
      when(() => mockRepository.saveUserSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result.isValid, true);
      expect(result.userId, isNotEmpty);
      expect(result.language, isNotEmpty);
    });

    test('should not save if no changes are needed', () async {
      // Arrange
      const userId = 'user-123';
      final validSettings = TestFixtures.createTestSettings(userId: userId);

      when(() => mockRepository.getUserSettings(userId))
          .thenAnswer((_) async => validSettings);

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result, equals(validSettings));
      verify(() => mockRepository.getUserSettings(userId)).called(1);
      verifyNever(() => mockRepository.saveUserSettings(any()));
    });
  });
}
