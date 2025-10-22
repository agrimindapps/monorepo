import 'package:app_minigames/features/sudoku/data/datasources/sudoku_local_datasource.dart';
import 'package:app_minigames/features/sudoku/data/models/high_score_model.dart';
import 'package:app_minigames/features/sudoku/data/repositories/sudoku_repository_impl.dart';
import 'package:app_minigames/features/sudoku/domain/entities/enums.dart';
import 'package:app_minigames/features/sudoku/domain/entities/high_score_entity.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSudokuLocalDataSource extends Mock implements SudokuLocalDataSource {}

void main() {
  late SudokuRepositoryImpl repository;
  late MockSudokuLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSudokuLocalDataSource();
    repository = SudokuRepositoryImpl(mockDataSource);
  });

  group('SudokuRepositoryImpl', () {
    group('loadHighScore', () {
      test('should return high score when data exists', () async {
        // Arrange
        final highScoreModel = HighScoreModel(
          bestTime: 300,
          fewestMistakes: 2,
          gamesCompleted: 5,
          difficulty: GameDifficulty.medium,
          lastPlayedAt: DateTime(2024, 1, 1),
        );

        when(() => mockDataSource.loadHighScore(GameDifficulty.medium))
            .thenAnswer((_) async => highScoreModel);

        // Act
        final result = await repository.loadHighScore(GameDifficulty.medium);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (highScore) {
            expect(highScore.bestTime, 300);
            expect(highScore.fewestMistakes, 2);
            expect(highScore.gamesCompleted, 5);
            expect(highScore.difficulty, GameDifficulty.medium);
          },
        );

        verify(() => mockDataSource.loadHighScore(GameDifficulty.medium))
            .called(1);
      });

      test('should return initial high score when no data exists', () async {
        // Arrange
        when(() => mockDataSource.loadHighScore(GameDifficulty.easy))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.loadHighScore(GameDifficulty.easy);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (highScore) {
            expect(highScore.bestTime, 0);
            expect(highScore.fewestMistakes, 0);
            expect(highScore.gamesCompleted, 0);
            expect(highScore.difficulty, GameDifficulty.easy);
            expect(highScore.lastPlayedAt, null);
          },
        );
      });

      test('should return CacheFailure when datasource throws exception', () async {
        // Arrange
        when(() => mockDataSource.loadHighScore(GameDifficulty.hard))
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await repository.loadHighScore(GameDifficulty.hard);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to load high score'));
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('saveHighScore', () {
      test('should save high score successfully', () async {
        // Arrange
        final highScore = HighScoreEntity(
          bestTime: 200,
          fewestMistakes: 1,
          gamesCompleted: 10,
          difficulty: GameDifficulty.hard,
          lastPlayedAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.saveHighScore(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.saveHighScore(highScore);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockDataSource.saveHighScore(any())).called(1);
      });

      test('should return CacheFailure when save fails', () async {
        // Arrange
        final highScore = HighScoreEntity.initial(GameDifficulty.medium);

        when(() => mockDataSource.saveHighScore(any()))
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await repository.saveHighScore(highScore);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to save high score'));
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('getAllHighScores', () {
      test('should return all high scores', () async {
        // Arrange
        final highScores = [
          HighScoreModel(
            bestTime: 100,
            fewestMistakes: 0,
            gamesCompleted: 3,
            difficulty: GameDifficulty.easy,
          ),
          HighScoreModel(
            bestTime: 200,
            fewestMistakes: 1,
            gamesCompleted: 5,
            difficulty: GameDifficulty.medium,
          ),
        ];

        when(() => mockDataSource.getAllHighScores())
            .thenAnswer((_) async => highScores);

        // Act
        final result = await repository.getAllHighScores();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (scores) {
            expect(scores.length, 2);
            expect(scores[0].difficulty, GameDifficulty.easy);
            expect(scores[1].difficulty, GameDifficulty.medium);
          },
        );
      });

      test('should return CacheFailure when loading all fails', () async {
        // Arrange
        when(() => mockDataSource.getAllHighScores())
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await repository.getAllHighScores();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('clearAllHighScores', () {
      test('should clear all high scores successfully', () async {
        // Arrange
        when(() => mockDataSource.clearAllHighScores())
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.clearAllHighScores();

        // Assert
        expect(result.isRight(), true);
        verify(() => mockDataSource.clearAllHighScores()).called(1);
      });

      test('should return CacheFailure when clear fails', () async {
        // Arrange
        when(() => mockDataSource.clearAllHighScores())
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await repository.clearAllHighScores();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
          },
          (_) => fail('Should not return success'),
        );
      });
    });
  });
}
