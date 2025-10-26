import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/entities/high_score_entity.dart';
import 'package:app_minigames/features/memory/domain/usecases/save_high_score_usecase.dart';
import '../../../../helpers/test_fixtures.dart';
import '../../../../helpers/mock_repositories.dart';

void main() {
  late SaveHighScoreUseCase useCase;
  late MockMemoryRepository mockRepository;

  setUp(() {
    mockRepository = MockMemoryRepository();
    useCase = SaveHighScoreUseCase(mockRepository);

    // Register fallback values for any() matchers
    registerFallbackValue(TestFixtures.createHighScore());
  });

  group('SaveHighScoreUseCase', () {
    test('should save high score successfully with valid data', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        score: 1500,
        moves: 25,
        time: const Duration(seconds: 90),
      );

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(highScore);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveHighScore(highScore)).called(1);
    });

    test('should return ValidationFailure when score is negative', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        score: -100,
        moves: 25,
      );

      // Act
      final result = await useCase(highScore);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Score cannot be negative');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.saveHighScore(any()));
    });

    test('should return ValidationFailure when moves is negative', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        score: 1000,
        moves: -5,
      );

      // Act
      final result = await useCase(highScore);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Moves cannot be negative');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.saveHighScore(any()));
    });

    test('should accept zero score as valid', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        score: 0,
        moves: 10,
      );

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(highScore);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveHighScore(highScore)).called(1);
    });

    test('should accept zero moves as valid', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        score: 1000,
        moves: 0,
      );

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(highScore);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveHighScore(highScore)).called(1);
    });

    test('should propagate repository failure when save fails', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore();
      const failure = CacheFailure('Failed to save to local storage');

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(highScore);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Failed to save to local storage');
        },
        (_) => fail('Should not return success'),
      );

      verify(() => mockRepository.saveHighScore(highScore)).called(1);
    });

    test('should validate before calling repository', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        score: -100,
        moves: 25,
      );

      // Act
      final result = await useCase(highScore);

      // Assert
      expect(result.isLeft(), true);
      verifyNever(() => mockRepository.saveHighScore(any()));
    });

    test('should save high scores for different difficulties', () async {
      // Arrange
      final easyScore = TestFixtures.createHighScore(
        difficulty: GameDifficulty.easy,
        score: 500,
      );
      final mediumScore = TestFixtures.createHighScore(
        difficulty: GameDifficulty.medium,
        score: 1000,
      );
      final hardScore = TestFixtures.createHighScore(
        difficulty: GameDifficulty.hard,
        score: 2000,
      );

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result1 = await useCase(easyScore);
      final result2 = await useCase(mediumScore);
      final result3 = await useCase(hardScore);

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      expect(result3.isRight(), true);

      verify(() => mockRepository.saveHighScore(easyScore)).called(1);
      verify(() => mockRepository.saveHighScore(mediumScore)).called(1);
      verify(() => mockRepository.saveHighScore(hardScore)).called(1);
    });
  });
}
