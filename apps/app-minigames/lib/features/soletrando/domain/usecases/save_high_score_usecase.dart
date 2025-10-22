import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/high_score_entity.dart';
import '../repositories/soletrando_repository.dart';

/// Parameters for saving high score
class SaveHighScoreParams {
  final int score;
  final int wordsCompleted;
  final GameDifficulty difficulty;

  const SaveHighScoreParams({
    required this.score,
    required this.wordsCompleted,
    required this.difficulty,
  });
}

/// Use case to save high score
class SaveHighScoreUseCase {
  final SoletrandoRepository repository;

  SaveHighScoreUseCase(this.repository);

  Future<Either<Failure, void>> call(SaveHighScoreParams params) async {
    // Validation: score must be positive
    if (params.score <= 0) {
      return const Left(
        ValidationFailure('Pontuação deve ser maior que zero'),
      );
    }

    // Validation: words completed must be non-negative
    if (params.wordsCompleted < 0) {
      return const Left(
        ValidationFailure('Palavras completadas não pode ser negativo'),
      );
    }

    // Create high score entity
    final highScore = HighScoreEntity(
      score: params.score,
      wordsCompleted: params.wordsCompleted,
      difficulty: params.difficulty,
      achievedAt: DateTime.now(),
    );

    // Load existing high scores to compare
    final loadResult = await repository.loadHighScores();

    return loadResult.fold(
      (failure) {
        // If can't load existing scores, still try to save
        return repository.saveHighScore(highScore);
      },
      (existingScores) {
        final currentBest = existingScores.getForDifficulty(params.difficulty);

        // Only save if new score is better
        if (highScore.isBetterThan(currentBest)) {
          return repository.saveHighScore(highScore);
        } else {
          // Not a new high score, return success without saving
          return const Right(null);
        }
      },
    );
  }
}
