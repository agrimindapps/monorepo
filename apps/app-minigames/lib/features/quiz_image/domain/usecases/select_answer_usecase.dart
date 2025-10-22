import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Use case that handles answer selection for current question
/// Validates answer, checks correctness, and updates score
@injectable
class SelectAnswerUseCase {
  SelectAnswerUseCase();

  Either<Failure, QuizGameState> call({
    required QuizGameState currentState,
    required String selectedAnswer,
  }) {
    // Validate game is playing
    if (currentState.gameState != GameStateEnum.playing) {
      return const Left(GameLogicFailure('Game is not in playing state'));
    }

    // Validate question hasn't already been answered
    if (currentState.currentAnswerState != AnswerState.unanswered) {
      return const Left(GameLogicFailure('Question already answered'));
    }

    // Validate selected answer is one of the options
    if (!currentState.currentQuestion.options.contains(selectedAnswer)) {
      return const Left(ValidationFailure('Invalid answer option'));
    }

    // Check if answer is correct
    final isCorrect = currentState.currentQuestion.isCorrect(selectedAnswer);
    final newAnswerState =
        isCorrect ? AnswerState.correct : AnswerState.incorrect;
    final newCorrectAnswers =
        isCorrect ? currentState.correctAnswers + 1 : currentState.correctAnswers;

    return Right(
      currentState.copyWith(
        currentSelectedAnswer: selectedAnswer,
        currentAnswerState: newAnswerState,
        correctAnswers: newCorrectAnswers,
      ),
    );
  }
}
