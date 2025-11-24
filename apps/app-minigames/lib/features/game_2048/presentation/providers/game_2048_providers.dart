import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/game_2048_local_datasource.dart';
import '../../data/repositories/game_2048_repository_impl.dart';
import '../../domain/repositories/game_2048_repository.dart';
import '../../domain/usecases/check_game_over_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/move_tiles_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/spawn_tile_usecase.dart';
import '../../../../core/providers/core_providers.dart';

part 'game_2048_providers.g.dart';

// =========================================================================
// DATA SOURCES
// =========================================================================

@riverpod
Game2048LocalDataSource game2048LocalDataSource(
    Game2048LocalDataSourceRef ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return Game2048LocalDataSource(sharedPrefs);
}

// =========================================================================
// REPOSITORIES
// =========================================================================

@riverpod
Game2048Repository game2048Repository(Game2048RepositoryRef ref) {
  final dataSource = ref.watch(game2048LocalDataSourceProvider);
  return Game2048RepositoryImpl(dataSource);
}

// =========================================================================
// USE CASES
// =========================================================================

@riverpod
MoveTilesUseCase moveTilesUseCase(MoveTilesUseCaseRef ref) {
  return MoveTilesUseCase();
}

@riverpod
SpawnTileUseCase spawnTileUseCase(SpawnTileUseCaseRef ref) {
  return SpawnTileUseCase();
}

@riverpod
CheckGameOverUseCase checkGameOverUseCase(CheckGameOverUseCaseRef ref) {
  return CheckGameOverUseCase();
}

@riverpod
RestartGameUseCase restartGameUseCase(RestartGameUseCaseRef ref) {
  final spawnTile = ref.watch(spawnTileUseCaseProvider);
  return RestartGameUseCase(spawnTile);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(game2048RepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(game2048RepositoryProvider);
  return SaveHighScoreUseCase(repository);
}
