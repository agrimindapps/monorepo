import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/game_2048_local_datasource.dart';
import '../data/repositories/game_2048_repository_impl.dart';
import '../domain/repositories/game_2048_repository.dart';
import '../domain/usecases/check_game_over_usecase.dart';
import '../domain/usecases/load_high_score_usecase.dart';
import '../domain/usecases/move_tiles_usecase.dart';
import '../domain/usecases/restart_game_usecase.dart';
import '../domain/usecases/save_high_score_usecase.dart';
import '../domain/usecases/spawn_tile_usecase.dart';

/// Initializes dependency injection for Game 2048 feature
Future<void> initGame2048DI(GetIt sl) async {
  // =========================================================================
  // DATA SOURCES
  // =========================================================================
  sl.registerLazySingleton<Game2048LocalDataSource>(
    () => Game2048LocalDataSource(sl<SharedPreferences>()),
  );

  // =========================================================================
  // REPOSITORIES
  // =========================================================================
  sl.registerLazySingleton<Game2048Repository>(
    () => Game2048RepositoryImpl(sl<Game2048LocalDataSource>()),
  );

  // =========================================================================
  // USE CASES
  // =========================================================================
  sl.registerLazySingleton(() => MoveTilesUseCase());

  sl.registerLazySingleton(() => SpawnTileUseCase());

  sl.registerLazySingleton(() => CheckGameOverUseCase());

  sl.registerLazySingleton(
    () => RestartGameUseCase(sl<SpawnTileUseCase>()),
  );

  sl.registerLazySingleton(
    () => LoadHighScoreUseCase(sl<Game2048Repository>()),
  );

  sl.registerLazySingleton(
    () => SaveHighScoreUseCase(sl<Game2048Repository>()),
  );
}
