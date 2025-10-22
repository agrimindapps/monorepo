import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tower_repository.dart';

/// Use case for saving high score
/// Only saves if new score is higher than current high score
@injectable
class SaveHighScoreUseCase {
  final TowerRepository repository;

  SaveHighScoreUseCase(this.repository);

  Future<Either<Failure, void>> call(int score) async {
    // Validate score
    if (score < 0) {
      return const Left(ValidationFailure('Score cannot be negative'));
    }

    // Load current high score
    final currentHighScoreResult = await repository.getHighScore();

    return await currentHighScoreResult.fold(
      // If load fails, save anyway (assume this is first score)
      (failure) async => await repository.saveHighScore(score),
      // If load succeeds, only save if new score is higher
      (currentHighScore) async {
        if (score > currentHighScore.score) {
          return await repository.saveHighScore(score);
        }
        return const Right(null);
      },
    );
  }
}
