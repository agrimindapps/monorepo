import '../entities/connect_four_score.dart';

abstract class IConnectFourScoreRepository {
  Future<List<ConnectFourScore>> getScores();
  Future<void> saveScore(ConnectFourScore score);
  Future<void> deleteScore(ConnectFourScore score);
  Future<void> clearAllScores();
}
