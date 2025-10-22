// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to handle question timeout
@injectable
class HandleTimeoutUseCase {
  HandleTimeoutUseCase();

  /// Execute the use case
  /// Timeout = lose 1 life
  Future<Either<Failure, QuizGameState>> call({
    required QuizGameState currentState,
  }) async {
    // Validation: game must be playing
    if (!currentState.gameStatus.isPlaying) {
      return Left(GameLogicFailure('Game is not in progress'));
    }

    // Timeout: lose 1 life
    final newLives = currentState.lives - 1;

    return Right(currentState.copyWith(
      lives: newLives,
      timeLeft: 0,
      currentAnswerState: AnswerState.incorrect,
      gameStatus: newLives <= 0 ? QuizGameStatus.gameOver : currentState.gameStatus,
    ));
  }
}
