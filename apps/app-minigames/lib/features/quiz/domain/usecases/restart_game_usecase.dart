// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to restart the game
class RestartGameUseCase {
  RestartGameUseCase();

  /// Execute the use case
  /// Resets to initial loading state
  Future<Either<Failure, QuizGameState>> call({
    required QuizDifficulty difficulty,
  }) async {
    // Return to initial loading state
    return Right(QuizGameState.initial(difficulty: difficulty));
  }
}
