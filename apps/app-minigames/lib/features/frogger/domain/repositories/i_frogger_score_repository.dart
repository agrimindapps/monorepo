import '../entities/frogger_score.dart';

abstract class IFroggerScoreRepository {
  Future<List<FroggerScore>> getScores();
  Future<void> saveScore(FroggerScore score);
  Future<void> deleteScore(FroggerScore score);
  Future<void> clearAllScores();
}
