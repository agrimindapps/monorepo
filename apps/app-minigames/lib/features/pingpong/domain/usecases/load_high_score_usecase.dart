import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/high_score_entity.dart';
import '../entities/enums.dart';
import '../repositories/pingpong_repository.dart';

class LoadHighScoreUseCase {
  final PingpongRepository repository;

  LoadHighScoreUseCase(this.repository);

  Future<Either<Failure, HighScoreEntity?>> call(
      GameDifficulty difficulty) async {
    try {
      return await repository.getHighScore(difficulty);
    } catch (e) {
      return Left(CacheFailure('Failed to load high score: $e'));
    }
  }
}
