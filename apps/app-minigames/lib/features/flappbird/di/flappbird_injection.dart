// Package imports:
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Domain imports:
import '../domain/repositories/flappbird_repository.dart';
import '../domain/usecases/start_game_usecase.dart';
import '../domain/usecases/flap_bird_usecase.dart';
import '../domain/usecases/update_physics_usecase.dart';
import '../domain/usecases/update_pipes_usecase.dart';
import '../domain/usecases/check_collision_usecase.dart';
import '../domain/usecases/load_high_score_usecase.dart';
import '../domain/usecases/save_high_score_usecase.dart';
import '../domain/services/physics_service.dart';
import '../domain/services/pipe_generator_service.dart';
import '../domain/services/collision_service.dart';

// Data imports:
import '../data/datasources/flappbird_local_datasource.dart';
import '../data/repositories/flappbird_repository_impl.dart';

@module
abstract class FlappbirdModule {
  // Data sources
  FlappbirdLocalDataSource flappbirdLocalDataSource(SharedPreferences prefs) =>
      FlappbirdLocalDataSource(prefs);

  // Repositories
  @Singleton(as: FlappbirdRepository)
  FlappbirdRepositoryImpl flappbirdRepository(
    FlappbirdLocalDataSource dataSource,
  ) => FlappbirdRepositoryImpl(dataSource);

  // Services are already registered as @lazySingleton, no need to register here

  // Use cases
  StartGameUseCase startGameUseCase(
    PhysicsService physicsService,
    PipeGeneratorService pipeGeneratorService,
  ) => StartGameUseCase(physicsService, pipeGeneratorService);

  FlapBirdUseCase get flapBirdUseCase => FlapBirdUseCase();

  UpdatePhysicsUseCase updatePhysicsUseCase(
    PhysicsService physicsService,
    CollisionService collisionService,
  ) => UpdatePhysicsUseCase(physicsService, collisionService);

  UpdatePipesUseCase get updatePipesUseCase => UpdatePipesUseCase();

  CheckCollisionUseCase checkCollisionUseCase(
    CollisionService collisionService,
  ) => CheckCollisionUseCase(collisionService);

  LoadHighScoreUseCase loadHighScoreUseCase(FlappbirdRepository repository) =>
      LoadHighScoreUseCase(repository);

  SaveHighScoreUseCase saveHighScoreUseCase(FlappbirdRepository repository) =>
      SaveHighScoreUseCase(repository);
}
