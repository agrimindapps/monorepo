// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Core imports:
import 'package:app_minigames/core/di/injection.dart';

// Domain imports:
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/flap_bird_usecase.dart';
import '../../domain/usecases/update_physics_usecase.dart';
import '../../domain/usecases/update_pipes_usecase.dart';
import '../../domain/usecases/check_collision_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';

part 'flappbird_notifier.g.dart';

@riverpod
class FlappbirdGameNotifier extends _$FlappbirdGameNotifier {
  // Use cases injected via GetIt
  late final StartGameUseCase _startGameUseCase;
  late final FlapBirdUseCase _flapBirdUseCase;
  late final UpdatePhysicsUseCase _updatePhysicsUseCase;
  late final UpdatePipesUseCase _updatePipesUseCase;
  late final CheckCollisionUseCase _checkCollisionUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // Game loop timer (60fps = 16ms)
  Timer? _gameTimer;

  // High score (cached)
  int _highScore = 0;

  @override
  FutureOr<FlappyGameState> build() async {
    // Default screen dimensions (will be updated when page layout is known)
    const double screenWidth = 400.0;
    const double screenHeight = 800.0;
    // Inject use cases
    _startGameUseCase = getIt<StartGameUseCase>();
    _flapBirdUseCase = getIt<FlapBirdUseCase>();
    _updatePhysicsUseCase = getIt<UpdatePhysicsUseCase>();
    _updatePipesUseCase = getIt<UpdatePipesUseCase>();
    _checkCollisionUseCase = getIt<CheckCollisionUseCase>();
    _loadHighScoreUseCase = getIt<LoadHighScoreUseCase>();
    _saveHighScoreUseCase = getIt<SaveHighScoreUseCase>();

    // Load high score
    await _loadHighScore();

    // Return initial state (not started)
    return FlappyGameState.initial(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      difficulty: FlappyDifficulty.medium,
    );
  }

  /// Get current high score
  int get highScore => _highScore;

  /// Load high score from storage
  Future<void> _loadHighScore() async {
    final result = await _loadHighScoreUseCase();
    result.fold(
      (failure) => _highScore = 0,
      (highScore) => _highScore = highScore.score,
    );
  }

  /// Save high score if current score is higher
  Future<void> _saveHighScore() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (currentState.score > _highScore) {
      final result = await _saveHighScoreUseCase(score: currentState.score);
      result.fold(
        (failure) {}, // Ignore failure
        (_) => _highScore = currentState.score,
      );
    }
  }

  /// Start game
  Future<void> startGame() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final result = await _startGameUseCase(currentState: currentState);

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (newState) {
        state = AsyncValue.data(newState);
        _startGameLoop();
      },
    );
  }

  /// Start 60fps game loop
  void _startGameLoop() {
    _gameTimer?.cancel();

    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 16), // 60fps
      (_) => _updateGame(),
    );
  }

  /// Update game (called every frame)
  Future<void> _updateGame() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isPlaying) {
      _gameTimer?.cancel();
      return;
    }

    // 1. Update physics (gravity, bird position)
    final physicsResult = await _updatePhysicsUseCase(currentState: currentState);

    var newState = currentState;
    physicsResult.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        _gameTimer?.cancel();
        return;
      },
      (updatedState) => newState = updatedState,
    );

    // Check if game over after physics
    if (newState.isGameOver) {
      state = AsyncValue.data(newState);
      _gameTimer?.cancel();
      _saveHighScore();
      return;
    }

    // 2. Update pipes (movement, scoring, spawning)
    final pipesResult = await _updatePipesUseCase(currentState: newState);

    pipesResult.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        _gameTimer?.cancel();
        return;
      },
      (updatedState) => newState = updatedState,
    );

    // 3. Check collision with pipes
    final collisionResult = await _checkCollisionUseCase(currentState: newState);

    collisionResult.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        _gameTimer?.cancel();
        return;
      },
      (updatedState) {
        newState = updatedState;

        // Check if game over after collision
        if (newState.isGameOver) {
          _gameTimer?.cancel();
          _saveHighScore();
        }
      },
    );

    state = AsyncValue.data(newState);
  }

  /// Make bird flap (jump)
  Future<void> flap() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Auto-start if not started
    if (currentState.status == FlappyGameStatus.notStarted ||
        currentState.status == FlappyGameStatus.ready) {
      await startGame();
      return;
    }

    // Restart if game over
    if (currentState.isGameOver) {
      await restartGame();
      return;
    }

    final result = await _flapBirdUseCase(currentState: currentState);

    result.fold(
      (failure) {}, // Ignore flap failures
      (newState) => state = AsyncValue.data(newState),
    );
  }

  /// Restart game
  Future<void> restartGame() async {
    _gameTimer?.cancel();
    await startGame();
  }

  /// Change difficulty and restart
  Future<void> changeDifficulty(FlappyDifficulty newDifficulty) async {
    _gameTimer?.cancel();

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newState = currentState.copyWith(
      difficulty: newDifficulty,
      score: 0,
      status: FlappyGameStatus.notStarted,
    );

    state = AsyncValue.data(newState);
  }

  /// Update screen dimensions
  void updateScreenDimensions(double width, double height) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final groundHeight = height * 0.15;

    final newState = currentState.copyWith(
      screenWidth: width,
      screenHeight: height,
      groundHeight: groundHeight,
      bird: currentState.bird.copyWith(
        y: height * 0.5, // Re-center bird
      ),
    );

    state = AsyncValue.data(newState);
  }
}
