// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Core imports:

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
import 'flappbird_providers.dart';

part 'flappbird_notifier.g.dart';

@riverpod
class FlappbirdGameNotifier extends _$FlappbirdGameNotifier {
  // Use cases
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

  // Mounted flag for race condition protection
  bool _isMounted = true;

  // Last frame timestamp for delta time calculation
  DateTime? _lastFrameTime;

  @override
  FutureOr<FlappyGameState> build() async {
    // Default screen dimensions (will be updated when page layout is known)
    const double screenWidth = 400.0;
    const double screenHeight = 800.0;
    // Inject use cases
    _startGameUseCase = ref.read(startGameUseCaseProvider);
    _flapBirdUseCase = ref.read(flapBirdUseCaseProvider);
    _updatePhysicsUseCase = ref.read(updatePhysicsUseCaseProvider);
    _updatePipesUseCase = ref.read(updatePipesUseCaseProvider);
    _checkCollisionUseCase = ref.read(checkCollisionUseCaseProvider);
    _loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    _saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);

    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
    });

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
    final currentState = state.value;
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
    if (!_isMounted) return;

    final currentState = state.value;
    if (currentState == null) return;

    final result = await _startGameUseCase(currentState: currentState);
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);
        _startGameLoop();
      },
    );
  }

  /// Start 60fps game loop with delta time support
  void _startGameLoop() {
    _gameTimer?.cancel();
    _lastFrameTime = DateTime.now();

    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 16), // Target 60fps
      (_) => _updateGame(),
    );
  }

  /// Update game (called every frame)
  /// Calculates delta time and passes it to physics calculations
  Future<void> _updateGame() async {
    if (!_isMounted) return;

    final currentState = state.value;
    if (currentState == null || !currentState.isPlaying) {
      _gameTimer?.cancel();
      return;
    }

    // Calculate delta time since last frame
    final now = DateTime.now();
    final deltaTime = _lastFrameTime != null
        ? now.difference(_lastFrameTime!).inMilliseconds / 1000.0
        : 1.0 / 60.0; // Fallback to 60fps if first frame
    _lastFrameTime = now;

    // Clamp delta time to prevent large jumps (e.g., device pause/resume)
    final clampedDeltaTime = deltaTime.clamp(1.0 / 120.0, 0.1); // 8.3ms to 100ms

    // 1. Update physics (gravity, bird position) with delta time
    final physicsResult = await _updatePhysicsUseCase(
      currentState: currentState,
      deltaTimeSeconds: clampedDeltaTime,
    );
    if (!_isMounted) return;

    var newState = currentState;
    physicsResult.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
        _gameTimer?.cancel();
        return;
      },
      (updatedState) => newState = updatedState,
    );

    // Check if game over after physics
    if (newState.isGameOver) {
      if (!_isMounted) return;
      state = AsyncValue.data(newState);
      _gameTimer?.cancel();
      _saveHighScore();
      return;
    }

    // 2. Update pipes (movement, scoring, spawning)
    final pipesResult = await _updatePipesUseCase(currentState: newState);
    if (!_isMounted) return;

    pipesResult.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
        _gameTimer?.cancel();
        return;
      },
      (updatedState) => newState = updatedState,
    );

    // 3. Check collision with pipes
    final collisionResult = await _checkCollisionUseCase(currentState: newState);
    if (!_isMounted) return;

    collisionResult.fold(
      (failure) {
        if (!_isMounted) return;
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

    if (!_isMounted) return;
    state = AsyncValue.data(newState);
  }

  /// Make bird flap (jump)
  Future<void> flap() async {
    if (!_isMounted) return;

    final currentState = state.value;
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
    if (!_isMounted) return;

    result.fold(
      (failure) {}, // Ignore flap failures
      (newState) {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);
      },
    );
  }

  /// Restart game
  Future<void> restartGame() async {
    _gameTimer?.cancel();
    await startGame();
  }

  /// Change difficulty and restart
  Future<void> changeDifficulty(FlappyDifficulty newDifficulty) async {
    if (!_isMounted) return;

    _gameTimer?.cancel();

    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(
      difficulty: newDifficulty,
      score: 0,
      status: FlappyGameStatus.notStarted,
    );

    if (!_isMounted) return;
    state = AsyncValue.data(newState);
  }

  /// Update screen dimensions
  void updateScreenDimensions(double width, double height) {
    if (!_isMounted) return;

    final currentState = state.value;
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

    if (!_isMounted) return;
    state = AsyncValue.data(newState);
  }
}
