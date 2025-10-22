import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/features/pingpong/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/ball_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/paddle_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/enums.dart';
import 'package:app_minigames/features/pingpong/domain/usecases/update_ai_paddle_usecase.dart';
import 'package:core/core.dart';

void main() {
  late UpdateAiPaddleUseCase useCase;

  setUp(() {
    useCase = UpdateAiPaddleUseCase();
  });

  group('UpdateAiPaddleUseCase', () {
    test('should move AI paddle up when ball is above', () async {
      final state = GameStateEntity(
        ball: const BallEntity(y: 0.3),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: const PaddleEntity(y: 0.5, isLeft: false),
        status: GameStatus.playing,
        difficulty: GameDifficulty.medium,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.aiPaddle.y, lessThan(state.aiPaddle.y));
        },
      );
    });

    test('should move AI paddle down when ball is below', () async {
      final state = GameStateEntity(
        ball: const BallEntity(y: 0.7),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: const PaddleEntity(y: 0.5, isLeft: false),
        status: GameStatus.playing,
        difficulty: GameDifficulty.medium,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.aiPaddle.y, greaterThan(state.aiPaddle.y));
        },
      );
    });

    test('should not move AI paddle when ball is close to center', () async {
      final state = GameStateEntity(
        ball: const BallEntity(y: 0.505),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: const PaddleEntity(y: 0.5, isLeft: false),
        status: GameStatus.playing,
        difficulty: GameDifficulty.medium,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.aiPaddle.y, closeTo(state.aiPaddle.y, 0.01));
        },
      );
    });

    test('should move faster on hard difficulty', () async {
      final stateHard = GameStateEntity(
        ball: const BallEntity(y: 0.3),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: const PaddleEntity(y: 0.5, isLeft: false),
        status: GameStatus.playing,
        difficulty: GameDifficulty.hard,
      );

      final stateEasy = GameStateEntity(
        ball: const BallEntity(y: 0.3),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: const PaddleEntity(y: 0.5, isLeft: false),
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final resultHard = await useCase(stateHard);
      final resultEasy = await useCase(stateEasy);

      double hardDelta = 0;
      double easyDelta = 0;

      resultHard.fold((_) {}, (s) => hardDelta = (stateHard.aiPaddle.y - s.aiPaddle.y).abs());
      resultEasy.fold((_) {}, (s) => easyDelta = (stateEasy.aiPaddle.y - s.aiPaddle.y).abs());

      expect(hardDelta, greaterThan(easyDelta));
    });

    test('should return failure when game is not active', () async {
      final state = GameStateEntity(
        ball: const BallEntity(),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.initial,
      );

      final result = await useCase(state);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should not return success'),
      );
    });
  });
}
