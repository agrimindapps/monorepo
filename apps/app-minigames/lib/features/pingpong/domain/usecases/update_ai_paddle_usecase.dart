import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/game_state_entity.dart';

class UpdateAiPaddleUseCase {
  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return Left(ValidationFailure('Game is not active'));
    }

    try {
      var aiPaddle = state.aiPaddle;
      final ball = state.ball;
      final aiSpeed = state.difficulty.aiSpeed;
      final reactionDelay = state.difficulty.aiReactionDelay;

      final targetY = ball.y;
      final currentY = aiPaddle.y;

      if (targetY < currentY - reactionDelay) {
        aiPaddle = aiPaddle.moveUp(aiSpeed);
      } else if (targetY > currentY + reactionDelay) {
        aiPaddle = aiPaddle.moveDown(aiSpeed);
      }

      return Right(state.copyWith(aiPaddle: aiPaddle));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update AI paddle: $e'));
    }
  }
}
