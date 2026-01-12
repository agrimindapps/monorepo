import '../entities/batalha_naval_score.dart';
import '../repositories/i_batalha_naval_score_repository.dart';

class GetHighScoresUseCase {
  final IBatalhaNavalScoreRepository repository;

  GetHighScoresUseCase(this.repository);

  Future<List<BatalhaNavalScore>> call() {
    return repository.getHighScores();
  }
}
