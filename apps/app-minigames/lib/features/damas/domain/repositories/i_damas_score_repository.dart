import '../entities/damas_score.dart';

abstract class IDamasScoreRepository {
  Future<List<DamasScore>> getScores();
  Future<void> saveScore(DamasScore score);
  Future<void> deleteScore(DamasScore score);
  Future<void> clearAllScores();
}
