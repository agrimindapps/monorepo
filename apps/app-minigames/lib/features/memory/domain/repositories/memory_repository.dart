import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/high_score_entity.dart';

abstract class MemoryRepository {
  Future<Either<Failure, HighScoreEntity>> loadHighScore(
    GameDifficulty difficulty,
  );

  Future<Either<Failure, void>> saveHighScore(
    HighScoreEntity highScore,
  );

  Future<Either<Failure, Map<String, dynamic>>> loadGameConfig();

  Future<Either<Failure, void>> saveGameConfig(
    Map<String, dynamic> config,
  );

  Future<Either<Failure, void>> clearAllData();
}
