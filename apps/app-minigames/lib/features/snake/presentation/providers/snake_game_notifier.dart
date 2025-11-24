// Dart imports:
import 'dart:async';

// Package imports:
// Package imports:
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Domain imports:
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';
import '../../domain/services/direction_queue.dart';
import '../../domain/services/snake_movement_service.dart';
import '../../domain/usecases/update_snake_position_usecase.dart';
import '../../domain/usecases/change_direction_usecase.dart';
import '../../domain/usecases/start_new_game_usecase.dart';
import '../../domain/usecases/toggle_pause_usecase.dart';
import '../../domain/usecases/change_difficulty_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import 'snake_providers.dart';

part 'snake_game_notifier.g.dart';

@riverpod
class SnakeGameNotifier extends _$SnakeGameNotifier {
  // Use cases injected via Riverpod
  late final UpdateSnakePositionUseCase _updateSnakePositionUseCase;
  late final ChangeDirectionUseCase _changeDirectionUseCase;
  late final StartNewGameUseCase _startNewGameUseCase;
  late final TogglePauseUseCase _togglePauseUseCase;
  late final ChangeDifficultyUseCase _changeDifficultyUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // Services
  late final SnakeMovementService _movementService;

  // Game loop timer
  Timer? _gameTimer;

  // High score (cached)
  int _highScore = 0;

  // Mounted flag for race condition protection
  bool _isMounted = true;

  // Input buffering for responsive controls
  final DirectionQueue _directionQueue = DirectionQueue();

  @override
  FutureOr<SnakeGameState> build() async {
    // Inject use cases
    _updateSnakePositionUseCase = ref.read(updateSnakePositionUseCaseProvider);
    _changeDirectionUseCase = ref.read(changeDirectionUseCaseProvider);
    _startNewGameUseCase = ref.read(startNewGameUseCaseProvider);
    _togglePauseUseCase = ref.read(togglePauseUseCaseProvider);
    _changeDifficultyUseCase = ref.read(changeDifficultyUseCaseProvider);
    _loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    _saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);

    // Inject services
    _movementService = ref.read(snakeMovementServiceProvider);

    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
      _directionQueue.clear();
    });

    // Load high score
    await _loadHighScore();

    // Return initial state (not started)
    return SnakeGameState.initial();
  }

  /// Get current high score
  int get highScore => _highScore;

  /// Load high score
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

  /// Start a new game
  Future<void> startGame() async {
    if (!_isMounted) return;

    final currentDifficulty =
        state.valueOrNull?.difficulty ?? SnakeDifficulty.medium;

    final result = await _startNewGameUseCase(difficulty: currentDifficulty);
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

  /// Start game loop (Timer.periodic)
  /// Uses dynamic game speed based on current score
  void _startGameLoop() {
    _gameTimer?.cancel();
    _directionQueue.clear();

    final initialState = state.valueOrNull;
    if (initialState == null) return;

    // Calculate initial game speed with dynamic difficulty
    final dynamicGameSpeed = _movementService.calculateDynamicGameSpeed(
      baseDifficulty: initialState.difficulty,
      score: initialState.score,
    );

    _gameTimer =
        Timer.periodic(Duration(milliseconds: dynamicGameSpeed), (_) async {
      if (!_isMounted) return;

      var currentState = state.valueOrNull;
      if (currentState == null || !currentState.gameStatus.isRunning) {
        _gameTimer?.cancel();
        return;
      }

      // Process queued direction changes
      while (!_directionQueue.isEmpty) {
        final queuedDirection = _directionQueue.dequeue();
        if (queuedDirection != null && currentState != null) {
          final result = await _changeDirectionUseCase(
            currentState: currentState!,
            newDirection: queuedDirection,
          );
          result.fold(
            (failure) {}, // Ignore invalid directions
            (newState) => currentState = newState,
          );
        }
      }

      // Update snake position
      if (currentState != null) {
        final result =
            await _updateSnakePositionUseCase(currentState: currentState!);
        if (!_isMounted) return;

        result.fold(
          (failure) {
            if (!_isMounted) return;
            state = AsyncValue.error(failure, StackTrace.current);
            _gameTimer?.cancel();
          },
          (newState) {
            if (!_isMounted) return;
            state = AsyncValue.data(newState);

            // Check game over
            if (newState.gameStatus.isGameOver) {
              _gameTimer?.cancel();
              _saveHighScore();
              HapticFeedback.heavyImpact();
            } else {
              // Check if score increased (food eaten)
              if (newState.score > currentState!.score) {
                HapticFeedback.lightImpact();
              }

              // Recalculate game speed if score changed (dynamic difficulty)
              final newDynamicSpeed =
                  _movementService.calculateDynamicGameSpeed(
                baseDifficulty: newState.difficulty,
                score: newState.score,
              );

              if (newDynamicSpeed != dynamicGameSpeed) {
                // Speed changed, restart timer with new speed
                _startGameLoop();
              }
            }
          },
        );
      }
    });
  }

  /// Change direction with input buffering
  /// Queues direction changes if game is running for more responsive controls
  Future<void> changeDirection(Direction newDirection) async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Auto-start game if not started
    if (currentState.gameStatus.isNotStarted) {
      await startGame();
      if (!_isMounted) return;

      // Change direction after starting
      final startedState = state.valueOrNull;
      if (startedState != null) {
        final result = await _changeDirectionUseCase(
          currentState: startedState,
          newDirection: newDirection,
        );
        if (!_isMounted) return;

        result.fold(
          (failure) {}, // Ignore opposite direction
          (newState) {
            if (!_isMounted) return;
            state = AsyncValue.data(newState);
          },
        );
      }
      return;
    }

    // If game is running, queue the direction for next frame
    if (currentState.gameStatus.isRunning) {
      _directionQueue.enqueue(
        newDirection: newDirection,
        currentDirection: currentState.direction,
      );
      return;
    }

    // If game is paused, apply direction immediately
    final result = await _changeDirectionUseCase(
      currentState: currentState,
      newDirection: newDirection,
    );
    if (!_isMounted) return;

    result.fold(
      (failure) {}, // Ignore opposite direction
      (newState) {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);
      },
    );
  }

  /// Toggle pause
  Future<void> togglePause() async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final result = await _togglePauseUseCase(currentState: currentState);
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);

        if (newState.gameStatus.isRunning) {
          _startGameLoop();
        } else {
          _gameTimer?.cancel();
        }
      },
    );
  }

  /// Restart game
  Future<void> restartGame() async {
    _gameTimer?.cancel();
    await startGame();
  }

  /// Change difficulty
  Future<void> changeDifficulty(SnakeDifficulty newDifficulty) async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    _gameTimer?.cancel();

    final result = await _changeDifficultyUseCase(
      currentState: currentState,
      newDifficulty: newDifficulty,
    );
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) async {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);
        await startGame();
      },
    );
  }

  /// Toggle wall mode
  Future<void> toggleWalls() async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Toggle hasWalls
    final newHasWalls = !currentState.hasWalls;

    // Restart game with new setting
    _gameTimer?.cancel();

    // We need to update the startNewGameUseCase to accept hasWalls or update state manually
    // For now, let's update state manually and restart

    final newState = SnakeGameState.initial(
      difficulty: currentState.difficulty,
      hasWalls: newHasWalls,
    );

    state = AsyncValue.data(newState);
    // Don't auto-start, let user start
  }
}
