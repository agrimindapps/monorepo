import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';

class CheckScoreUseCase {
  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return Left(ValidationFailure('Game is not active'));
    }

    try {
      final ball = state.ball;

      if (ball.x < 0.0) {
        final newAiScore = state.aiScore + 1;
        final newMaxRally =
            state.currentRally > state.maxRally ? state.currentRally : state.maxRally;

        return Right(state.copyWith(
          ball: ball.reset(toLeft: false),
          aiScore: newAiScore,
          currentRally: 0,
          maxRally: newMaxRally,
          status: newAiScore >= GameStateEntity.winningScore
              ? GameStatus.gameOver
              : GameStatus.playing,
        ));
      }

      if (ball.x > 1.0) {
        final newPlayerScore = state.playerScore + 1;
        final newMaxRally =
            state.currentRally > state.maxRally ? state.currentRally : state.maxRally;

        return Right(state.copyWith(
          ball: ball.reset(toLeft: true),
          playerScore: newPlayerScore,
          currentRally: 0,
          maxRally: newMaxRally,
          status: newPlayerScore >= GameStateEntity.winningScore
              ? GameStatus.gameOver
              : GameStatus.playing,
        ));
      }

      return Right(state);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check score: $e'));
    }
  }
}
