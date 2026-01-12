import '../entities/dino_run_score.dart';
import '../repositories/i_dino_run_score_repository.dart';

class GetHighScoresUseCase {
  final IDinoRunScoreRepository repository;

  GetHighScoresUseCase(this.repository);

  Future<List<DinoRunScore>> call({int limit = 10}) async {
    final scores = await repository.getScores();
    return scores.take(limit).toList();
  }
}
