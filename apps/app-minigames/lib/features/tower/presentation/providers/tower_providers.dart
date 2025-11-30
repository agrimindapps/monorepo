import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/tower_local_data_source.dart';
import '../../data/repositories/tower_repository_impl.dart';
import '../../domain/repositories/tower_repository.dart';
import '../../domain/services/block_generation_service.dart';
import '../../domain/services/overlap_calculation_service.dart';
import '../../domain/services/physics_service.dart';
import '../../domain/services/scoring_service.dart';
import '../../domain/usecases/change_difficulty_usecase.dart';
import '../../domain/usecases/drop_block_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/start_new_game_usecase.dart';
import '../../domain/usecases/toggle_pause_usecase.dart';
import '../../domain/usecases/update_moving_block_usecase.dart';

part 'tower_providers.g.dart';

@riverpod
TowerLocalDataSource towerLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TowerLocalDataSourceImpl(prefs);
}

@Riverpod(keepAlive: true)
TowerRepository towerRepository(Ref ref) {
  final dataSource = ref.watch(towerLocalDataSourceProvider);
  return TowerRepositoryImpl(dataSource);
}

@riverpod
BlockGenerationService blockGenerationService(Ref ref) =>
    BlockGenerationService();

@riverpod
OverlapCalculationService overlapCalculationService(Ref ref) =>
    OverlapCalculationService();

@riverpod
PhysicsService physicsService(Ref ref) => PhysicsService();

@riverpod
ScoringService scoringService(Ref ref) => ScoringService();

@riverpod
ChangeDifficultyUseCase changeDifficultyUseCase(Ref ref) {
  final physics = ref.watch(physicsServiceProvider);
  return ChangeDifficultyUseCase(physics);
}

@riverpod
DropBlockUseCase dropBlockUseCase(Ref ref) {
  final overlap = ref.watch(overlapCalculationServiceProvider);
  final scoring = ref.watch(scoringServiceProvider);
  final physics = ref.watch(physicsServiceProvider);
  final blockGen = ref.watch(blockGenerationServiceProvider);
  return DropBlockUseCase(overlap, scoring, physics, blockGen);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(towerRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(towerRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
StartNewGameUseCase startNewGameUseCase(Ref ref) {
  return StartNewGameUseCase();
}

@riverpod
TogglePauseUseCase togglePauseUseCase(Ref ref) =>
    TogglePauseUseCase();

@riverpod
UpdateMovingBlockUseCase updateMovingBlockUseCase(Ref ref) {
  final physics = ref.watch(physicsServiceProvider);
  return UpdateMovingBlockUseCase(physics);
}
