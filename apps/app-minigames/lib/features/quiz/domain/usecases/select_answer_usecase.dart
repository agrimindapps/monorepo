// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to process answer selection
@injectable
class SelectAnswerUseCase {
  SelectAnswerUseCase();

  /// Execute the use case
  /// Validates answer and updates score/lives
  Future<Either<Failure, QuizGameState>> call({
    required QuizGameState currentState,
    required String selectedAnswer,
  }) async {
    // Validation: game must be playing
    if (!currentState.gameStatus.isPlaying) {
      return Left(GameLogicFailure('Game is not in progress'));
    }

    // Validation: must have current question
    final currentQuestion = currentState.currentQuestion;
    if (currentQuestion == null) {
      return Left(GameLogicFailure('No current question'));
    }

    // Check if answer is correct
    final isCorrect = currentQuestion.isCorrectAnswer(selectedAnswer);

    // Update state based on answer
    if (isCorrect) {
      // Correct: add timeLeft to score
      return Right(currentState.copyWith(
        score: currentState.score + currentState.timeLeft,
        currentAnswerState: AnswerState.correct,
      ));
    } else {
      // Incorrect: lose 1 life
      final newLives = currentState.lives - 1;
      return Right(currentState.copyWith(
        lives: newLives,
        currentAnswerState: AnswerState.incorrect,
        gameStatus: newLives <= 0 ? QuizGameStatus.gameOver : currentState.gameStatus,
      ));
    }
  }
}
