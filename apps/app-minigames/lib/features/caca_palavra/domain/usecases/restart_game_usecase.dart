import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';
import '../repositories/caca_palavra_repository.dart';
import 'generate_grid_usecase.dart';

/// Restarts the game with optional new difficulty
class RestartGameUseCase {
  final CacaPalavraRepository repository;
  final GenerateGridUseCase generateGridUseCase;

  RestartGameUseCase(this.repository, this.generateGridUseCase);

  Future<Either<Failure, GameState>> call({
    GameDifficulty? newDifficulty,
  }) async {
    try {
      GameDifficulty difficulty;

      if (newDifficulty != null) {
        difficulty = newDifficulty;
        // Save new difficulty preference
        await repository.saveDifficulty(difficulty);
      } else {
        // Load saved difficulty
        final difficultyResult = await repository.loadDifficulty();
        difficulty = difficultyResult.fold(
          (_) => GameDifficulty.medium, // Default on error
          (saved) => saved,
        );
      }

      // Generate new grid
      return await generateGridUseCase(difficulty: difficulty);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to restart game: ${e.toString()}'));
    }
  }
}
