// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';
import '../entities/quiz_question.dart';

/// Use case to start a new game
@injectable
class StartGameUseCase {
  StartGameUseCase();

  /// Execute the use case
  /// Initializes game with questions
  Future<Either<Failure, QuizGameState>> call({
    required List<QuizQuestion> questions,
    required QuizDifficulty difficulty,
  }) async {
    // Validation: must have questions
    if (questions.isEmpty) {
      return Left(ValidationFailure('No questions provided'));
    }

    // Create initial playing state
    return Right(QuizGameState(
      questions: questions,
      currentQuestionIndex: 0,
      score: 0,
      lives: 3,
      timeLeft: difficulty.timeInSeconds,
      gameStatus: QuizGameStatus.playing,
      currentAnswerState: AnswerState.none,
      difficulty: difficulty,
    ));
  }
}
