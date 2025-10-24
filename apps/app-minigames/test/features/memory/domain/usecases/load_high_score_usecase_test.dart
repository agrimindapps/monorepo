import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/entities/high_score_entity.dart';
import 'package:app_minigames/features/memory/domain/usecases/load_high_score_usecase.dart';
import '../../../../helpers/test_fixtures.dart';
import '../../../../helpers/mock_repositories.dart';

void main() {
  late LoadHighScoreUseCase useCase;
  late MockMemoryRepository mockRepository;

  setUp(() {
    mockRepository = MockMemoryRepository();
    useCase = LoadHighScoreUseCase(mockRepository);
  });

  group('LoadHighScoreUseCase', () {
    test('should load high score successfully for easy difficulty', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        difficulty: GameDifficulty.easy,
        score: 500,
      );

      when(() => mockRepository.loadHighScore(GameDifficulty.easy))
          .thenAnswer((_) async => Right(highScore));

      const params = LoadHighScoreParams(difficulty: GameDifficulty.easy);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore, highScore);
          expect(loadedScore.difficulty, GameDifficulty.easy);
          expect(loadedScore.score, 500);
        },
      );

      verify(() => mockRepository.loadHighScore(GameDifficulty.easy)).called(1);
    });

    test('should load high score successfully for medium difficulty', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        difficulty: GameDifficulty.medium,
        score: 1000,
      );

      when(() => mockRepository.loadHighScore(GameDifficulty.medium))
          .thenAnswer((_) async => Right(highScore));

      const params = LoadHighScoreParams(difficulty: GameDifficulty.medium);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore.difficulty, GameDifficulty.medium);
          expect(loadedScore.score, 1000);
        },
      );

      verify(() => mockRepository.loadHighScore(GameDifficulty.medium)).called(1);
    });

    test('should load high score successfully for hard difficulty', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        difficulty: GameDifficulty.hard,
        score: 2000,
      );

      when(() => mockRepository.loadHighScore(GameDifficulty.hard))
          .thenAnswer((_) async => Right(highScore));

      const params = LoadHighScoreParams(difficulty: GameDifficulty.hard);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore.difficulty, GameDifficulty.hard);
          expect(loadedScore.score, 2000);
        },
      );

      verify(() => mockRepository.loadHighScore(GameDifficulty.hard)).called(1);
    });

    test('should propagate repository failure when load fails', () async {
      // Arrange
      const failure = CacheFailure('Failed to load from local storage');

      when(() => mockRepository.loadHighScore(any()))
          .thenAnswer((_) async => const Left(failure));

      const params = LoadHighScoreParams(difficulty: GameDifficulty.medium);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Failed to load from local storage');
        },
        (_) => fail('Should not return success'),
      );

      verify(() => mockRepository.loadHighScore(GameDifficulty.medium)).called(1);
    });

    test('should return empty score when no high score exists', () async {
      // Arrange
      final emptyScore = HighScoreEntity.empty(
        difficulty: GameDifficulty.medium,
      );

      when(() => mockRepository.loadHighScore(any()))
          .thenAnswer((_) async => Right(emptyScore));

      const params = LoadHighScoreParams(difficulty: GameDifficulty.medium);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore.score, 0);
          expect(loadedScore.moves, 0);
          expect(loadedScore.hasScore, false);
        },
      );
    });

    test('should load different high scores for different difficulties', () async {
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

      when(() => mockRepository.loadHighScore(GameDifficulty.easy))
          .thenAnswer((_) async => Right(easyScore));
      when(() => mockRepository.loadHighScore(GameDifficulty.medium))
          .thenAnswer((_) async => Right(mediumScore));
      when(() => mockRepository.loadHighScore(GameDifficulty.hard))
          .thenAnswer((_) async => Right(hardScore));

      // Act
      final result1 = await useCase(const LoadHighScoreParams(difficulty: GameDifficulty.easy));
      final result2 = await useCase(const LoadHighScoreParams(difficulty: GameDifficulty.medium));
      final result3 = await useCase(const LoadHighScoreParams(difficulty: GameDifficulty.hard));

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      expect(result3.isRight(), true);

      result1.fold(
        (_) => fail('Should not fail'),
        (score) => expect(score.score, 500),
      );
      result2.fold(
        (_) => fail('Should not fail'),
        (score) => expect(score.score, 1000),
      );
      result3.fold(
        (_) => fail('Should not fail'),
        (score) => expect(score.score, 2000),
      );
    });

    test('should return high score with all properties intact', () async {
      // Arrange
      final highScore = TestFixtures.createHighScore(
        difficulty: GameDifficulty.medium,
        score: 1500,
        moves: 30,
        time: const Duration(seconds: 120),
        achievedAt: DateTime(2024, 1, 15),
      );

      when(() => mockRepository.loadHighScore(GameDifficulty.medium))
          .thenAnswer((_) async => Right(highScore));

      const params = LoadHighScoreParams(difficulty: GameDifficulty.medium);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore.score, 1500);
          expect(loadedScore.moves, 30);
          expect(loadedScore.time, const Duration(seconds: 120));
          expect(loadedScore.achievedAt, DateTime(2024, 1, 15));
          expect(loadedScore.difficulty, GameDifficulty.medium);
        },
      );
    });
  });
}
