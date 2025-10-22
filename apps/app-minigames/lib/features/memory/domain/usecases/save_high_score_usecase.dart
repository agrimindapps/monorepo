import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/high_score_entity.dart';
import '../repositories/memory_repository.dart';

class SaveHighScoreUseCase {
  final MemoryRepository _repository;

  SaveHighScoreUseCase(this._repository);

  Future<Either<Failure, void>> call(HighScoreEntity highScore) async {
    if (highScore.score < 0) {
      return const Left(ValidationFailure('Score cannot be negative'));
    }

    if (highScore.moves < 0) {
      return const Left(ValidationFailure('Moves cannot be negative'));
    }

    return await _repository.saveHighScore(highScore);
  }
}
