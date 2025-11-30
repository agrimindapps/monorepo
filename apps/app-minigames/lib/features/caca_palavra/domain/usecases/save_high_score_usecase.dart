import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/high_score.dart';
import '../repositories/caca_palavra_repository.dart';

/// Saves high score if it's a new record
class SaveHighScoreUseCase {
  final CacaPalavraRepository repository;

  SaveHighScoreUseCase(this.repository);

  Future<Either<Failure, HighScore>> call({
    required GameDifficulty difficulty,
    required int completionTime,
  }) async {
    try {
      // Validation
      if (completionTime <= 0) {
        return const Left(ValidationFailure('Completion time must be positive'));
      }

      // Load current high score
      final currentResult = await repository.loadHighScore();

      return await currentResult.fold(
        (failure) => Left(failure),
        (currentScore) async {
          final currentFastest = currentScore.getFastest(difficulty);

          // Check if new record (0 means no previous record)
          if (currentFastest == 0 || completionTime < currentFastest) {
            final updatedScore = currentScore.updateFastest(
              difficulty,
              completionTime,
            );

            final saveResult = await repository.saveHighScore(updatedScore);

            return saveResult.fold(
              (failure) => Left(failure),
              (_) => Right(updatedScore),
            );
          }

          // Not a new record
          return Right(currentScore);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to save high score: ${e.toString()}'));
    }
  }
}
