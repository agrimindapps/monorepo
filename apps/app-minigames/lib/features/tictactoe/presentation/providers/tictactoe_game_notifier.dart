import 'dart:async';
import 'package:flutter/semantics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/game_settings.dart';
import '../../domain/entities/enums.dart';
// import '../../domain/entities/game_analytics.dart'; // For future analytics
import '../../domain/usecases/make_move_usecase.dart';
import '../../domain/usecases/make_ai_move_usecase.dart';
import '../../domain/usecases/check_game_result_usecase.dart';
import '../../domain/usecases/load_settings_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';
import '../../domain/usecases/load_stats_usecase.dart';
import '../../domain/usecases/save_stats_usecase.dart';
import '../../domain/usecases/reset_stats_usecase.dart';
import 'tictactoe_providers.dart';

part 'tictactoe_game_notifier.g.dart';

/// Riverpod notifier for TicTacToe game state management
/// Handles game logic, AI moves, settings, and statistics
@riverpod
class TicTacToeGameNotifier extends _$TicTacToeGameNotifier {
  // Use cases
  late final MakeMoveUseCase _makeMoveUseCase;
  late final MakeAIMoveUseCase _makeAIMoveUseCase;
  late final CheckGameResultUseCase _checkGameResultUseCase;
  late final LoadSettingsUseCase _loadSettingsUseCase;
  late final SaveSettingsUseCase _saveSettingsUseCase;
  late final LoadStatsUseCase _loadStatsUseCase;
  late final SaveStatsUseCase _saveStatsUseCase;

  // Analytics tracking (for future use - currently commented out)
  // final GameAnalytics _analytics = const GameAnalytics();
  // DateTime? _gameStartTime;
  // DateTime? _lastMoveTime;
  // final List<GameMove> _currentGameMoves = [];

  // Protection against multiple AI executions
  bool _isProcessingAIMove = false;
  Timer? _aiTimer;
  bool _isMounted = true;

  @override
  Future<GameState> build() async {
    // Inject use cases
    _makeMoveUseCase = ref.read(makeMoveUseCaseProvider);
    _makeAIMoveUseCase = ref.read(makeAiMoveUseCaseProvider);
    _checkGameResultUseCase = ref.read(checkGameResultUseCaseProvider);
    _loadSettingsUseCase = ref.read(loadSettingsUseCaseProvider);
    _saveSettingsUseCase = ref.read(saveSettingsUseCaseProvider);
    _loadStatsUseCase = ref.read(loadStatsUseCaseProvider);
    _saveStatsUseCase = ref.read(saveStatsUseCaseProvider);

    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _aiTimer?.cancel();
    });

    // Load settings and initialize game
    final settingsResult = await _loadSettingsUseCase();

    return settingsResult.fold(
      (_) => GameState.initial(), // Default settings on error
      (settings) => GameState.initial(
        gameMode: settings.gameMode,
        difficulty: settings.difficulty,
      ),
    );
  }

  /// Makes a player move at the specified position
  Future<void> makeMove(int row, int col) async {
    final currentState = state.value;
    if (currentState == null || !currentState.isInProgress) return;

    // Track move timing (for future analytics)
    // final now = DateTime.now();
    // final thinkingTime =
    //     _lastMoveTime != null ? now.difference(_lastMoveTime!) : Duration.zero;

    // Record move for analytics (commented out for future use)
    // _currentGameMoves.add(
    //   GameMove(
    //     row: row,
    //     col: col,
    //     player: currentState.currentPlayer,
    //     timestamp: now,
    //     thinkingTime: thinkingTime, // Uses thinkingTime from above
    //   ),
    // );

    state = const AsyncValue.loading();

    // Execute move
    final moveResult = await _makeMoveUseCase(
      currentState: currentState,
      row: row,
      col: col,
    );

    await moveResult.fold(
      (failure) async {
        // Revert to previous state on failure
        state = AsyncValue.data(currentState);
      },
      (newState) async {
        // Track last move time for analytics (future use)
        // _lastMoveTime = now;

        // Check game result
        final resultCheck = await _checkGameResultUseCase(newState);

        await resultCheck.fold(
          (failure) async {
            state = AsyncValue.data(newState);
          },
          (finalState) async {
            state = AsyncValue.data(finalState);

            // Track last move time for analytics (future use)
            // _lastMoveTime = now;

            // Announce move for accessibility
            _announceMove(row, col, currentState.currentPlayer);

            // If game ended, handle end-game logic
            if (!finalState.isInProgress) {
              await _handleGameEnd(finalState);
              _announceGameResult(finalState);
            } else if (finalState.gameMode == GameMode.vsComputer) {
              // Schedule AI move
              _scheduleAIMove();
            }
          },
        );
      },
    );
  }

  /// Schedules AI move with delay for better UX
  void _scheduleAIMove() {
    _aiTimer?.cancel();

    _aiTimer = Timer(const Duration(milliseconds: 500), () async {
      await _executeAIMove();
    });
  }

  /// Executes AI move with protection against multiple executions
  Future<void> _executeAIMove() async {
    if (!_isMounted) return;
    if (_isProcessingAIMove) return;

    final currentState = state.value;
    if (currentState == null || !currentState.isInProgress) return;

    _isProcessingAIMove = true;

    try {
      if (!_isMounted) return;
      state = const AsyncValue.loading();

      final aiMoveResult = await _makeAIMoveUseCase(currentState);
      if (!_isMounted) return;

      await aiMoveResult.fold(
        (failure) async {
          if (!_isMounted) return;
          state = AsyncValue.data(currentState);
        },
        (newState) async {
          if (!_isMounted) return;

          // Check game result after AI move
          final resultCheck = await _checkGameResultUseCase(newState);
          if (!_isMounted) return;

          await resultCheck.fold(
            (failure) async {
              if (!_isMounted) return;
              state = AsyncValue.data(newState);
            },
            (finalState) async {
              if (!_isMounted) return;
              state = AsyncValue.data(finalState);

              if (!finalState.isInProgress) {
                await _handleGameEnd(finalState);
                _announceGameResult(finalState);
              }
            },
          );
        },
      );
    } finally {
      _isProcessingAIMove = false;
    }
  }

  /// Handles game end logic (save stats, analytics)
  Future<void> _handleGameEnd(GameState finalState) async {
    // Update analytics (commented out for now - can be persisted in future)
    // if (_gameStartTime != null) {
    //   final session = GameSession(
    //     moves: List.from(_currentGameMoves),
    //     result: finalState.result,
    //     mode: finalState.gameMode,
    //     difficulty: finalState.difficulty,
    //     startTime: _gameStartTime!,
    //     endTime: DateTime.now(),
    //   );
    //   _analytics.addSession(session);
    // }

    // Update and save stats
    final statsResult = await _loadStatsUseCase();

    await statsResult.fold(
      (_) {}, // Ignore error
      (currentStats) async {
        GameStats updatedStats;

        switch (finalState.result) {
          case GameResult.xWins:
            updatedStats = currentStats.incrementXWins();
            break;
          case GameResult.oWins:
            updatedStats = currentStats.incrementOWins();
            break;
          case GameResult.draw:
            updatedStats = currentStats.incrementDraws();
            break;
          default:
            updatedStats = currentStats;
        }

        await _saveStatsUseCase(updatedStats);

        // Invalidate stats provider to refresh UI
        ref.invalidate(ticTacToeStatsProvider);
      },
    );
  }

  /// Restarts the game with same settings
  Future<void> restartGame() async {
    _aiTimer?.cancel();
    _isProcessingAIMove = false;

    final currentState = state.value;
    if (currentState == null) return;

    // Start new game tracking (for future analytics)
    // _gameStartTime = DateTime.now();
    // _lastMoveTime = DateTime.now();
    // _currentGameMoves.clear();

    // Reset to initial state
    final newState = GameState.initial(
      gameMode: currentState.gameMode,
      difficulty: currentState.difficulty,
    );

    state = AsyncValue.data(newState);

    // If AI plays first, schedule move
    if (newState.gameMode == GameMode.vsComputer &&
        newState.currentPlayer == Player.x) {
      _scheduleAIMove();
    }
  }

  /// Changes game mode and restarts
  Future<void> changeGameMode(GameMode mode) async {
    _aiTimer?.cancel();

    final currentState = state.value;
    if (currentState == null) return;

    final newSettings = GameSettings(
      gameMode: mode,
      difficulty: currentState.difficulty,
    );

    await _saveSettingsUseCase(newSettings);

    final newState = GameState.initial(
      gameMode: mode,
      difficulty: currentState.difficulty,
    );

    state = AsyncValue.data(newState);
    await restartGame();
  }

  /// Changes difficulty and restarts
  Future<void> changeDifficulty(Difficulty difficulty) async {
    _aiTimer?.cancel();

    final currentState = state.value;
    if (currentState == null) return;

    final newSettings = GameSettings(
      gameMode: currentState.gameMode,
      difficulty: difficulty,
    );

    await _saveSettingsUseCase(newSettings);

    final newState = GameState.initial(
      gameMode: currentState.gameMode,
      difficulty: difficulty,
    );

    state = AsyncValue.data(newState);
    await restartGame();
  }

  /// Announces move for accessibility
  void _announceMove(int row, int col, Player player) {
    const rowNames = ['primeira linha', 'segunda linha', 'terceira linha'];
    const colNames = ['primeira coluna', 'segunda coluna', 'terceira coluna'];
    final message =
        '${player.symbol} jogou na ${rowNames[row]}, ${colNames[col]}';

    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announces game result for accessibility
  void _announceGameResult(GameState state) {
    final message = state.result.message;
    if (message.isNotEmpty) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }
}

/// Provider for game statistics
@riverpod
class TicTacToeStatsNotifier extends _$TicTacToeStatsNotifier {
  late final LoadStatsUseCase _loadStatsUseCase;
  late final ResetStatsUseCase _resetStatsUseCase;

  @override
  Future<GameStats> build() async {
    _loadStatsUseCase = ref.read(loadStatsUseCaseProvider);
    _resetStatsUseCase = ref.read(resetStatsUseCaseProvider);

    final result = await _loadStatsUseCase();

    return result.fold(
      (_) => const GameStats.empty(),
      (stats) => stats,
    );
  }

  /// Resets all statistics
  Future<void> resetStats() async {
    state = const AsyncValue.loading();

    final result = await _resetStatsUseCase();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) {
        state = const AsyncValue.data(GameStats.empty());
      },
    );
  }
}
