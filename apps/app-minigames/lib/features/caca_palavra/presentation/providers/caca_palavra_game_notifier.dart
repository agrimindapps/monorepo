import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/high_score.dart';
import '../../domain/usecases/generate_grid_usecase.dart';
import '../../domain/usecases/select_cell_usecase.dart';
import '../../domain/usecases/check_word_match_usecase.dart';
import '../../domain/usecases/toggle_word_highlight_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';

part 'caca_palavra_game_notifier.g.dart';

/// Riverpod notifier for Caça Palavra game state management
/// Handles grid generation, cell selection, word matching, and scoring
@riverpod
class CacaPalavraGameNotifier extends _$CacaPalavraGameNotifier {
  // Use cases
  late final GenerateGridUseCase _generateGridUseCase;
  late final SelectCellUseCase _selectCellUseCase;
  late final CheckWordMatchUseCase _checkWordMatchUseCase;
  late final ToggleWordHighlightUseCase _toggleWordHighlightUseCase;
  late final RestartGameUseCase _restartGameUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // Debounce timer for cell taps (100ms as per requirements)
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 100);

  // Game start time for completion tracking
  DateTime? _gameStartTime;

  // High score cache
  HighScore _highScore = const HighScore.empty();

  @override
  Future<GameState> build() async {
    // Inject use cases
    _generateGridUseCase = getIt<GenerateGridUseCase>();
    _selectCellUseCase = getIt<SelectCellUseCase>();
    _checkWordMatchUseCase = getIt<CheckWordMatchUseCase>();
    _toggleWordHighlightUseCase = getIt<ToggleWordHighlightUseCase>();
    _restartGameUseCase = getIt<RestartGameUseCase>();
    _loadHighScoreUseCase = getIt<LoadHighScoreUseCase>();
    _saveHighScoreUseCase = getIt<SaveHighScoreUseCase>();

    // Cleanup on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Load high score
    await _loadHighScore();

    // Start new game
    return await _startNewGame();
  }

  /// Get current high score
  HighScore get highScore => _highScore;

  /// Loads high score from storage
  Future<void> _loadHighScore() async {
    final result = await _loadHighScoreUseCase();
    result.fold(
      (failure) => _highScore = const HighScore.empty(),
      (score) => _highScore = score,
    );
  }

  /// Starts a new game with current or default difficulty
  Future<GameState> _startNewGame() async {
    _gameStartTime = DateTime.now();

    final difficulty = state.valueOrNull?.difficulty ?? GameDifficulty.medium;
    final result = await _generateGridUseCase(difficulty: difficulty);

    return result.fold(
      (failure) => GameState.initial(difficulty: difficulty),
      (newState) => newState,
    );
  }

  /// Handles cell tap with debounce (100ms)
  Future<void> handleCellTap(int row, int col) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Schedule execution after debounce delay
    _debounceTimer = Timer(_debounceDuration, () async {
      await _executeCellTap(row, col);
    });
  }

  /// Executes cell tap after debounce
  Future<void> _executeCellTap(int row, int col) async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isPlaying) return;

    // Haptic feedback for selection
    HapticFeedback.selectionClick();

    state = const AsyncValue.loading();

    // Select cell
    final selectResult = _selectCellUseCase(
      currentState: currentState,
      row: row,
      col: col,
    );

    await selectResult.fold(
      (failure) async {
        state = AsyncValue.data(currentState);
      },
      (newState) async {
        // Check if selection forms a word (only if 2+ positions)
        if (newState.selectedPositions.length >= 2) {
          final previousFoundCount = newState.foundWordsCount;

          final checkResult = _checkWordMatchUseCase(currentState: newState);

          await checkResult.fold(
            (failure) async {
              state = AsyncValue.data(newState);
            },
            (finalState) async {
              // Provide haptic feedback if word was found
              if (finalState.foundWordsCount > previousFoundCount) {
                HapticFeedback.mediumImpact();
              }

              state = AsyncValue.data(finalState);

              // Check if game completed
              if (finalState.isCompleted) {
                await _handleGameCompletion(finalState);
              }
            },
          );
        } else {
          state = AsyncValue.data(newState);
        }
      },
    );
  }

  /// Handles word tap from word list (toggles highlight)
  Future<void> handleWordTap(int wordIndex) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final result = _toggleWordHighlightUseCase(
      currentState: currentState,
      wordIndex: wordIndex,
    );

    result.fold(
      (failure) {}, // Ignore errors
      (newState) {
        state = AsyncValue.data(newState);
      },
    );
  }

  /// Handles game completion (saves high score)
  Future<void> _handleGameCompletion(GameState finalState) async {
    if (_gameStartTime == null) return;

    final completionTime = DateTime.now().difference(_gameStartTime!).inSeconds;

    final result = await _saveHighScoreUseCase(
      difficulty: finalState.difficulty,
      completionTime: completionTime,
    );

    result.fold(
      (failure) {}, // Ignore save errors
      (updatedScore) {
        _highScore = updatedScore;
        // Invalidate high score provider
        ref.invalidate(cacaPalavraHighScoreNotifierProvider);
      },
    );
  }

  /// Restarts game with optional new difficulty
  Future<void> restartGame({GameDifficulty? newDifficulty}) async {
    _debounceTimer?.cancel();
    _gameStartTime = DateTime.now();

    state = const AsyncValue.loading();

    final result = await _restartGameUseCase(newDifficulty: newDifficulty);

    result.fold(
      (failure) {
        // Fallback to initial state on error
        state = AsyncValue.data(
          GameState.initial(difficulty: newDifficulty ?? GameDifficulty.medium),
        );
      },
      (newState) {
        state = AsyncValue.data(newState);
      },
    );
  }

  /// Changes difficulty and restarts game
  Future<void> changeDifficulty(GameDifficulty difficulty) async {
    await restartGame(newDifficulty: difficulty);
  }

  /// Gets completion time in seconds (if game completed)
  int? getCompletionTime() {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        !currentState.isCompleted ||
        _gameStartTime == null) {
      return null;
    }

    return DateTime.now().difference(_gameStartTime!).inSeconds;
  }
}

/// Provider for high score
@riverpod
class CacaPalavraHighScoreNotifier extends _$CacaPalavraHighScoreNotifier {
  late final LoadHighScoreUseCase _loadHighScoreUseCase;

  @override
  Future<HighScore> build() async {
    _loadHighScoreUseCase = getIt<LoadHighScoreUseCase>();

    final result = await _loadHighScoreUseCase();

    return result.fold(
      (_) => const HighScore.empty(),
      (score) => score,
    );
  }
}
