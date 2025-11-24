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
TowerLocalDataSource towerLocalDataSource(TowerLocalDataSourceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TowerLocalDataSourceImpl(prefs);
}

@Riverpod(keepAlive: true)
TowerRepository towerRepository(TowerRepositoryRef ref) {
  final dataSource = ref.watch(towerLocalDataSourceProvider);
  return TowerRepositoryImpl(dataSource);
}

@riverpod
BlockGenerationService blockGenerationService(BlockGenerationServiceRef ref) =>
    BlockGenerationService();

@riverpod
OverlapCalculationService overlapCalculationService(
        OverlapCalculationServiceRef ref) =>
    OverlapCalculationService();

@riverpod
PhysicsService physicsService(PhysicsServiceRef ref) => PhysicsService();

@riverpod
ScoringService scoringService(ScoringServiceRef ref) => ScoringService();

@riverpod
ChangeDifficultyUseCase changeDifficultyUseCase(
    ChangeDifficultyUseCaseRef ref) {
  final repository = ref.watch(towerRepositoryProvider);
  return ChangeDifficultyUseCase(repository);
}

@riverpod
DropBlockUseCase dropBlockUseCase(DropBlockUseCaseRef ref) {
  final physics = ref.watch(physicsServiceProvider);
  final overlap = ref.watch(overlapCalculationServiceProvider);
  final scoring = ref.watch(scoringServiceProvider);
  return DropBlockUseCase(physics, overlap, scoring);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(towerRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(towerRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
StartNewGameUseCase startNewGameUseCase(StartNewGameUseCaseRef ref) {
  final blockGen = ref.watch(blockGenerationServiceProvider);
  return StartNewGameUseCase(blockGen);
}

@riverpod
TogglePauseUseCase togglePauseUseCase(TogglePauseUseCaseRef ref) =>
    TogglePauseUseCase();

@riverpod
UpdateMovingBlockUseCase updateMovingBlockUseCase(
    UpdateMovingBlockUseCaseRef ref) {
  final physics = ref.watch(physicsServiceProvider);
  return UpdateMovingBlockUseCase(physics);
}
