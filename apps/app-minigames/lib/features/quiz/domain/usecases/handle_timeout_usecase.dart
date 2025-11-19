// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';
import '../services/life_management_service.dart';

/// Use case to handle question timeout
@injectable
class HandleTimeoutUseCase {
  final LifeManagementService _lifeManagementService;

  HandleTimeoutUseCase(this._lifeManagementService);

  /// Execute the use case
  /// Timeout = lose 1 life
  Future<Either<Failure, QuizGameState>> call({
    required QuizGameState currentState,
  }) async {
    // Validation: game must be playing
    if (!currentState.gameStatus.isPlaying) {
      return Left(GameLogicFailure('Game is not in progress'));
    }

    // Timeout: deduct lives using service
    final lifeResult = _lifeManagementService.deductLivesForTimeout(
      currentState.lives,
    );

    return Right(
      currentState.copyWith(
        lives: lifeResult.newLives,
        timeLeft: 0,
        currentAnswerState: AnswerState.incorrect,
        gameStatus: lifeResult.isGameOver
            ? QuizGameStatus.gameOver
            : currentState.gameStatus,
      ),
    );
  }
}
