// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Core imports:
import 'package:core/core.dart' hide test;

// Data imports:
import 'package:app_minigames/features/flappbird/data/datasources/flappbird_local_datasource.dart';
import 'package:app_minigames/features/flappbird/data/models/high_score_model.dart';
import 'package:app_minigames/features/flappbird/data/repositories/flappbird_repository_impl.dart';

// Mocks
class MockFlappbirdLocalDataSource extends Mock
    implements FlappbirdLocalDataSource {}

void main() {
  late FlappbirdRepositoryImpl repository;
  late MockFlappbirdLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFlappbirdLocalDataSource();
    repository = FlappbirdRepositoryImpl(mockDataSource);
  });

  group('FlappbirdRepositoryImpl', () {
    group('loadHighScore', () {
      test('should return high score from data source', () async {
        // Arrange
        final highScore = HighScoreModel(
          score: 42,
          achievedAt: DateTime(2024, 1, 1),
        );

        when(() => mockDataSource.loadHighScore())
            .thenAnswer((_) async => highScore);

        // Act
        final result = await repository.loadHighScore();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (score) {
            expect(score.score, 42);
            expect(score.achievedAt, DateTime(2024, 1, 1));
          },
        );

        verify(() => mockDataSource.loadHighScore()).called(1);
      });

      test('should return CacheFailure when data source throws', () async {
        // Arrange
        when(() => mockDataSource.loadHighScore())
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await repository.loadHighScore();

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

      test('should return empty high score when data source returns empty',
          () async {
        // Arrange
        when(() => mockDataSource.loadHighScore())
            .thenAnswer((_) async => HighScoreModel.empty());

        // Act
        final result = await repository.loadHighScore();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (score) {
            expect(score.score, 0);
            expect(score.achievedAt, null);
          },
        );
      });
    });

    group('saveHighScore', () {
      test('should save high score to data source', () async {
        // Arrange
        when(() => mockDataSource.saveHighScore(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.saveHighScore(score: 100);

        // Assert
        expect(result.isRight(), true);

        final captured = verify(
          () => mockDataSource.saveHighScore(captureAny()),
        ).captured;

        expect(captured.length, 1);
        final savedModel = captured.first as HighScoreModel;
        expect(savedModel.score, 100);
        expect(savedModel.achievedAt, isNotNull);
      });

      test('should return CacheFailure when data source throws', () async {
        // Arrange
        when(() => mockDataSource.saveHighScore(any()))
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await repository.saveHighScore(score: 50);

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

      test('should include timestamp when saving', () async {
        // Arrange
        when(() => mockDataSource.saveHighScore(any()))
            .thenAnswer((_) async => {});

        final beforeSave = DateTime.now();

        // Act
        await repository.saveHighScore(score: 75);

        final afterSave = DateTime.now();

        // Assert
        final captured = verify(
          () => mockDataSource.saveHighScore(captureAny()),
        ).captured;

        final savedModel = captured.first as HighScoreModel;
        expect(savedModel.achievedAt, isNotNull);
        expect(
          savedModel.achievedAt!.isAfter(beforeSave.subtract(const Duration(seconds: 1))),
          true,
        );
        expect(
          savedModel.achievedAt!.isBefore(afterSave.add(const Duration(seconds: 1))),
          true,
        );
      });
    });
  });
}
