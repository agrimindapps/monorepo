import 'package:riverpod_annotation/riverpod_annotation.dart';

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
Game2048LocalDataSource game2048LocalDataSource(Ref ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return Game2048LocalDataSource(sharedPrefs);
}

// =========================================================================
// REPOSITORIES
// =========================================================================

@riverpod
Game2048Repository game2048Repository(Ref ref) {
  final dataSource = ref.watch(game2048LocalDataSourceProvider);
  return Game2048RepositoryImpl(dataSource);
}

// =========================================================================
// USE CASES
// =========================================================================

@riverpod
MoveTilesUseCase moveTilesUseCase(Ref ref) {
  return MoveTilesUseCase();
}

@riverpod
SpawnTileUseCase spawnTileUseCase(Ref ref) {
  return SpawnTileUseCase();
}

@riverpod
CheckGameOverUseCase checkGameOverUseCase(Ref ref) {
  return CheckGameOverUseCase();
}

@riverpod
RestartGameUseCase restartGameUseCase(Ref ref) {
  final spawnTile = ref.watch(spawnTileUseCaseProvider);
  return RestartGameUseCase(spawnTile);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(game2048RepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(game2048RepositoryProvider);
  return SaveHighScoreUseCase(repository);
}
