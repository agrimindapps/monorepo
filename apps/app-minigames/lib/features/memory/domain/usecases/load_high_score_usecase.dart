import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/high_score_entity.dart';
import '../repositories/memory_repository.dart';

class LoadHighScoreParams {
  final GameDifficulty difficulty;

  const LoadHighScoreParams({required this.difficulty});
}

class LoadHighScoreUseCase {
  final MemoryRepository _repository;

  LoadHighScoreUseCase(this._repository);

  Future<Either<Failure, HighScoreEntity>> call(
    LoadHighScoreParams params,
  ) async {
    return await _repository.loadHighScore(params.difficulty);
  }
}
