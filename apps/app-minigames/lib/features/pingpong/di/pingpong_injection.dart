import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/pingpong_local_datasource.dart';
import '../data/repositories/pingpong_repository_impl.dart';
import '../domain/repositories/pingpong_repository.dart';
import '../domain/usecases/load_high_score_usecase.dart';
import '../domain/usecases/save_high_score_usecase.dart';

@module
abstract class PingpongModule {
  @lazySingleton
  PingpongLocalDataSource pingpongLocalDataSource(
    SharedPreferences sharedPreferences,
  ) =>
      PingpongLocalDataSourceImpl(sharedPreferences);

  @lazySingleton
  PingpongRepository pingpongRepository(
    PingpongLocalDataSource dataSource,
  ) =>
      PingpongRepositoryImpl(dataSource);

  @lazySingleton
  LoadHighScoreUseCase loadHighScoreUseCase(PingpongRepository repository) =>
      LoadHighScoreUseCase(repository);

  @lazySingleton
  SaveHighScoreUseCase saveHighScoreUseCase(PingpongRepository repository) =>
      SaveHighScoreUseCase(repository);
}
