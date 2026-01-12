import '../entities/simon_score.dart';
import '../repositories/i_simon_score_repository.dart';

class GetHighScoresUseCase {
  final ISimonScoreRepository _repository;

  GetHighScoresUseCase(this._repository);

  Future<List<SimonScore>> call({int limit = 10}) async {
    return _repository.getTopScores(limit: limit);
  }
}
