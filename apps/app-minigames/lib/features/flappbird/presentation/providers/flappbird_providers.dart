import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/flappbird_local_datasource.dart';
import '../../data/repositories/flappbird_repository_impl.dart';
import '../../domain/repositories/flappbird_repository.dart';
import '../../domain/services/collision_service.dart';
import '../../domain/services/physics_service.dart';
import '../../domain/services/pipe_generator_service.dart';
import '../../domain/usecases/check_collision_usecase.dart';
import '../../domain/usecases/flap_bird_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/update_physics_usecase.dart';
import '../../domain/usecases/update_pipes_usecase.dart';

part 'flappbird_providers.g.dart';

// Data Sources

@riverpod
FlappbirdLocalDataSource flappbirdLocalDataSource(
  FlappbirdLocalDataSourceRef ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FlappbirdLocalDataSource(prefs);
}

// Repositories

@Riverpod(keepAlive: true)
FlappbirdRepository flappbirdRepository(FlappbirdRepositoryRef ref) {
  final dataSource = ref.watch(flappbirdLocalDataSourceProvider);
  return FlappbirdRepositoryImpl(dataSource);
}

// Services

@riverpod
PhysicsService physicsService(PhysicsServiceRef ref) {
  return PhysicsService();
}

@riverpod
PipeGeneratorService pipeGeneratorService(PipeGeneratorServiceRef ref) {
  return PipeGeneratorService();
}

@riverpod
CollisionService collisionService(CollisionServiceRef ref) {
  return CollisionService();
}

// Use Cases

@riverpod
StartGameUseCase startGameUseCase(StartGameUseCaseRef ref) {
  final physicsService = ref.watch(physicsServiceProvider);
  final pipeGeneratorService = ref.watch(pipeGeneratorServiceProvider);
  return StartGameUseCase(physicsService, pipeGeneratorService);
}

@riverpod
FlapBirdUseCase flapBirdUseCase(FlapBirdUseCaseRef ref) {
  return FlapBirdUseCase();
}

@riverpod
UpdatePhysicsUseCase updatePhysicsUseCase(UpdatePhysicsUseCaseRef ref) {
  final physicsService = ref.watch(physicsServiceProvider);
  final collisionService = ref.watch(collisionServiceProvider);
  return UpdatePhysicsUseCase(physicsService, collisionService);
}

@riverpod
UpdatePipesUseCase updatePipesUseCase(UpdatePipesUseCaseRef ref) {
  return UpdatePipesUseCase();
}

@riverpod
CheckCollisionUseCase checkCollisionUseCase(CheckCollisionUseCaseRef ref) {
  final collisionService = ref.watch(collisionServiceProvider);
  return CheckCollisionUseCase(collisionService);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(flappbirdRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(flappbirdRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}
