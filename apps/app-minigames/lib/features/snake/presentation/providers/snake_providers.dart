import 'package:flutter_riverpod/flutter_riverpod.dart';
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
SnakeLocalDataSource snakeLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SnakeLocalDataSourceImpl(prefs);
}

@Riverpod(keepAlive: true)
SnakeRepository snakeRepository(Ref ref) {
  final dataSource = ref.watch(snakeLocalDataSourceProvider);
  return SnakeRepositoryImpl(dataSource);
}

@riverpod
CollisionDetectionService collisionDetectionService(Ref ref) =>
    CollisionDetectionService();

@riverpod
FoodGeneratorService foodGeneratorService(Ref ref) =>
    FoodGeneratorService();

@riverpod
GameStateManagerService gameStateManagerService(Ref ref) =>
    GameStateManagerService();

@riverpod
SnakeMovementService snakeMovementService(Ref ref) =>
    SnakeMovementService();

@riverpod
ChangeDifficultyUseCase changeDifficultyUseCase(Ref ref) {
  return ChangeDifficultyUseCase();
}

@riverpod
ChangeDirectionUseCase changeDirectionUseCase(Ref ref) =>
    ChangeDirectionUseCase();

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(snakeRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(snakeRepositoryProvider);
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
UpdateSnakePositionUseCase updateSnakePositionUseCase(Ref ref) {
  final movement = ref.watch(snakeMovementServiceProvider);
  final collision = ref.watch(collisionDetectionServiceProvider);
  final foodGenerator = ref.watch(foodGeneratorServiceProvider);
  return UpdateSnakePositionUseCase(
      foodGenerator, movement, collision);
}
