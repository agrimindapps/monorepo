import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Use case that decrements the timer by one second
/// Returns failure if timer reaches zero
class UpdateTimerUseCase {
  UpdateTimerUseCase();

  Either<Failure, QuizGameState> call(QuizGameState currentState) {
    // Only update timer if game is playing
    if (currentState.gameState != GameStateEnum.playing) {
      return const Left(GameLogicFailure('Game is not in playing state'));
    }

    // Don't decrement if already answered
    if (currentState.currentAnswerState != AnswerState.unanswered) {
      return Right(currentState);
    }

    // Decrement timer
    final newTimeLeft = currentState.timeLeft - 1;

    // Prevent negative time
    if (newTimeLeft < 0) {
      return Right(currentState.copyWith(timeLeft: 0));
    }

    return Right(currentState.copyWith(timeLeft: newTimeLeft));
  }
}
