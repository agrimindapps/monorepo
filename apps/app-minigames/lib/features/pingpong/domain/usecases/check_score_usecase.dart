import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';
import '../services/score_manager_service.dart';

class CheckScoreUseCase {
  final ScoreManagerService _scoreService;

  CheckScoreUseCase(this._scoreService);

  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return Left(ValidationFailure('Game is not active'));
    }

    try {
      final scoreUpdate = _scoreService.checkBoundaries(
        ball: state.ball,
        playerScore: state.playerScore,
        aiScore: state.aiScore,
      );

      if (!scoreUpdate.shouldUpdate) {
        return Right(state);
      }

      final newMaxRally = state.currentRally > state.maxRally
          ? state.currentRally
          : state.maxRally;

      final gameOverResult = _scoreService.checkGameOver(
        playerScore: scoreUpdate.newPlayerScore,
        aiScore: scoreUpdate.newAiScore,
      );

      var newState = state.copyWith(
        playerScore: scoreUpdate.newPlayerScore,
        aiScore: scoreUpdate.newAiScore,
        maxRally: newMaxRally,
        currentRally: 0,
      );

      if (gameOverResult.isGameOver) {
        newState = newState.copyWith(status: GameStatus.gameOver);
      } else {
        final newBall = state.ball.reset(toLeft: scoreUpdate.resetBallToLeft);
        newState = newState.copyWith(ball: newBall);
      }

      return Right(newState);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check score: $e'));
    }
  }
}
