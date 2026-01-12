import '../entities/asteroids_score.dart';

abstract class IAsteroidsScoreRepository {
  Future<List<AsteroidsScore>> getScores();
  Future<void> saveScore(AsteroidsScore score);
  Future<void> deleteScore(AsteroidsScore score);
  Future<void> clearAllScores();
}
