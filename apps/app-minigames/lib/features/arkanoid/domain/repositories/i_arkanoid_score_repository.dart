import '../entities/arkanoid_score.dart';

abstract class IArkanoidScoreRepository {
  Future<void> saveScore(ArkanoidScore score);
  Future<List<ArkanoidScore>> getAllScores();
  Future<List<ArkanoidScore>> getTopScores({int limit = 10});
  Future<void> deleteScore(String id);
  Future<void> deleteAllScores();
}
