import '../../domain/entities/connect_four_score.dart';
import '../../domain/repositories/i_connect_four_score_repository.dart';
import '../datasources/local/connect_four_local_datasource.dart';
import '../models/connect_four_score_model.dart';

class ConnectFourScoreRepositoryImpl implements IConnectFourScoreRepository {
  final ConnectFourLocalDatasource _datasource;

  ConnectFourScoreRepositoryImpl(this._datasource);

  @override
  Future<List<ConnectFourScore>> getScores() async {
    return await _datasource.getScores();
  }

  @override
  Future<void> saveScore(ConnectFourScore score) async {
    final model = ConnectFourScoreModel.fromEntity(score);
    await _datasource.saveScore(model);
  }

  @override
  Future<void> deleteScore(ConnectFourScore score) async {
    final model = ConnectFourScoreModel.fromEntity(score);
    await _datasource.deleteScore(model);
  }

  @override
  Future<void> clearAllScores() async {
    await _datasource.clearAllScores();
  }
}
