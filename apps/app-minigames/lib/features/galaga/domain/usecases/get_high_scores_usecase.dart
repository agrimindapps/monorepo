import '../entities/galaga_score.dart';
import '../repositories/i_galaga_score_repository.dart';

class GetHighScoresUseCase {
  final IGalagaScoreRepository repository;

  GetHighScoresUseCase(this.repository);

  Future<List<GalagaScore>> call({int limit = 10}) async {
    final scores = await repository.getScores();
    return scores.take(limit).toList();
  }
}
