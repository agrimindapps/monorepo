// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to advance to next question
@injectable
class NextQuestionUseCase {
  NextQuestionUseCase();

  /// Execute the use case
  /// Advances to next question or ends game
  Future<Either<Failure, QuizGameState>> call({
    required QuizGameState currentState,
  }) async {
    // Check if there are more questions
    if (currentState.hasMoreQuestions) {
      // Advance to next question
      return Right(currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
        timeLeft: currentState.difficulty.timeInSeconds,
        currentAnswerState: AnswerState.none,
      ));
    } else {
      // No more questions: game over
      return Right(currentState.copyWith(
        gameStatus: QuizGameStatus.gameOver,
      ));
    }
  }
}
