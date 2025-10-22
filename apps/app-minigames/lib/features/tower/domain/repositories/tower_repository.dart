import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/high_score.dart';

/// Repository interface for Tower game data operations
abstract class TowerRepository {
  /// Loads the high score from local storage
  Future<Either<Failure, HighScore>> getHighScore();

  /// Saves the high score to local storage
  Future<Either<Failure, void>> saveHighScore(int score);
}
