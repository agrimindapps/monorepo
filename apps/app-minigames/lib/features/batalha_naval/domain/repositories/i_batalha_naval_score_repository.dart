import '../entities/batalha_naval_score.dart';

abstract class IBatalhaNavalScoreRepository {
  Future<List<BatalhaNavalScore>> getHighScores();
  Future<void> saveScore(BatalhaNavalScore score);
  Future<void> deleteScore(BatalhaNavalScore score);
}
