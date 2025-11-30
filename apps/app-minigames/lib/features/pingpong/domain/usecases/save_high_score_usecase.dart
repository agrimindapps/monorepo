import 'package:core/core.dart';
import '../entities/high_score_entity.dart';
import '../repositories/pingpong_repository.dart';

class SaveHighScoreUseCase {
  final PingpongRepository repository;

  SaveHighScoreUseCase(this.repository);

  Future<Either<Failure, void>> call(HighScoreEntity highScore) async {
    try {
      if (highScore.score <= 0) {
        return const Left(ValidationFailure('Score must be greater than 0'));
      }

      return await repository.saveHighScore(highScore);
    } catch (e) {
      return Left(CacheFailure('Failed to save high score: $e'));
    }
  }
}
