import 'package:core/core.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case for starting a new game
class StartNewGameUseCase {
  const StartNewGameUseCase();

  Future<Either<Failure, GameState>> call({
    Difficulty difficulty = Difficulty.beginner,
    GameConfig? customConfig,
  }) async {
    // Validation for custom config
    if (difficulty == Difficulty.custom && customConfig == null) {
      return const Left(
        ValidationFailure('Configuração personalizada é obrigatória para modo custom'),
      );
    }

    if (customConfig != null) {
      if (customConfig.rows < 5 || customConfig.rows > 50) {
        return const Left(
          ValidationFailure('Número de linhas deve estar entre 5 e 50'),
        );
      }

      if (customConfig.cols < 5 || customConfig.cols > 50) {
        return const Left(
          ValidationFailure('Número de colunas deve estar entre 5 e 50'),
        );
      }

      final maxMines = customConfig.safeCells - 1;
      if (customConfig.mines < 1 || customConfig.mines >= customConfig.safeCells) {
        return Left(
          ValidationFailure('Número de minas deve estar entre 1 e $maxMines'),
        );
      }
    }

    return Right(
      GameState.initial(
        difficulty: difficulty,
        customConfig: customConfig,
      ),
    );
  }
}
