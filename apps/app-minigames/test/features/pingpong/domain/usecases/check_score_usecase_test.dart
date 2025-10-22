import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/features/pingpong/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/ball_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/paddle_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/enums.dart';
import 'package:app_minigames/features/pingpong/domain/usecases/check_score_usecase.dart';
import 'package:core/core.dart';

void main() {
  late CheckScoreUseCase useCase;

  setUp(() {
    useCase = CheckScoreUseCase();
  });

  group('CheckScoreUseCase', () {
    test('should score for AI when ball goes off left side', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: -0.1, y: 0.5),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
        currentRally: 5,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.aiScore, 1);
          expect(newState.ball.x, 0.5);
          expect(newState.ball.y, 0.5);
          expect(newState.currentRally, 0);
          expect(newState.maxRally, 5);
        },
      );
    });

    test('should score for player when ball goes off right side', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 1.1, y: 0.5),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
        currentRally: 3,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.playerScore, 1);
          expect(newState.ball.x, 0.5);
          expect(newState.ball.y, 0.5);
          expect(newState.currentRally, 0);
          expect(newState.maxRally, 3);
        },
      );
    });

    test('should end game when player reaches winning score', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 1.1, y: 0.5),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        playerScore: 4,
        aiScore: 2,
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.playerScore, 5);
          expect(newState.status, GameStatus.gameOver);
        },
      );
    });

    test('should end game when AI reaches winning score', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: -0.1, y: 0.5),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        playerScore: 2,
        aiScore: 4,
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.aiScore, 5);
          expect(newState.status, GameStatus.gameOver);
        },
      );
    });

    test('should not score when ball is in play', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 0.5, y: 0.5),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.playerScore, 0);
          expect(newState.aiScore, 0);
          expect(newState.status, GameStatus.playing);
        },
      );
    });

    test('should return failure when game is not active', () async {
      final state = GameStateEntity(
        ball: const BallEntity(),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.gameOver,
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
