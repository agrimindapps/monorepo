import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/pingpong_local_datasource.dart';
import '../../data/repositories/pingpong_repository_impl.dart';
import '../../domain/repositories/pingpong_repository.dart';
import '../../domain/services/ai_paddle_service.dart';
import '../../domain/services/ball_physics_service.dart';
import '../../domain/services/collision_detection_service.dart';
import '../../domain/services/score_manager_service.dart';
import '../../domain/usecases/check_collision_usecase.dart';
import '../../domain/usecases/check_score_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/update_ai_paddle_usecase.dart';
import '../../domain/usecases/update_ball_usecase.dart';
import '../../domain/usecases/update_player_paddle_usecase.dart';

part 'pingpong_providers.g.dart';

@riverpod
PingpongLocalDataSource pingpongLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PingpongLocalDataSourceImpl(prefs);
}

@Riverpod(keepAlive: true)
PingpongRepository pingpongRepository(Ref ref) {
  final dataSource = ref.watch(pingpongLocalDataSourceProvider);
  return PingpongRepositoryImpl(dataSource);
}

@riverpod
AiPaddleService aiPaddleService(Ref ref) => AiPaddleService();

@riverpod
BallPhysicsService ballPhysicsService(Ref ref) =>
    BallPhysicsService();

@riverpod
CollisionDetectionService collisionDetectionService(Ref ref) =>
    CollisionDetectionService();

@riverpod
ScoreManagerService scoreManagerService(Ref ref) =>
    ScoreManagerService();

@riverpod
CheckCollisionUseCase checkCollisionUseCase(Ref ref) {
  final service = ref.watch(collisionDetectionServiceProvider);
  final physics = ref.watch(ballPhysicsServiceProvider);
  return CheckCollisionUseCase(service, physics);
}

@riverpod
CheckScoreUseCase checkScoreUseCase(Ref ref) {
  final service = ref.watch(scoreManagerServiceProvider);
  return CheckScoreUseCase(service);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(pingpongRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(pingpongRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
StartGameUseCase startGameUseCase(Ref ref) =>
    StartGameUseCase();

@riverpod
UpdateAiPaddleUseCase updateAiPaddleUseCase(Ref ref) {
  final service = ref.watch(aiPaddleServiceProvider);
  return UpdateAiPaddleUseCase(service);
}

@riverpod
UpdateBallUseCase updateBallUseCase(Ref ref) {
  final service = ref.watch(ballPhysicsServiceProvider);
  return UpdateBallUseCase(service);
}

@riverpod
UpdatePlayerPaddleUseCase updatePlayerPaddleUseCase(Ref ref) =>
    UpdatePlayerPaddleUseCase();
