import '../entities/space_invaders_score.dart';

abstract class ISpaceInvadersScoreRepository {
  Future<void> saveScore(SpaceInvadersScore score);
  Future<List<SpaceInvadersScore>> getAllScores();
  Future<List<SpaceInvadersScore>> getTopScores({int limit = 10});
  Future<void> deleteScore(String id);
  Future<void> deleteAllScores();
}
