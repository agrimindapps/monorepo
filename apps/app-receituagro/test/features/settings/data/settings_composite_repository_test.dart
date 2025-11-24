import 'package:app_receituagro/features/settings/data/repositories/settings_composite_repository_impl.dart';
import 'package:app_receituagro/features/settings/domain/entities/tts_settings_entity.dart';
import 'package:app_receituagro/features/settings/domain/entities/user_settings_entity.dart';
import 'package:app_receituagro/features/settings/domain/repositories/i_tts_settings_repository.dart';
import 'package:app_receituagro/features/settings/domain/repositories/i_user_settings_repository.dart';
import 'package:app_receituagro/features/settings/domain/repositories/profile_repository.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock repositories
class MockUserSettingsRepository extends Mock
    implements IUserSettingsRepository {}

class MockTTSSettingsRepository extends Mock
    implements ITTSSettingsRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late SettingsCompositeRepositoryImpl composite;
  late MockUserSettingsRepository mockUserRepo;
  late MockTTSSettingsRepository mockTTSRepo;
  late MockProfileRepository mockProfileRepo;

  setUp(() {
    mockUserRepo = MockUserSettingsRepository();
    mockTTSRepo = MockTTSSettingsRepository();
    mockProfileRepo = MockProfileRepository();

    composite = SettingsCompositeRepositoryImpl(
      mockUserRepo,
      mockTTSRepo,
      mockProfileRepo,
    );
  });

  group('SettingsCompositeRepository - User Settings Delegation', () {
    test('getUserSettings should delegate to user settings repository',
        () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      when(() => mockUserRepo.getUserSettings(userId))
          .thenAnswer((_) async => settings);

      // Act
      final result = await composite.getUserSettings(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (retrievedSettings) {
          expect(retrievedSettings, equals(settings));
        },
      );

      verify(() => mockUserRepo.getUserSettings(userId)).called(1);
    });

    test('saveUserSettings should delegate to user settings repository',
        () async {
      // Arrange
      const userId = 'user-123';
      final settings = UserSettingsEntity.createDefault(userId);

      when(() => mockUserRepo.saveUserSettings(settings))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await composite.saveUserSettings(settings);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockUserRepo.saveUserSettings(settings)).called(1);
    });
  });

  group('SettingsCompositeRepository - TTS Settings Delegation', () {
    test('getTTSSettings should delegate to TTS repository', () async {
      // Arrange
      const userId = 'user-123';
      final ttsSettings = TTSSettingsEntity.defaults();

      when(() => mockTTSRepo.getSettings(userId))
          .thenAnswer((_) async => Right(ttsSettings));

      // Act
      final result = await composite.getTTSSettings(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings, equals(ttsSettings));
        },
      );

      verify(() => mockTTSRepo.getSettings(userId)).called(1);
    });

    test('saveTTSSettings should delegate to TTS repository', () async {
      // Arrange
      const userId = 'user-123';
      final ttsSettings = TTSSettingsEntity.defaults();

      when(() => mockTTSRepo.saveSettings(userId, ttsSettings))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await composite.saveTTSSettings(userId, ttsSettings);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockTTSRepo.saveSettings(userId, ttsSettings)).called(1);
    });
  });

  group('SettingsCompositeRepository - Profile Delegation', () {
    test('hasProfileImage should delegate to profile repository', () {
      // Arrange
      when(() => mockProfileRepo.hasProfileImage()).thenReturn(true);

      // Act
      final result = composite.hasProfileImage();

      // Assert
      expect(result, true);
      verify(() => mockProfileRepo.hasProfileImage()).called(1);
    });

    test('getCurrentProfileImageUrl should delegate to profile repository',
        () {
      // Arrange
      const imageUrl = 'https://example.com/profile.jpg';
      when(() => mockProfileRepo.getCurrentProfileImageUrl())
          .thenReturn(imageUrl);

      // Act
      final result = composite.getCurrentProfileImageUrl();

      // Assert
      expect(result, imageUrl);
      verify(() => mockProfileRepo.getCurrentProfileImageUrl()).called(1);
    });
  });

  group('SettingsCompositeRepository - Unified Operations', () {
    test('resetAllSettings should reset all repositories', () async {
      // Arrange
      const userId = 'user-123';

      when(() => mockUserRepo.resetToDefault(userId))
          .thenAnswer((_) async => Future.value());
      when(() => mockTTSRepo.resetToDefault(userId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await composite.resetAllSettings(userId);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockUserRepo.resetToDefault(userId)).called(1);
      verify(() => mockTTSRepo.resetToDefault(userId)).called(1);
    });

    test('resetAllSettings should fail if TTS reset fails', () async {
      // Arrange
      const userId = 'user-123';
      const failure = CacheFailure('TTS reset failed');

      when(() => mockUserRepo.resetToDefault(userId))
          .thenAnswer((_) async => Future.value());
      when(() => mockTTSRepo.resetToDefault(userId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await composite.resetAllSettings(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, contains('Failed to reset TTS settings'));
        },
        (_) => fail('Should return failure'),
      );
    });

    test('exportAllSettings should aggregate all settings data', () async {
      // Arrange
      const userId = 'user-123';
      final ttsSettings = TTSSettingsEntity.defaults();

      when(() => mockUserRepo.exportSettings(userId))
          .thenAnswer((_) async => {'user': 'data'});
      when(() => mockTTSRepo.getSettings(userId))
          .thenAnswer((_) async => Right(ttsSettings));
      when(() => mockProfileRepo.hasProfileImage()).thenReturn(true);
      when(() => mockProfileRepo.getCurrentProfileImageUrl())
          .thenReturn('https://example.com/profile.jpg');
      when(() => mockProfileRepo.getUserInitials()).thenReturn('JD');

      // Act
      final result = await composite.exportAllSettings(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data['userSettings'], isNotNull);
          expect(data['ttsSettings'], isNotNull);
          expect(data['profile'], isNotNull);
          expect(data['metadata'], isNotNull);

          // Verify structure
          final profile = data['profile'] as Map<String, dynamic>;
          expect(profile['hasImage'], true);
          expect(profile['imageUrl'], 'https://example.com/profile.jpg');
          expect(profile['initials'], 'JD');

          final metadata = data['metadata'] as Map<String, dynamic>;
          expect(metadata['userId'], userId);
          expect(metadata['version'], '1.0.0');
          expect(metadata['exportedAt'], isNotNull);
        },
      );

      verify(() => mockUserRepo.exportSettings(userId)).called(1);
      verify(() => mockTTSRepo.getSettings(userId)).called(1);
      verify(() => mockProfileRepo.hasProfileImage()).called(1);
    });

    test('getSettingsSummary should aggregate settings information', () async {
      // Arrange
      const userId = 'user-123';
      final userSettings = UserSettingsEntity.createDefault(userId);
      final ttsSettings = TTSSettingsEntity.defaults();

      when(() => mockUserRepo.getUserSettings(userId))
          .thenAnswer((_) async => userSettings);
      when(() => mockTTSRepo.getSettings(userId))
          .thenAnswer((_) async => Right(ttsSettings));
      when(() => mockProfileRepo.hasProfileImage()).thenReturn(true);

      // Act
      final result = await composite.getSettingsSummary(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          expect(summary.hasUserSettings, true);
          expect(summary.hasTTSSettings, true);
          expect(summary.hasProfileImage, true);
          expect(summary.totalSettingsCount, 3);
          expect(summary.lastUpdated, isNotNull);
        },
      );
    });

    test('hasPendingSync should check sync status', () async {
      // Arrange
      const userId = 'user-123';
      final userSettings = UserSettingsEntity.createDefault(userId);

      when(() => mockUserRepo.isSyncEnabled(userId))
          .thenAnswer((_) async => true);
      when(() => mockUserRepo.getUserSettings(userId))
          .thenAnswer((_) async => userSettings);

      // Act
      final result = await composite.hasPendingSync(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (hasPending) {
          expect(hasPending, true);
        },
      );

      verify(() => mockUserRepo.isSyncEnabled(userId)).called(1);
      verify(() => mockUserRepo.getUserSettings(userId)).called(1);
    });
  });

  group('SettingsCompositeRepository - Error Handling', () {
    test('getUserSettings should handle repository exceptions', () async {
      // Arrange
      const userId = 'user-123';

      when(() => mockUserRepo.getUserSettings(userId))
          .thenThrow(Exception('Repository error'));

      // Act
      final result = await composite.getUserSettings(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, contains('Failed to get user settings'));
        },
        (_) => fail('Should return failure'),
      );
    });

    test('exportAllSettings should handle repository exceptions', () async {
      // Arrange
      const userId = 'user-123';

      when(() => mockUserRepo.exportSettings(userId))
          .thenThrow(Exception('Export failed'));

      // Act
      final result = await composite.exportAllSettings(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, contains('Failed to export settings'));
        },
        (_) => fail('Should return failure'),
      );
    });
  });
}
