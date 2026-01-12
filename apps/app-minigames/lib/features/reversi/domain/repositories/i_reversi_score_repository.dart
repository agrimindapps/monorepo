import '../entities/reversi_score.dart';

abstract class IReversiScoreRepository {
  Future<void> saveScore(ReversiScore score);
  Future<List<ReversiScore>> getAllScores();
  Future<List<ReversiScore>> getTopScores({int limit = 10});
  Future<List<ReversiScore>> getTodayScores();
  Future<void> deleteScore(String id);
  Future<void> deleteAllScores();
}
