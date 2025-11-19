// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';
import '../services/answer_validation_service.dart';
import '../services/life_management_service.dart';

/// Use case to process answer selection
@injectable
class SelectAnswerUseCase {
  final AnswerValidationService _answerValidationService;
  final LifeManagementService _lifeManagementService;

  SelectAnswerUseCase(
    this._answerValidationService,
    this._lifeManagementService,
  );

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

    // Validate answer using service
    final validationResult = _answerValidationService.validateAnswer(
      question: currentQuestion,
      selectedAnswer: selectedAnswer,
      timeLeft: currentState.timeLeft,
      difficulty: currentState.difficulty,
    );

    if (validationResult.isCorrect) {
      // Correct: add score
      return Right(
        currentState.copyWith(
          score: currentState.score + validationResult.scoreEarned,
          currentAnswerState: AnswerState.correct,
        ),
      );
    } else {
      // Incorrect: deduct lives using service
      final lifeResult = _lifeManagementService.deductLivesForIncorrectAnswer(
        currentState.lives,
      );

      return Right(
        currentState.copyWith(
          lives: lifeResult.newLives,
          currentAnswerState: AnswerState.incorrect,
          gameStatus: lifeResult.isGameOver
              ? QuizGameStatus.gameOver
              : currentState.gameStatus,
        ),
      );
    }
  }
}
