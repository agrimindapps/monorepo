import '../../domain/entities/batalha_naval_score.dart';
import '../../domain/repositories/i_batalha_naval_score_repository.dart';
import '../datasources/local/batalha_naval_local_datasource.dart';
import '../models/batalha_naval_score_model.dart';

class BatalhaNavalScoreRepositoryImpl implements IBatalhaNavalScoreRepository {
  final BatalhaNavalLocalDatasource localDatasource;

  BatalhaNavalScoreRepositoryImpl(this.localDatasource);

  @override
  Future<List<BatalhaNavalScore>> getHighScores() async {
    return await localDatasource.getHighScores();
  }

  @override
  Future<void> saveScore(BatalhaNavalScore score) async {
    await localDatasource.saveScore(BatalhaNavalScoreModel.fromEntity(score));
  }

  @override
  Future<void> deleteScore(BatalhaNavalScore score) async {
    await localDatasource.deleteScore(BatalhaNavalScoreModel.fromEntity(score));
  }
}
