// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to start a new game
@injectable
class StartNewGameUseCase {
  StartNewGameUseCase();

  /// Execute the use case
  /// Initializes game to running state
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeDifficulty difficulty,
    int gridSize = 20,
  }) async {
    // Create initial state and set to running
    final initialState = SnakeGameState.initial(
      gridSize: gridSize,
      difficulty: difficulty,
    );

    return Right(initialState.copyWith(gameStatus: SnakeGameStatus.running));
  }
}
