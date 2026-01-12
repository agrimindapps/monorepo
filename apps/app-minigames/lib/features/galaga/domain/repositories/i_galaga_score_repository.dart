import '../entities/galaga_score.dart';

abstract class IGalagaScoreRepository {
  Future<List<GalagaScore>> getScores();
  Future<void> saveScore(GalagaScore score);
  Future<void> deleteScore(GalagaScore score);
  Future<void> clearAllScores();
}
