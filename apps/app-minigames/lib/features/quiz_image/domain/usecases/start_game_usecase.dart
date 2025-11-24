import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Use case that starts a new quiz game
/// Validates game state and transitions to playing state
class StartGameUseCase {
  StartGameUseCase();

  Either<Failure, QuizGameState> call(QuizGameState currentState) {
    // Validate that we have questions loaded
    if (currentState.questions.isEmpty) {
      return const Left(GameLogicFailure('No questions loaded'));
    }

    // Validate game is in ready state
    if (currentState.gameState != GameStateEnum.ready) {
      return const Left(GameLogicFailure('Game already started'));
    }

    return Right(
      currentState.copyWith(
        gameState: GameStateEnum.playing,
        currentQuestionIndex: 0,
        correctAnswers: 0,
        timeLeft: currentState.difficulty.timeLimit,
        currentAnswerState: AnswerState.unanswered,
        currentSelectedAnswer: null,
      ),
    );
  }
}
