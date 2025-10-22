import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/features/pingpong/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/ball_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/paddle_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/enums.dart';
import 'package:app_minigames/features/pingpong/domain/usecases/check_collision_usecase.dart';
import 'package:core/core.dart';

void main() {
  late CheckCollisionUseCase useCase;

  setUp(() {
    useCase = CheckCollisionUseCase();
  });

  group('CheckCollisionUseCase', () {
    test('should detect player paddle collision and reverse ball', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 0.06, y: 0.5, velocityX: -0.005),
        playerPaddle: const PaddleEntity(y: 0.5, isLeft: true),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.ball.velocityX, greaterThan(0));
          expect(newState.currentRally, 1);
          expect(newState.totalHits, 1);
        },
      );
    });

    test('should detect AI paddle collision and reverse ball', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 0.94, y: 0.5, velocityX: 0.005),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: const PaddleEntity(y: 0.5, isLeft: false),
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.ball.velocityX, lessThan(0));
          expect(newState.currentRally, 1);
          expect(newState.totalHits, 1);
        },
      );
    });

    test('should not detect collision when ball is far from paddles', () async {
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
          expect(newState.ball.velocityX, state.ball.velocityX);
          expect(newState.currentRally, 0);
          expect(newState.totalHits, 0);
        },
      );
    });

    test('should adjust ball angle based on hit position', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 0.06, y: 0.55, velocityX: -0.005),
        playerPaddle: const PaddleEntity(y: 0.5, isLeft: true),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.ball.velocityY, isNot(equals(state.ball.velocityY)));
        },
      );
    });

    test('should return failure when game is not active', () async {
      final state = GameStateEntity(
        ball: const BallEntity(),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.paused,
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
