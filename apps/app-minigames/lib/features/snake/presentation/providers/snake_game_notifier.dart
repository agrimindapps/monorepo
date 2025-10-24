// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Core imports:
import 'package:app_minigames/core/di/injection.dart';

// Domain imports:
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/update_snake_position_usecase.dart';
import '../../domain/usecases/change_direction_usecase.dart';
import '../../domain/usecases/start_new_game_usecase.dart';
import '../../domain/usecases/toggle_pause_usecase.dart';
import '../../domain/usecases/change_difficulty_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';

part 'snake_game_notifier.g.dart';

@riverpod
class SnakeGameNotifier extends _$SnakeGameNotifier {
  // Use cases injected via GetIt
  late final UpdateSnakePositionUseCase _updateSnakePositionUseCase;
  late final ChangeDirectionUseCase _changeDirectionUseCase;
  late final StartNewGameUseCase _startNewGameUseCase;
  late final TogglePauseUseCase _togglePauseUseCase;
  late final ChangeDifficultyUseCase _changeDifficultyUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // Game loop timer
  Timer? _gameTimer;

  // High score (cached)
  int _highScore = 0;

  // Mounted flag for race condition protection
  bool _isMounted = true;

  @override
  FutureOr<SnakeGameState> build() async {
    // Inject use cases
    _updateSnakePositionUseCase = getIt<UpdateSnakePositionUseCase>();
    _changeDirectionUseCase = getIt<ChangeDirectionUseCase>();
    _startNewGameUseCase = getIt<StartNewGameUseCase>();
    _togglePauseUseCase = getIt<TogglePauseUseCase>();
    _changeDifficultyUseCase = getIt<ChangeDifficultyUseCase>();
    _loadHighScoreUseCase = getIt<LoadHighScoreUseCase>();
    _saveHighScoreUseCase = getIt<SaveHighScoreUseCase>();

    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
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

    final currentDifficulty = state.valueOrNull?.difficulty ?? SnakeDifficulty.medium;

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
  void _startGameLoop() {
    _gameTimer?.cancel();

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final gameSpeed = currentState.difficulty.gameSpeed;

    _gameTimer = Timer.periodic(gameSpeed, (_) async {
      if (!_isMounted) return;

      final currentState = state.valueOrNull;
      if (currentState == null || !currentState.gameStatus.isRunning) {
        _gameTimer?.cancel();
        return;
      }

      // Update snake position
      final result = await _updateSnakePositionUseCase(currentState: currentState);
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
          }
        },
      );
    });
  }

  /// Change direction
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

}
