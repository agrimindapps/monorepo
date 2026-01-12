import '../entities/damas_score.dart';
import '../repositories/i_damas_score_repository.dart';

class GetHighScoresUseCase {
  final IDamasScoreRepository repository;

  GetHighScoresUseCase(this.repository);

  Future<List<DamasScore>> call() async {
    return repository.getScores();
  }
}
