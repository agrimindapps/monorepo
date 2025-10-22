import 'package:core/core.dart';
import '../entities/game_state.dart';

/// Use case for updating game timer
class UpdateTimerUseCase {
  static const int maxTime = 999 * 60 + 59; // 999:59

  const UpdateTimerUseCase();

  Future<Either<Failure, GameState>> call({
    required GameState currentState,
  }) async {
    if (!currentState.isPlaying || currentState.isPaused) {
      return Right(currentState);
    }

    if (currentState.timeSeconds >= maxTime) {
      return Right(currentState);
    }

    return Right(
      currentState.copyWith(
        timeSeconds: currentState.timeSeconds + 1,
      ),
    );
  }
}
