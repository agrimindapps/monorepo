import '../entities/frogger_score.dart';
import '../repositories/i_frogger_score_repository.dart';

class GetHighScoresUseCase {
  final IFroggerScoreRepository repository;

  GetHighScoresUseCase(this.repository);

  Future<List<FroggerScore>> call({int limit = 10}) async {
    final scores = await repository.getScores();
    return scores.take(limit).toList();
  }
}
