import '../entities/asteroids_score.dart';
import '../repositories/i_asteroids_score_repository.dart';

class GetHighScoresUseCase {
  final IAsteroidsScoreRepository repository;

  GetHighScoresUseCase(this.repository);

  Future<List<AsteroidsScore>> call({int limit = 10}) async {
    final scores = await repository.getScores();
    return scores.take(limit).toList();
  }
}
