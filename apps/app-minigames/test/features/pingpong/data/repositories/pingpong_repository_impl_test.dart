import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_minigames/features/pingpong/data/datasources/pingpong_local_datasource.dart';
import 'package:app_minigames/features/pingpong/data/models/high_score_model.dart';
import 'package:app_minigames/features/pingpong/data/repositories/pingpong_repository_impl.dart';
import 'package:app_minigames/features/pingpong/domain/entities/enums.dart';
import 'package:app_minigames/features/pingpong/domain/entities/high_score_entity.dart';
import 'package:core/core.dart';

class MockPingpongLocalDataSource extends Mock
    implements PingpongLocalDataSource {}

class _FakeHighScoreModel extends Fake implements HighScoreModel {}

void main() {
  late PingpongRepositoryImpl repository;
  late MockPingpongLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPingpongLocalDataSource();
    repository = PingpongRepositoryImpl(mockDataSource);
    registerFallbackValue(_FakeHighScoreModel());
  });

  group('PingpongRepositoryImpl', () {
    final tHighScore = HighScoreModel(
      score: 1000,
      difficulty: GameDifficulty.medium,
      date: DateTime(2024, 1, 1),
      gameDuration: const Duration(minutes: 2),
      totalHits: 25,
    );

    test('should return high score when datasource succeeds', () async {
      when(() => mockDataSource.getHighScore(GameDifficulty.medium))
          .thenAnswer((_) async => tHighScore);

      final result = await repository.getHighScore(GameDifficulty.medium);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (highScore) => expect(highScore, tHighScore),
      );
      verify(() => mockDataSource.getHighScore(GameDifficulty.medium)).called(1);
    });

    test('should return null when no high score exists', () async {
      when(() => mockDataSource.getHighScore(GameDifficulty.easy))
          .thenAnswer((_) async => null);

      final result = await repository.getHighScore(GameDifficulty.easy);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (highScore) => expect(highScore, null),
      );
    });

    test('should return CacheFailure when datasource throws exception', () async {
      when(() => mockDataSource.getHighScore(GameDifficulty.hard))
          .thenThrow(Exception('Storage error'));

      final result = await repository.getHighScore(GameDifficulty.hard);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should not return success'),
      );
    });

    test('should save high score successfully', () async {
      when(() => mockDataSource.saveHighScore(any()))
          .thenAnswer((_) async => {});

      final result = await repository.saveHighScore(tHighScore);

      expect(result.isRight(), true);
      verify(() => mockDataSource.saveHighScore(any())).called(1);
    });

    test('should return CacheFailure when save fails', () async {
      when(() => mockDataSource.saveHighScore(any()))
          .thenThrow(Exception('Storage error'));

      final result = await repository.saveHighScore(tHighScore);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should not return success'),
      );
    });

    test('should clear high scores successfully', () async {
      when(() => mockDataSource.clearHighScores())
          .thenAnswer((_) async => {});

      final result = await repository.clearHighScores();

      expect(result.isRight(), true);
      verify(() => mockDataSource.clearHighScores()).called(1);
    });
  });
}
