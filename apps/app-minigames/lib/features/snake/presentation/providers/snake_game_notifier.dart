// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Domain imports:
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';
import '../../domain/services/direction_queue.dart';
import '../../domain/services/snake_movement_service.dart';
import '../../domain/services/power_up_service.dart';
import '../../domain/services/game_mode_service.dart';
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
  late final PowerUpService _powerUpService;
  late final GameModeService _gameModeService;

  // Game loop timer
  Timer? _gameTimer;
  
  // Elapsed time timer for survival/time attack modes
  Timer? _elapsedTimer;

  // High score (cached)
  int _highScore = 0;
  
  // XP gained this game (for display)
  int _lastXpGained = 0;
  
  // Was new high score achieved
  bool _isNewHighScore = false;

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
    _powerUpService = ref.read(powerUpServiceProvider);
    _gameModeService = ref.read(gameModeServiceProvider);

    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
      _elapsedTimer?.cancel();
      _directionQueue.clear();
    });

    // Load high score
    await _loadHighScore();

    // Return initial state (not started)
    return SnakeGameState.initial();
  }

  /// Get current high score
  int get highScore => _highScore;
  
  /// Get last XP gained
  int get lastXpGained => _lastXpGained;
  
  /// Was new high score achieved in last game
  bool get isNewHighScore => _isNewHighScore;

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
    final currentState = state.value;
    if (currentState == null) return;

    _isNewHighScore = currentState.score > _highScore;
    if (_isNewHighScore) {
      final result = await _saveHighScoreUseCase(score: currentState.score);
      result.fold(
        (failure) {}, // Ignore failure
        (_) => _highScore = currentState.score,
      );
    }
  }

  /// Start a new game with optional mode and difficulty
  Future<void> startGame({
    SnakeGameMode? gameMode,
    SnakeDifficulty? difficulty,
    int? gridSize,
  }) async {
    if (!_isMounted) return;
    
    _isNewHighScore = false;
    _lastXpGained = 0;

    final currentState = state.value;
    final finalDifficulty = difficulty ?? currentState?.difficulty ?? SnakeDifficulty.medium;
    final finalGameMode = gameMode ?? currentState?.gameMode ?? SnakeGameMode.classic;
    final finalGridSize = gridSize ?? currentState?.gridSize ?? 20;

    final result = await _startNewGameUseCase(difficulty: finalDifficulty);
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) {
        if (!_isMounted) return;
        // Apply game mode and grid size to the new state
        final stateWithMode = newState.copyWith(
          gameMode: finalGameMode,
          gridSize: finalGridSize,
          timeAttackRemainingSeconds: finalGameMode == SnakeGameMode.timeAttack 
              ? _gameModeService.getTimeAttackDuration() 
              : 120,
        );
        state = AsyncValue.data(stateWithMode);
        _startGameLoop();
        _startElapsedTimer();
      },
    );
  }
  
  /// Start elapsed time timer
  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isMounted) return;
      
      final currentState = state.value;
      if (currentState == null || !currentState.gameStatus.isRunning) {
        _elapsedTimer?.cancel();
        return;
      }
      
      // Update elapsed seconds
      var newState = currentState.copyWith(
        elapsedSeconds: currentState.elapsedSeconds + 1,
      );
      
      // Handle Time Attack mode countdown
      if (currentState.gameMode == SnakeGameMode.timeAttack) {
        final newRemaining = currentState.timeAttackRemainingSeconds - 1;
        if (newRemaining <= 0) {
          // Time's up - game over
          newState = newState.copyWith(
            gameStatus: SnakeGameStatus.gameOver,
            timeAttackRemainingSeconds: 0,
            lastDeathType: SnakeDeathType.timeout,
          );
          _gameTimer?.cancel();
          _elapsedTimer?.cancel();
          _saveHighScore();
          HapticFeedback.heavyImpact();
        } else {
          newState = newState.copyWith(
            timeAttackRemainingSeconds: newRemaining,
          );
        }
      }
      
      state = AsyncValue.data(newState);
    });
  }

  /// Start game loop (Timer.periodic)
  /// Uses dynamic game speed based on current score and power-ups
  void _startGameLoop() {
    _gameTimer?.cancel();
    _directionQueue.clear();

    final initialState = state.value;
    if (initialState == null) return;

    // Calculate initial game speed with dynamic difficulty
    var dynamicGameSpeed = _movementService.calculateDynamicGameSpeed(
      baseDifficulty: initialState.difficulty,
      score: initialState.score,
    );

    // Apply power-up speed modifiers
    dynamicGameSpeed = _powerUpService.calculateSpeedWithPowerUps(
      baseSpeed: dynamicGameSpeed,
      hasSpeedBoost: initialState.hasSpeedBoost,
      hasSlowMotion: initialState.hasSlowMotion,
    );
    
    // Apply survival mode speed if applicable
    if (initialState.gameMode == SnakeGameMode.survival) {
      dynamicGameSpeed = _gameModeService.calculateSurvivalSpeed(
        baseSpeed: dynamicGameSpeed,
        secondsElapsed: initialState.elapsedSeconds,
      );
    }

    _gameTimer =
        Timer.periodic(Duration(milliseconds: dynamicGameSpeed), (_) async {
      if (!_isMounted) return;

      var currentState = state.value;
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
            
            // Track food eaten and power-ups collected
            var updatedState = newState;
            if (newState.score > currentState!.score) {
              final foodEaten = (newState.score - currentState!.score) ~/ 10;
              updatedState = updatedState.copyWith(
                foodEatenThisGame: updatedState.foodEatenThisGame + foodEaten,
              );
            }
            
            // Track power-ups collected
            if (newState.activePowerUps.length > currentState!.activePowerUps.length) {
              final newPowerUps = Map<String, int>.from(updatedState.powerUpsCollectedThisGame);
              for (final powerUp in newState.activePowerUps) {
                if (!currentState!.activePowerUps.any((p) => p.type == powerUp.type && p.activatedAt == powerUp.activatedAt)) {
                  final typeName = powerUp.type.name;
                  newPowerUps[typeName] = (newPowerUps[typeName] ?? 0) + 1;
                }
              }
              updatedState = updatedState.copyWith(
                powerUpsCollectedThisGame: newPowerUps,
              );
            }
            
            state = AsyncValue.data(updatedState);

            // Check game over
            if (newState.gameStatus.isGameOver) {
              _gameTimer?.cancel();
              _elapsedTimer?.cancel();
              _saveHighScore();
              HapticFeedback.heavyImpact();
            } else {
              // Check if score increased (food eaten) or power-up collected
              if (newState.score > currentState!.score) {
                HapticFeedback.lightImpact();
              }
              if (newState.activePowerUps.length > currentState!.activePowerUps.length) {
                HapticFeedback.mediumImpact();
              }

              // Recalculate game speed if score or power-ups changed
              var newDynamicSpeed = _movementService.calculateDynamicGameSpeed(
                baseDifficulty: newState.difficulty,
                score: newState.score,
              );

              // Apply power-up speed modifiers
              newDynamicSpeed = _powerUpService.calculateSpeedWithPowerUps(
                baseSpeed: newDynamicSpeed,
                hasSpeedBoost: newState.hasSpeedBoost,
                hasSlowMotion: newState.hasSlowMotion,
              );
              
              // Apply survival mode speed if applicable
              if (newState.gameMode == SnakeGameMode.survival) {
                newDynamicSpeed = _gameModeService.calculateSurvivalSpeed(
                  baseSpeed: newDynamicSpeed,
                  secondsElapsed: newState.elapsedSeconds,
                );
              }

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

    final currentState = state.value;
    if (currentState == null) return;

    // Auto-start game if not started
    if (currentState.gameStatus.isNotStarted) {
      await startGame();
      if (!_isMounted) return;

      // Change direction after starting
      final startedState = state.value;
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

    final currentState = state.value;
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
          _startElapsedTimer();
        } else {
          _gameTimer?.cancel();
          _elapsedTimer?.cancel();
        }
      },
    );
  }

  /// Restart game
  Future<void> restartGame() async {
    _gameTimer?.cancel();
    _elapsedTimer?.cancel();
    await startGame();
  }

  /// Change difficulty
  Future<void> changeDifficulty(SnakeDifficulty newDifficulty) async {
    if (!_isMounted) return;

    final currentState = state.value;
    if (currentState == null) return;

    _gameTimer?.cancel();
    _elapsedTimer?.cancel();

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
  
  /// Change game mode
  Future<void> changeGameMode(SnakeGameMode newMode) async {
    if (!_isMounted) return;
    
    final currentState = state.value;
    if (currentState == null) return;
    
    _gameTimer?.cancel();
    _elapsedTimer?.cancel();
    
    final newState = SnakeGameState.initial(
      difficulty: currentState.difficulty,
      hasWalls: currentState.hasWalls,
      gameMode: newMode,
      gridSize: currentState.gridSize,
    );
    
    state = AsyncValue.data(newState);
  }
  
  /// Change grid size
  Future<void> changeGridSize(int newGridSize) async {
    if (!_isMounted) return;
    
    final currentState = state.value;
    if (currentState == null) return;
    
    _gameTimer?.cancel();
    _elapsedTimer?.cancel();
    
    final newState = SnakeGameState.initial(
      difficulty: currentState.difficulty,
      hasWalls: currentState.hasWalls,
      gameMode: currentState.gameMode,
      gridSize: newGridSize,
    );
    
    state = AsyncValue.data(newState);
  }

  /// Toggle wall mode
  Future<void> toggleWalls() async {
    if (!_isMounted) return;

    final currentState = state.value;
    if (currentState == null) return;

    // Toggle hasWalls
    final newHasWalls = !currentState.hasWalls;

    // Restart game with new setting
    _gameTimer?.cancel();
    _elapsedTimer?.cancel();

    final newState = SnakeGameState.initial(
      difficulty: currentState.difficulty,
      hasWalls: newHasWalls,
      gameMode: currentState.gameMode,
      gridSize: currentState.gridSize,
    );

    state = AsyncValue.data(newState);
    // Don't auto-start, let user start
  }
  
  /// Calculate XP for current game (for display purposes)
  int calculateXpForCurrentGame() {
    final currentState = state.value;
    if (currentState == null) return 0;
    
    final totalPowerUps = currentState.powerUpsCollectedThisGame.values
        .fold<int>(0, (sum, count) => sum + count);
    
    return _calculateXp(
      score: currentState.score,
      snakeLength: currentState.length,
      survivalSeconds: currentState.elapsedSeconds,
      difficulty: currentState.difficulty.name,
      powerUpsCollected: totalPowerUps,
    );
  }
  
  int _calculateXp({
    required int score,
    required int snakeLength,
    required int survivalSeconds,
    required String difficulty,
    required int powerUpsCollected,
  }) {
    int baseXp = score * 2;
    int lengthBonus = snakeLength * 5;
    int survivalBonus = survivalSeconds ~/ 10;
    int powerUpBonus = powerUpsCollected * 10;

    double difficultyMultiplier = switch (difficulty) {
      'easy' => 1.0,
      'medium' => 1.5,
      'hard' => 2.0,
      _ => 1.0,
    };

    return ((baseXp + lengthBonus + survivalBonus + powerUpBonus) *
            difficultyMultiplier)
        .round();
  }
}
