import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/snake_local_data_source.dart';
import '../../data/repositories/snake_repository_impl.dart';
import '../../domain/repositories/snake_repository.dart';
import '../../domain/services/collision_detection_service.dart';
import '../../domain/services/food_generator_service.dart';
import '../../domain/services/game_state_manager_service.dart';
import '../../domain/services/snake_movement_service.dart';
import '../../domain/usecases/change_difficulty_usecase.dart';
import '../../domain/usecases/change_direction_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/start_new_game_usecase.dart';
import '../../domain/usecases/toggle_pause_usecase.dart';
import '../../domain/usecases/update_snake_position_usecase.dart';

part 'snake_providers.g.dart';

@riverpod
SnakeLocalDataSource snakeLocalDataSource(SnakeLocalDataSourceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SnakeLocalDataSourceImpl(prefs);
}

@Riverpod(keepAlive: true)
SnakeRepository snakeRepository(SnakeRepositoryRef ref) {
  final dataSource = ref.watch(snakeLocalDataSourceProvider);
  return SnakeRepositoryImpl(dataSource);
}

@riverpod
CollisionDetectionService collisionDetectionService(
        CollisionDetectionServiceRef ref) =>
    CollisionDetectionService();

@riverpod
FoodGeneratorService foodGeneratorService(FoodGeneratorServiceRef ref) =>
    FoodGeneratorService();

@riverpod
GameStateManagerService gameStateManagerService(
        GameStateManagerServiceRef ref) =>
    GameStateManagerService();

@riverpod
SnakeMovementService snakeMovementService(SnakeMovementServiceRef ref) =>
    SnakeMovementService();

@riverpod
ChangeDifficultyUseCase changeDifficultyUseCase(
    ChangeDifficultyUseCaseRef ref) {
  final repository = ref.watch(snakeRepositoryProvider);
  return ChangeDifficultyUseCase(repository);
}

@riverpod
ChangeDirectionUseCase changeDirectionUseCase(ChangeDirectionUseCaseRef ref) =>
    ChangeDirectionUseCase();

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(snakeRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(snakeRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
StartNewGameUseCase startNewGameUseCase(StartNewGameUseCaseRef ref) {
  final foodGenerator = ref.watch(foodGeneratorServiceProvider);
  return StartNewGameUseCase(foodGenerator);
}

@riverpod
TogglePauseUseCase togglePauseUseCase(TogglePauseUseCaseRef ref) =>
    TogglePauseUseCase();

@riverpod
UpdateSnakePositionUseCase updateSnakePositionUseCase(
    UpdateSnakePositionUseCaseRef ref) {
  final movement = ref.watch(snakeMovementServiceProvider);
  final collision = ref.watch(collisionDetectionServiceProvider);
  final foodGenerator = ref.watch(foodGeneratorServiceProvider);
  final gameState = ref.watch(gameStateManagerServiceProvider);
  return UpdateSnakePositionUseCase(
      movement, collision, foodGenerator, gameState);
}
