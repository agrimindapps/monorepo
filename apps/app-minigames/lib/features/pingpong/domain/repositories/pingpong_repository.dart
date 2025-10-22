import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/high_score_entity.dart';
import '../entities/enums.dart';

abstract class PingpongRepository {
  Future<Either<Failure, HighScoreEntity?>> getHighScore(
      GameDifficulty difficulty);
  Future<Either<Failure, void>> saveHighScore(HighScoreEntity highScore);
  Future<Either<Failure, void>> clearHighScores();
}
