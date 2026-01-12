import '../entities/dino_run_score.dart';

abstract class IDinoRunScoreRepository {
  Future<List<DinoRunScore>> getScores();
  Future<void> saveScore(DinoRunScore score);
  Future<void> deleteScore(DinoRunScore score);
  Future<void> clearAllScores();
}
