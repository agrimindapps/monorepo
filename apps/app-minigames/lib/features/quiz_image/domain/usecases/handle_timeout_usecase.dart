import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Use case that handles timeout for current question
/// Marks question as incorrect if unanswered when time runs out
class HandleTimeoutUseCase {
  HandleTimeoutUseCase();

  Either<Failure, QuizGameState> call(QuizGameState currentState) {
    // Only handle timeout if game is playing
    if (currentState.gameState != GameStateEnum.playing) {
      return const Left(GameLogicFailure('Game is not in playing state'));
    }

    // Only handle timeout if question is unanswered
    if (currentState.currentAnswerState != AnswerState.unanswered) {
      return const Left(GameLogicFailure('Question already answered'));
    }

    // Mark as incorrect due to timeout
    return Right(
      currentState.copyWith(
        currentAnswerState: AnswerState.incorrect,
        timeLeft: 0,
      ),
    );
  }
}
