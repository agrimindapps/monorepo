import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/update_moving_block_usecase.dart';
import '../../domain/usecases/drop_block_usecase.dart';
import '../../domain/usecases/start_new_game_usecase.dart';
import '../../domain/usecases/toggle_pause_usecase.dart';
import '../../domain/usecases/change_difficulty_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import 'tower_providers.dart';

part 'tower_game_notifier.g.dart';

/// Riverpod notifier for Tower game state management
/// Handles game loop, player input, high scores, and haptic feedback
@riverpod
class TowerGameNotifier extends _$TowerGameNotifier {
  // Use cases
  late final UpdateMovingBlockUseCase _updateMovingBlockUseCase;
  late final DropBlockUseCase _dropBlockUseCase;
  late final StartNewGameUseCase _startNewGameUseCase;
  late final TogglePauseUseCase _togglePauseUseCase;
  late final ChangeDifficultyUseCase _changeDifficultyUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // Game loop timer
  Timer? _gameTimer;

  // High score tracking
  int _highScore = 0;

  // Mounted flag for race condition protection
  bool _isMounted = true;

  @override
  Future<GameState> build(double screenWidth) async {
    // Inject use cases from providers
    _updateMovingBlockUseCase = ref.read(updateMovingBlockUseCaseProvider);
    _dropBlockUseCase = ref.read(dropBlockUseCaseProvider);
    _startNewGameUseCase = ref.read(startNewGameUseCaseProvider);
    _togglePauseUseCase = ref.read(togglePauseUseCaseProvider);
    _changeDifficultyUseCase = ref.read(changeDifficultyUseCaseProvider);
    _loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    _saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);

    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
    });

    // Load high score
    final highScoreResult = await _loadHighScoreUseCase();
    highScoreResult.fold(
      (failure) => _highScore = 0,
      (highScore) => _highScore = highScore.score,
    );

    // Initialize game state
    final initialState = GameState.initial(screenWidth: screenWidth);

    // Start game loop
    _startGameLoop();

    return initialState;
  }

  /// Starts the game loop timer (16ms = ~60 FPS)
  void _startGameLoop() {
    _gameTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isMounted) return;

      final currentState = state.value;
      if (currentState == null || currentState.isPaused || currentState.isGameOver) {
        return;
      }

      // Update moving block position
      final updateResult = _updateMovingBlockUseCase(currentState);

      updateResult.fold(
        (failure) {
          // Ignore failures in game loop
        },
        (newState) {
          if (!_isMounted) return;
          state = AsyncValue.data(newState);
        },
      );
    });
  }

  /// Drops the current block and handles game logic
  Future<void> dropBlock() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Execute drop block use case
    final dropResult = await _dropBlockUseCase(currentState);

    await dropResult.fold(
      (failure) async {
        // Keep current state on failure
        state = AsyncValue.data(currentState);
      },
      (newState) async {
        state = AsyncValue.data(newState);

        // Handle haptic feedback
        if (newState.isGameOver) {
          // Heavy impact for game over
          HapticFeedback.heavyImpact();
          await _saveHighScoreIfNeeded(newState.score);
        } else if (newState.isPerfectPlacement) {
          // Heavy impact for perfect placement
          HapticFeedback.heavyImpact();
        } else {
          // Medium impact for normal placement
          HapticFeedback.mediumImpact();
        }
      },
    );
  }

  /// Saves high score from external source (Flame)
  Future<void> saveScore(int score) async {
    await _saveHighScoreIfNeeded(score);
  }

  /// Saves high score if current score is higher
  Future<void> _saveHighScoreIfNeeded(int score) async {
    if (score > _highScore) {
      final saveResult = await _saveHighScoreUseCase(score);
      saveResult.fold(
        (failure) {
          // Ignore save failures
        },
        (_) {
          _highScore = score;
        },
      );
    }
  }

  /// Toggles pause state
  void togglePause() {
    final currentState = state.value;
    if (currentState == null) return;

    final pauseResult = _togglePauseUseCase(currentState);

    pauseResult.fold(
      (failure) {
        // Cannot pause - ignore
      },
      (newState) {
        state = AsyncValue.data(newState);
      },
    );
  }

  /// Restarts the game with same settings
  void restartGame() {
    final currentState = state.value;
    if (currentState == null) return;

    final restartResult = _startNewGameUseCase(
      screenWidth: currentState.screenWidth,
      difficulty: currentState.difficulty,
    );

    restartResult.fold(
      (failure) {
        // Restart failed - keep current state
      },
      (newState) {
        state = AsyncValue.data(newState);
        _startGameLoop();
      },
    );
  }

  /// Changes game difficulty
  void changeDifficulty(GameDifficulty difficulty) {
    final currentState = state.value;
    if (currentState == null) return;

    final changeResult = _changeDifficultyUseCase(
      currentState: currentState,
      difficulty: difficulty,
    );

    changeResult.fold(
      (failure) {
        // Change failed - keep current state
      },
      (newState) {
        state = AsyncValue.data(newState);
      },
    );
  }

  /// Exposes high score
  int get highScore => _highScore;
}
