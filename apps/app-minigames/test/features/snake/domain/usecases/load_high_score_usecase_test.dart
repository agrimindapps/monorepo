import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/snake/domain/entities/high_score.dart';
import 'package:app_minigames/features/snake/domain/usecases/load_high_score_usecase.dart';
import '../../../../helpers/mock_repositories.dart';

void main() {
  late LoadHighScoreUseCase useCase;
  late MockSnakeRepository mockRepository;

  setUp(() {
    mockRepository = MockSnakeRepository();
    useCase = LoadHighScoreUseCase(mockRepository);
  });

  group('LoadHighScoreUseCase - Snake', () {
    test('should load high score successfully', () async {
      // Arrange
      const highScore = HighScore(score: 150);

      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => const Right(highScore));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore, highScore);
          expect(loadedScore.score, 150);
        },
      );

      verify(() => mockRepository.loadHighScore()).called(1);
    });

    test('should load zero score successfully', () async {
      // Arrange
      const highScore = HighScore(score: 0);

      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => const Right(highScore));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore.score, 0);
        },
      );
    });

    test('should load empty high score when no score exists', () async {
      // Arrange
      final emptyScore = HighScore.empty();

      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => Right(emptyScore));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore.score, 0);
        },
      );
    });

    test('should load high score with large value', () async {
      // Arrange
      const highScore = HighScore(score: 99999);

      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => const Right(highScore));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore.score, 99999);
        },
      );
    });

    test('should propagate repository failure when load fails', () async {
      // Arrange
      const failure = CacheFailure('Failed to load from local storage');

      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Failed to load from local storage');
        },
        (_) => fail('Should not return success'),
      );

      verify(() => mockRepository.loadHighScore()).called(1);
    });

    test('should handle multiple load calls successfully', () async {
      // Arrange
      const highScore1 = HighScore(score: 100);
      const highScore2 = HighScore(score: 200);

      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => const Right(highScore1));

      // Act - First load
      final result1 = await useCase();

      // Change mock return
      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => const Right(highScore2));

      // Act - Second load
      final result2 = await useCase();

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      result1.fold(
        (_) => fail('Should not fail'),
        (score) => expect(score.score, 100),
      );
      result2.fold(
        (_) => fail('Should not fail'),
        (score) => expect(score.score, 200),
      );

      verify(() => mockRepository.loadHighScore()).called(2);
    });

    test('should return complete HighScore entity with all properties', () async {
      // Arrange
      const highScore = HighScore(score: 250);

      when(() => mockRepository.loadHighScore())
          .thenAnswer((_) async => const Right(highScore));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (loadedScore) {
          expect(loadedScore, isA<HighScore>());
          expect(loadedScore.score, 250);
          expect(loadedScore.props, [250]);
        },
      );
    });
  });
}
