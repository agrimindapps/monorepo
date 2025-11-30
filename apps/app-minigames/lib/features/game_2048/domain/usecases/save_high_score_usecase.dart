import 'package:core/core.dart';

import '../entities/high_score_entity.dart';
import '../repositories/game_2048_repository.dart';

/// Saves high score to storage
class SaveHighScoreUseCase {
  final Game2048Repository _repository;

  SaveHighScoreUseCase(this._repository);

  /// Saves high score if it's better than existing one
  Future<Either<Failure, bool>> call(
    HighScoreEntity newScore,
    HighScoreEntity currentBest,
  ) async {
    try {
      // Validation
      if (newScore.score < 0) {
        return const Left(ValidationFailure('Score cannot be negative'));
      }

      if (newScore.moves < 0) {
        return const Left(ValidationFailure('Moves cannot be negative'));
      }

      // Check if new score is better
      if (!newScore.isBetterThan(currentBest)) {
        return const Right(false); // Not a new high score
      }

      // Save new high score
      final result = await _repository.saveHighScore(newScore);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true), // Successfully saved new high score
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
