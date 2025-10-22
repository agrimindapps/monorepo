import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Use case that advances to the next question or ends the game
/// Resets timer and answer state for next question
@injectable
class NextQuestionUseCase {
  NextQuestionUseCase();

  Either<Failure, QuizGameState> call(QuizGameState currentState) {
    // Validate game is playing
    if (currentState.gameState != GameStateEnum.playing) {
      return const Left(GameLogicFailure('Game is not in playing state'));
    }

    // Check if this is the last question
    if (currentState.isLastQuestion) {
      // End game
      return Right(
        currentState.copyWith(
          gameState: GameStateEnum.gameOver,
        ),
      );
    }

    // Advance to next question
    return Right(
      currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
        currentAnswerState: AnswerState.unanswered,
        currentSelectedAnswer: null,
        timeLeft: currentState.difficulty.timeLimit,
      ),
    );
  }
}
