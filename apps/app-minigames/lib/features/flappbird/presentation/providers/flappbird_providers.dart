import 'package:flutter_riverpod/flutter_riverpod.dart';
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
FlappbirdLocalDataSource flappbirdLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FlappbirdLocalDataSource(prefs);
}

// Repositories

@Riverpod(keepAlive: true)
FlappbirdRepository flappbirdRepository(Ref ref) {
  final dataSource = ref.watch(flappbirdLocalDataSourceProvider);
  return FlappbirdRepositoryImpl(dataSource);
}

// Services

@riverpod
PhysicsService physicsService(Ref ref) {
  return PhysicsService();
}

@riverpod
PipeGeneratorService pipeGeneratorService(Ref ref) {
  return PipeGeneratorService();
}

@riverpod
CollisionService collisionService(Ref ref) {
  return CollisionService();
}

// Use Cases

@riverpod
StartGameUseCase startGameUseCase(Ref ref) {
  final physicsService = ref.watch(physicsServiceProvider);
  final pipeGeneratorService = ref.watch(pipeGeneratorServiceProvider);
  return StartGameUseCase(physicsService, pipeGeneratorService);
}

@riverpod
FlapBirdUseCase flapBirdUseCase(Ref ref) {
  return FlapBirdUseCase();
}

@riverpod
UpdatePhysicsUseCase updatePhysicsUseCase(Ref ref) {
  final physicsService = ref.watch(physicsServiceProvider);
  final collisionService = ref.watch(collisionServiceProvider);
  return UpdatePhysicsUseCase(physicsService, collisionService);
}

@riverpod
UpdatePipesUseCase updatePipesUseCase(Ref ref) {
  return UpdatePipesUseCase();
}

@riverpod
CheckCollisionUseCase checkCollisionUseCase(Ref ref) {
  final collisionService = ref.watch(collisionServiceProvider);
  return CheckCollisionUseCase(collisionService);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(flappbirdRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(flappbirdRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}
