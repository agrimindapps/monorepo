import '../entities/simon_score.dart';

abstract class ISimonScoreRepository {
  Future<void> saveScore(SimonScore score);
  Future<List<SimonScore>> getAllScores();
  Future<List<SimonScore>> getTopScores({int limit = 10});
  Future<List<SimonScore>> getTodayScores();
  Future<List<SimonScore>> getWeekScores();
  Future<void> deleteScore(String id);
  Future<void> deleteAllScores();
}
