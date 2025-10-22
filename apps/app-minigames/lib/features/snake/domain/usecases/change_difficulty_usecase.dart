// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to change difficulty
@injectable
class ChangeDifficultyUseCase {
  ChangeDifficultyUseCase();

  /// Execute the use case
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
    required SnakeDifficulty newDifficulty,
  }) async {
    return Right(currentState.copyWith(difficulty: newDifficulty));
  }
}
