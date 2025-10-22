import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case for changing game difficulty
/// Updates difficulty and recalculates speed
@injectable
class ChangeDifficultyUseCase {
  ChangeDifficultyUseCase();

  Either<Failure, GameState> call({
    required GameState currentState,
    required GameDifficulty difficulty,
  }) {
    // Recalculate block speed based on new difficulty
    // Preserve current speed progression relative to difficulty
    final baseSpeed = 5.0;
    final currentSpeedRatio =
        currentState.blockSpeed / (baseSpeed * currentState.difficulty.speedMultiplier);
    final newSpeed = baseSpeed * difficulty.speedMultiplier * currentSpeedRatio;

    return Right(currentState.copyWith(
      difficulty: difficulty,
      blockSpeed: newSpeed,
    ));
  }
}
