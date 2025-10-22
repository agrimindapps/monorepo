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

// Data imports:
import '../data/datasources/flappbird_local_datasource.dart';
import '../data/repositories/flappbird_repository_impl.dart';

@module
abstract class FlappbirdModule {
  // Data sources
  FlappbirdLocalDataSource flappbirdLocalDataSource(
    SharedPreferences prefs,
  ) =>
      FlappbirdLocalDataSource(prefs);

  // Repositories
  @Singleton(as: FlappbirdRepository)
  FlappbirdRepositoryImpl flappbirdRepository(
    FlappbirdLocalDataSource dataSource,
  ) =>
      FlappbirdRepositoryImpl(dataSource);

  // Use cases (stateless - no singleton needed)
  StartGameUseCase get startGameUseCase => StartGameUseCase();

  FlapBirdUseCase get flapBirdUseCase => FlapBirdUseCase();

  UpdatePhysicsUseCase get updatePhysicsUseCase => UpdatePhysicsUseCase();

  UpdatePipesUseCase get updatePipesUseCase => UpdatePipesUseCase();

  CheckCollisionUseCase get checkCollisionUseCase => CheckCollisionUseCase();

  LoadHighScoreUseCase loadHighScoreUseCase(
    FlappbirdRepository repository,
  ) =>
      LoadHighScoreUseCase(repository);

  SaveHighScoreUseCase saveHighScoreUseCase(
    FlappbirdRepository repository,
  ) =>
      SaveHighScoreUseCase(repository);
}
