import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/high_score.dart';
import 'caca_palavra_providers.dart';

part 'caca_palavra_game_notifier.g.dart';

/// Riverpod notifier for Caça Palavra game state management
/// Handles grid generation, cell selection, word matching, and scoring
@riverpod
class CacaPalavraGameNotifier extends _$CacaPalavraGameNotifier {
  // Debounce timer for cell taps (100ms as per requirements)
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 100);

  // Game start time for completion tracking
  DateTime? _gameStartTime;

  // High score cache
  HighScore _highScore = const HighScore.empty();

  // Mounted flag for race condition protection
  bool _isMounted = true;

  @override
  Future<GameState> build() async {
    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
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
    final loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    final result = await loadHighScoreUseCase();
    result.fold(
      (failure) => _highScore = const HighScore.empty(),
      (score) => _highScore = score,
    );
  }

  /// Starts a new game with current or default difficulty
  Future<GameState> _startNewGame() async {
    _gameStartTime = DateTime.now();

    final difficulty = state.valueOrNull?.difficulty ?? GameDifficulty.medium;
    final generateGridUseCase = ref.read(generateGridUseCaseProvider);
    final result = await generateGridUseCase(difficulty: difficulty);

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
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isPlaying) return;

    // Haptic feedback for selection
    HapticFeedback.selectionClick();

    if (!_isMounted) return;
    state = const AsyncValue.loading();

    // Select cell
    final selectCellUseCase = ref.read(selectCellUseCaseProvider);
    final selectResult = selectCellUseCase(
      currentState: currentState,
      row: row,
      col: col,
    );

    await selectResult.fold(
      (failure) async {
        if (!_isMounted) return;
        state = AsyncValue.data(currentState);
      },
      (newState) async {
        if (!_isMounted) return;

        // Check if selection forms a word (only if 2+ positions)
        if (newState.selectedPositions.length >= 2) {
          final previousFoundCount = newState.foundWordsCount;

          final checkWordMatchUseCase = ref.read(checkWordMatchUseCaseProvider);
          final checkResult = checkWordMatchUseCase(currentState: newState);

          await checkResult.fold(
            (failure) async {
              if (!_isMounted) return;
              state = AsyncValue.data(newState);
            },
            (finalState) async {
              if (!_isMounted) return;

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
          if (!_isMounted) return;
          state = AsyncValue.data(newState);
        }
      },
    );
  }

  /// Handles word tap from word list (toggles highlight)
  Future<void> handleWordTap(int wordIndex) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final toggleWordHighlightUseCase =
        ref.read(toggleWordHighlightUseCaseProvider);
    final result = toggleWordHighlightUseCase(
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

    final saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);
    final result = await saveHighScoreUseCase(
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

    final restartGameUseCase = ref.read(restartGameUseCaseProvider);
    final result = await restartGameUseCase(newDifficulty: newDifficulty);

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
  @override
  Future<HighScore> build() async {
    final loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    final result = await loadHighScoreUseCase();

    return result.fold(
      (_) => const HighScore.empty(),
      (score) => score,
    );
  }
}
