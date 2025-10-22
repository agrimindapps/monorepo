import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/features/pingpong/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/ball_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/paddle_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/enums.dart';
import 'package:app_minigames/features/pingpong/domain/usecases/update_ball_usecase.dart';
import 'package:core/core.dart';

void main() {
  late UpdateBallUseCase useCase;

  setUp(() {
    useCase = UpdateBallUseCase();
  });

  group('UpdateBallUseCase', () {
    test('should move ball when game is playing', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 0.5, y: 0.5, velocityX: 0.01, velocityY: 0.005),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.ball.x, greaterThan(state.ball.x));
          expect(newState.ball.y, greaterThan(state.ball.y));
        },
      );
    });

    test('should bounce ball off top wall', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 0.5, y: 0.01, velocityX: 0.01, velocityY: -0.005),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.ball.velocityY, greaterThan(0));
        },
      );
    });

    test('should bounce ball off bottom wall', () async {
      final state = GameStateEntity(
        ball: const BallEntity(x: 0.5, y: 0.99, velocityX: 0.01, velocityY: 0.005),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.playing,
      );

      final result = await useCase(state);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.ball.velocityY, lessThan(0));
        },
      );
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
