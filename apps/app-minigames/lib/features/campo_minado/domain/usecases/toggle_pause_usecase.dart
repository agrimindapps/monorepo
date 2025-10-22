import 'package:core/core.dart';
import '../entities/game_state.dart';

/// Use case for toggling pause state
class TogglePauseUseCase {
  const TogglePauseUseCase();

  Future<Either<Failure, GameState>> call({
    required GameState currentState,
  }) async {
    if (currentState.isGameOver) {
      return const Left(ValidationFailure('Não é possível pausar jogo finalizado'));
    }

    return Right(
      currentState.copyWith(
        isPaused: !currentState.isPaused,
      ),
    );
  }
}
