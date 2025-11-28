import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/move_history.dart';
import '../../domain/entities/position_entity.dart';
import '../../domain/entities/sudoku_statistics.dart';
import '../../data/models/sudoku_statistics_model.dart';
import 'sudoku_providers.dart';
import 'achievement_provider.dart';

part 'sudoku_notifier.g.dart';

@riverpod
class SudokuGame extends _$SudokuGame {
  Timer? _gameTimer;
  bool _isMounted = true;

  // Session stats for achievement tracking
  SudokuSessionStats _sessionStats = SudokuSessionStats.empty();

  // Store newly unlocked achievements for UI display
  List<dynamic> _newlyUnlockedAchievements = [];

  // Undo usage counter for achievements
  int _undoUsageCount = 0;

  @override
  GameStateEntity build() {
    // Dispose timer on cleanup
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
    });

    // Return initial state
    return GameStateEntity.initial();
  }

  /// Get newly unlocked achievements (call after game completion)
  List<dynamic> get newlyUnlockedAchievements => _newlyUnlockedAchievements;

  /// Clear newly unlocked achievements
  void clearNewlyUnlockedAchievements() {
    _newlyUnlockedAchievements = [];
  }

  /// Get current session stats
  SudokuSessionStats get sessionStats => _sessionStats;

  /// Get undo usage count
  int get undoUsageCount => _undoUsageCount;

  /// Start new game with mode
  Future<void> startNewGame(
    GameDifficulty difficulty, {
    SudokuGameMode gameMode = SudokuGameMode.classic,
  }) async {
    // Reset session stats
    _sessionStats = SudokuSessionStats.empty();
    _newlyUnlockedAchievements = [];
    _undoUsageCount = 0;

    // Update global stats - puzzle started
    await _incrementPuzzlesStarted(difficulty);

    // Generate puzzle
    final generatePuzzleUseCase = ref.read(generatePuzzleUseCaseProvider);
    final result = await generatePuzzleUseCase(difficulty);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          status: GameStatus.initial,
        );
      },
      (grid) async {
        // Load high score
        final loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
        final highScoreResult = await loadHighScoreUseCase(difficulty);
        final highScore = highScoreResult.fold((_) => null, (score) => score);

        // Calculate initial remaining time for TimeAttack
        final timeLimit = gameMode.getTimeLimit(difficulty);

        // Update state
        state = GameStateEntity(
          grid: grid,
          difficulty: difficulty,
          gameMode: gameMode,
          status: GameStatus.playing,
          moves: 0,
          mistakes: 0,
          elapsedTime: Duration.zero,
          notesMode: false,
          selectedCell: null,
          highScore: highScore,
          errorMessage: null,
          moveHistory: const MoveHistory(),
          remainingTime: timeLimit,
          livesRemaining: gameMode.maxMistakes ?? 3,
          speedRunPuzzlesCompleted: state.gameMode == SudokuGameMode.speedRun
              ? state.speedRunPuzzlesCompleted
              : 0,
          speedRunTotalTime: state.gameMode == SudokuGameMode.speedRun
              ? state.speedRunTotalTime
              : Duration.zero,
        );

        // Start timer
        _startTimer();
      },
    );
  }

  /// Select cell
  void selectCell(int row, int col) {
    if (!state.canInteract) return;

    final cell = state.grid.getCell(row, col);
    if (cell.isFixed) return; // Can't select fixed cells

    final position = PositionEntity(row: row, col: col);

    // Update cell states (highlight related cells)
    var updatedGrid = state.grid;

    // Clear previous highlights
    for (final c in updatedGrid.cells) {
      if (c.state.isHighlighted) {
        final clearedCell = c.copyWith(state: CellState.normal);
        updatedGrid = updatedGrid.updateCell(clearedCell);
      }
    }

    // Highlight selected cell
    final selectedCell = updatedGrid.getCell(row, col);
    final highlightedCell = selectedCell.copyWith(state: CellState.selected);
    updatedGrid = updatedGrid.updateCell(highlightedCell);

    // Highlight related cells (same row, col, block)
    final relatedCells = updatedGrid.getRelatedCells(position);
    for (final relatedCell in relatedCells) {
      final highlighted = relatedCell.copyWith(state: CellState.highlighted);
      updatedGrid = updatedGrid.updateCell(highlighted);
    }

    // Highlight cells with same number
    if (selectedCell.value != null) {
      for (final c in updatedGrid.cells) {
        if (c.value == selectedCell.value && c.position != position) {
          final sameNumberCell = c.copyWith(state: CellState.sameNumber);
          updatedGrid = updatedGrid.updateCell(sameNumberCell);
        }
      }
    }

    state = state.copyWith(grid: updatedGrid, selectedCell: position);
  }

  /// Place number on selected cell
  void placeNumber(int value) {
    if (!state.canInteract || state.selectedCell == null) return;

    final position = state.selectedCell!;
    final currentCell = state.grid.getCell(position.row, position.col);

    if (state.notesMode) {
      // Toggle note
      _toggleNote(position.row, position.col, value);
    } else {
      // Place number
      final placeNumberUseCase = ref.read(placeNumberUseCaseProvider);
      final result = placeNumberUseCase(
        grid: state.grid,
        row: position.row,
        col: position.col,
        value: value,
      );

      result.fold(
        (failure) {
          // Invalid move - increment mistakes
          _sessionStats = _sessionStats.copyWith(
            mistakesThisGame: _sessionStats.mistakesThisGame + 1,
          );

          // Handle Hardcore mode - lose a life
          final newLives = state.gameMode == SudokuGameMode.hardcore
              ? state.livesRemaining - 1
              : state.livesRemaining;

          state = state.copyWith(
            mistakes: state.mistakes + 1,
            errorMessage: failure.message,
            livesRemaining: newLives,
          );

          // Check for game over in Hardcore mode
          if (state.gameMode == SudokuGameMode.hardcore && newLives <= 0) {
            _onGameFailed(reason: 'Você ficou sem vidas!');
          }
        },
        (updatedGrid) {
          // Valid move - track cell filled and record move history
          _sessionStats = _sessionStats.copyWith(
            cellsFilledThisGame: _sessionStats.cellsFilledThisGame + 1,
          );

          // Create move for history
          final move = SudokuMove.placeNumber(
            position: position,
            previousValue: currentCell.value,
            newValue: value,
            previousNotes: currentCell.notes,
          );

          // Valid move
          state = state.copyWith(
            grid: updatedGrid,
            moves: state.moves + 1,
            moveHistory: state.moveHistory.addMove(move),
            clearError: true,
          );

          // Check completion
          _checkCompletion();
        },
      );
    }
  }

  /// Clear selected cell
  void clearCell() {
    if (!state.canInteract || state.selectedCell == null) return;

    final position = state.selectedCell!;
    final cell = state.grid.getCell(position.row, position.col);

    if (cell.isFixed || cell.isEmpty) return;

    // Record move before clearing
    final move = SudokuMove.clearCell(
      position: position,
      previousValue: cell.value!,
      previousNotes: cell.notes,
    );

    // Clear value
    final clearedCell = cell.copyWith(clearValue: true, notes: const {});
    var updatedGrid = state.grid.updateCell(clearedCell);

    // Update conflicts
    final updateConflicts = ref.read(updateConflictsUseCaseProvider);
    updatedGrid = updateConflicts(updatedGrid);

    state = state.copyWith(
      grid: updatedGrid,
      moveHistory: state.moveHistory.addMove(move),
    );
  }

  /// Toggle notes mode
  void toggleNotesMode() {
    if (!_sessionStats.usedNotesMode) {
      _sessionStats = _sessionStats.copyWith(usedNotesMode: true);
    }
    state = state.copyWith(notesMode: !state.notesMode);
  }

  /// Toggle note on cell
  void _toggleNote(int row, int col, int note) {
    final position = PositionEntity(row: row, col: col);
    final currentCell = state.grid.getCell(row, col);

    final toggleNotesUseCase = ref.read(toggleNotesUseCaseProvider);
    final result = toggleNotesUseCase(
      grid: state.grid,
      row: row,
      col: col,
      note: note,
    );

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (updatedGrid) {
        // Get updated cell to see new notes
        final updatedCell = updatedGrid.getCell(row, col);

        // Create move for history
        final move = SudokuMove.toggleNote(
          position: position,
          note: note,
          previousNotes: currentCell.notes,
          newNotes: updatedCell.notes,
        );

        // Track note placed
        _sessionStats = _sessionStats.copyWith(
          notesPlacedThisGame: _sessionStats.notesPlacedThisGame + 1,
          usedNotesMode: true,
        );
        state = state.copyWith(
          grid: updatedGrid,
          moveHistory: state.moveHistory.addMove(move),
          clearError: true,
        );
      },
    );
  }

  /// Get hint
  void getHint() {
    if (!state.canUseHint) return;

    // Track hint used
    _sessionStats = _sessionStats.copyWith(
      hintsUsedThisGame: _sessionStats.hintsUsedThisGame + 1,
    );

    final getHintUseCase = ref.read(getHintUseCaseProvider);
    final result = getHintUseCase(state.grid);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (hint) {
        final position = hint.$1;
        final value = hint.$2;
        final currentCell = state.grid.getCell(position.row, position.col);

        // Place hint value
        final placeNumberUseCase = ref.read(placeNumberUseCaseProvider);
        final placeResult = placeNumberUseCase(
          grid: state.grid,
          row: position.row,
          col: position.col,
          value: value,
        );

        placeResult.fold(
          (failure) {
            state = state.copyWith(errorMessage: failure.message);
          },
          (updatedGrid) {
            // Create hint move for history
            final move = SudokuMove.hint(
              position: position,
              previousValue: currentCell.value,
              hintValue: value,
              previousNotes: currentCell.notes,
            );

            state = state.copyWith(
              grid: updatedGrid,
              moves: state.moves + 1,
              selectedCell: position,
              moveHistory: state.moveHistory.addMove(move),
              clearError: true,
            );

            // Check completion
            _checkCompletion();
          },
        );
      },
    );
  }

  /// Undo last move
  void undo() {
    if (!state.canUndo || !state.canInteract) return;

    final (newHistory, move) = state.moveHistory.undo();
    if (move == null) return;

    _undoUsageCount++;

    // Apply the reverse of the move
    var updatedGrid = state.grid;
    final cell = updatedGrid.getCell(move.position.row, move.position.col);

    // Restore previous state
    final restoredCell = cell.copyWith(
      value: move.previousValue,
      clearValue: move.previousValue == null,
      notes: move.previousNotes,
    );
    updatedGrid = updatedGrid.updateCell(restoredCell);

    // Update conflicts
    final updateConflicts = ref.read(updateConflictsUseCaseProvider);
    updatedGrid = updateConflicts(updatedGrid);

    state = state.copyWith(
      grid: updatedGrid,
      moveHistory: newHistory,
      moves: (state.moves - 1).clamp(0, state.moves),
    );
  }

  /// Redo last undone move
  void redo() {
    if (!state.canRedo || !state.canInteract) return;

    final (newHistory, move) = state.moveHistory.redo();
    if (move == null) return;

    // Apply the move again
    var updatedGrid = state.grid;
    final cell = updatedGrid.getCell(move.position.row, move.position.col);

    // Apply new state
    final updatedCell = cell.copyWith(
      value: move.newValue,
      clearValue: move.newValue == null,
      notes: move.newNotes,
    );
    updatedGrid = updatedGrid.updateCell(updatedCell);

    // Update conflicts
    final updateConflicts = ref.read(updateConflictsUseCaseProvider);
    updatedGrid = updateConflicts(updatedGrid);

    state = state.copyWith(
      grid: updatedGrid,
      moveHistory: newHistory,
      moves: state.moves + 1,
    );

    // Check completion after redo
    _checkCompletion();
  }

  /// Pause game
  void pauseGame() {
    if (state.isPlaying) {
      _gameTimer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  /// Resume game
  void resumeGame() {
    if (state.isPaused) {
      state = state.copyWith(status: GameStatus.playing);
      _startTimer();
    }
  }

  /// Restart game (same mode and difficulty)
  Future<void> restartGame() async {
    await startNewGame(state.difficulty, gameMode: state.gameMode);
  }

  /// Continue SpeedRun with next puzzle
  Future<void> continueSpeedRun() async {
    if (state.gameMode != SudokuGameMode.speedRun) return;

    // Save time from current puzzle
    final newTotalTime = state.speedRunTotalTime + state.elapsedTime;
    final newCompleted = state.speedRunPuzzlesCompleted + 1;

    // Check if SpeedRun is complete
    if (newCompleted >= state.gameMode.speedRunPuzzleCount) {
      // SpeedRun finished!
      state = state.copyWith(
        speedRunPuzzlesCompleted: newCompleted,
        speedRunTotalTime: newTotalTime,
        status: GameStatus.completed,
      );
      await _onGameComplete();
      return;
    }

    // Generate next puzzle
    _gameTimer?.cancel();

    final generatePuzzleUseCase = ref.read(generatePuzzleUseCaseProvider);
    final result = await generatePuzzleUseCase(state.difficulty);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (grid) {
        state = state.copyWith(
          grid: grid,
          status: GameStatus.playing,
          moves: 0,
          mistakes: 0,
          elapsedTime: Duration.zero,
          notesMode: false,
          selectedCell: null,
          errorMessage: null,
          moveHistory: const MoveHistory(),
          speedRunPuzzlesCompleted: newCompleted,
          speedRunTotalTime: newTotalTime,
        );
        _startTimer();
      },
    );
  }

  /// Check if puzzle is complete
  void _checkCompletion() {
    final checkCompletionUseCase = ref.read(checkCompletionUseCaseProvider);
    final result = checkCompletionUseCase(state.grid);

    result.fold(
      (_) {}, // Ignore errors
      (isComplete) {
        if (isComplete) {
          // For SpeedRun, continue to next puzzle
          if (state.gameMode == SudokuGameMode.speedRun &&
              state.speedRunPuzzlesCompleted <
                  state.gameMode.speedRunPuzzleCount - 1) {
            continueSpeedRun();
          } else {
            _onGameComplete();
          }
        }
      },
    );
  }

  /// Handle game failure (TimeAttack timeout, Hardcore out of lives)
  Future<void> _onGameFailed({required String reason}) async {
    _gameTimer?.cancel();
    state = state.copyWith(
      status: GameStatus.failed,
      errorMessage: reason,
    );
  }

  /// Handle game completion
  Future<void> _onGameComplete() async {
    _gameTimer?.cancel();

    state = state.copyWith(status: GameStatus.completed);

    // Update high score if applicable
    if (state.highScore != null) {
      final updatedHighScore = state.highScore!.updateWithGame(
        timeInSeconds: state.elapsedTime.inSeconds,
        mistakes: state.mistakes,
      );

      final saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);
      await saveHighScoreUseCase(updatedHighScore);

      state = state.copyWith(highScore: updatedHighScore);
    }

    // Update global statistics
    await _updateStatisticsOnCompletion();

    // Process achievements
    await _processAchievements();
  }

  /// Update statistics on game completion
  Future<void> _updateStatisticsOnCompletion() async {
    try {
      final dataSource = ref.read(sudokuLocalDataSourceProvider);
      final currentStats = await dataSource.loadStatistics();

      // Get difficulty-specific stats
      final diffStats = currentStats.getStatsForDifficulty(state.difficulty);

      // Update difficulty stats
      final newStreak = diffStats.currentStreak + 1;
      final updatedDiffStats = diffStats.copyWith(
        puzzlesCompleted: diffStats.puzzlesCompleted + 1,
        bestTimeSeconds: diffStats.bestTimeSeconds == 0
            ? state.elapsedTime.inSeconds
            : (state.elapsedTime.inSeconds < diffStats.bestTimeSeconds
                ? state.elapsedTime.inSeconds
                : diffStats.bestTimeSeconds),
        totalMistakes: diffStats.totalMistakes + _sessionStats.mistakesThisGame,
        perfectGames: diffStats.perfectGames +
            (_sessionStats.isPerfectGame ? 1 : 0),
        noHintGames: diffStats.noHintGames +
            (_sessionStats.isNoHintGame ? 1 : 0),
        currentStreak: newStreak,
        bestStreak: newStreak > diffStats.bestStreak
            ? newStreak
            : diffStats.bestStreak,
      );

      // Update global streak
      final newGlobalStreak = currentStats.currentStreak + 1;

      // Build updated stats based on difficulty
      SudokuStatistics updatedStats;
      switch (state.difficulty) {
        case GameDifficulty.easy:
          updatedStats = currentStats.copyWith(
            easyStats: updatedDiffStats,
            totalPuzzlesCompleted: currentStats.totalPuzzlesCompleted + 1,
            totalCellsFilled: currentStats.totalCellsFilled +
                _sessionStats.cellsFilledThisGame,
            totalMistakes: currentStats.totalMistakes +
                _sessionStats.mistakesThisGame,
            totalHintsUsed: currentStats.totalHintsUsed +
                _sessionStats.hintsUsedThisGame,
            totalNotesPlaced: currentStats.totalNotesPlaced +
                _sessionStats.notesPlacedThisGame,
            totalSecondsPlayed: currentStats.totalSecondsPlayed +
                state.elapsedTime.inSeconds,
            perfectGames: currentStats.perfectGames +
                (_sessionStats.isPerfectGame ? 1 : 0),
            noHintGames: currentStats.noHintGames +
                (_sessionStats.isNoHintGame ? 1 : 0),
            perfectNoHintGames: currentStats.perfectNoHintGames +
                (_sessionStats.isPerfectNoHintGame ? 1 : 0),
            currentStreak: newGlobalStreak,
            bestStreak: newGlobalStreak > currentStats.bestStreak
                ? newGlobalStreak
                : currentStats.bestStreak,
            lastPlayedAt: DateTime.now(),
          );
          break;
        case GameDifficulty.medium:
          updatedStats = currentStats.copyWith(
            mediumStats: updatedDiffStats,
            totalPuzzlesCompleted: currentStats.totalPuzzlesCompleted + 1,
            totalCellsFilled: currentStats.totalCellsFilled +
                _sessionStats.cellsFilledThisGame,
            totalMistakes: currentStats.totalMistakes +
                _sessionStats.mistakesThisGame,
            totalHintsUsed: currentStats.totalHintsUsed +
                _sessionStats.hintsUsedThisGame,
            totalNotesPlaced: currentStats.totalNotesPlaced +
                _sessionStats.notesPlacedThisGame,
            totalSecondsPlayed: currentStats.totalSecondsPlayed +
                state.elapsedTime.inSeconds,
            perfectGames: currentStats.perfectGames +
                (_sessionStats.isPerfectGame ? 1 : 0),
            noHintGames: currentStats.noHintGames +
                (_sessionStats.isNoHintGame ? 1 : 0),
            perfectNoHintGames: currentStats.perfectNoHintGames +
                (_sessionStats.isPerfectNoHintGame ? 1 : 0),
            currentStreak: newGlobalStreak,
            bestStreak: newGlobalStreak > currentStats.bestStreak
                ? newGlobalStreak
                : currentStats.bestStreak,
            lastPlayedAt: DateTime.now(),
          );
          break;
        case GameDifficulty.hard:
          updatedStats = currentStats.copyWith(
            hardStats: updatedDiffStats,
            totalPuzzlesCompleted: currentStats.totalPuzzlesCompleted + 1,
            totalCellsFilled: currentStats.totalCellsFilled +
                _sessionStats.cellsFilledThisGame,
            totalMistakes: currentStats.totalMistakes +
                _sessionStats.mistakesThisGame,
            totalHintsUsed: currentStats.totalHintsUsed +
                _sessionStats.hintsUsedThisGame,
            totalNotesPlaced: currentStats.totalNotesPlaced +
                _sessionStats.notesPlacedThisGame,
            totalSecondsPlayed: currentStats.totalSecondsPlayed +
                state.elapsedTime.inSeconds,
            perfectGames: currentStats.perfectGames +
                (_sessionStats.isPerfectGame ? 1 : 0),
            noHintGames: currentStats.noHintGames +
                (_sessionStats.isNoHintGame ? 1 : 0),
            perfectNoHintGames: currentStats.perfectNoHintGames +
                (_sessionStats.isPerfectNoHintGame ? 1 : 0),
            currentStreak: newGlobalStreak,
            bestStreak: newGlobalStreak > currentStats.bestStreak
                ? newGlobalStreak
                : currentStats.bestStreak,
            lastPlayedAt: DateTime.now(),
          );
          break;
      }

      // Save updated stats
      final statsModel = SudokuStatisticsModel.fromEntity(updatedStats);
      await dataSource.saveStatistics(statsModel);
    } catch (e) {
      // Silently fail - stats are not critical
    }
  }

  /// Process achievements on game completion
  Future<void> _processAchievements() async {
    try {
      final dataSource = ref.read(sudokuLocalDataSourceProvider);
      final stats = await dataSource.loadStatistics();

      final newlyUnlocked = await ref
          .read(sudokuAchievementsProvider.notifier)
          .processEndGame(
            difficulty: state.difficulty,
            sessionStats: _sessionStats,
            stats: stats,
            won: true,
            gameTimeSeconds: state.elapsedTime.inSeconds,
          );

      _newlyUnlockedAchievements = newlyUnlocked;
    } catch (e) {
      // Silently fail - achievements are not critical
    }
  }

  /// Increment puzzles started counter
  Future<void> _incrementPuzzlesStarted(GameDifficulty difficulty) async {
    try {
      final dataSource = ref.read(sudokuLocalDataSourceProvider);
      final currentStats = await dataSource.loadStatistics();

      // Get difficulty-specific stats
      final diffStats = currentStats.getStatsForDifficulty(difficulty);
      final updatedDiffStats = diffStats.copyWith(
        puzzlesStarted: diffStats.puzzlesStarted + 1,
      );

      // Build updated stats based on difficulty
      SudokuStatistics updatedStats;
      switch (difficulty) {
        case GameDifficulty.easy:
          updatedStats = currentStats.copyWith(
            easyStats: updatedDiffStats,
            totalPuzzlesStarted: currentStats.totalPuzzlesStarted + 1,
          );
          break;
        case GameDifficulty.medium:
          updatedStats = currentStats.copyWith(
            mediumStats: updatedDiffStats,
            totalPuzzlesStarted: currentStats.totalPuzzlesStarted + 1,
          );
          break;
        case GameDifficulty.hard:
          updatedStats = currentStats.copyWith(
            hardStats: updatedDiffStats,
            totalPuzzlesStarted: currentStats.totalPuzzlesStarted + 1,
          );
          break;
      }

      final statsModel = SudokuStatisticsModel.fromEntity(updatedStats);
      await dataSource.saveStatistics(statsModel);
    } catch (e) {
      // Silently fail
    }
  }

  /// Start game timer
  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isMounted) return;

      if (state.isPlaying) {
        if (!_isMounted) return;

        // Update elapsed time (always)
        final newElapsed = state.elapsedTime + const Duration(seconds: 1);

        // For TimeAttack mode, also decrement remaining time
        if (state.gameMode == SudokuGameMode.timeAttack &&
            state.remainingTime != null) {
          final newRemaining = state.remainingTime! - 1;

          if (newRemaining <= 0) {
            // Time's up!
            state = state.copyWith(
              elapsedTime: newElapsed,
              remainingTime: 0,
            );
            _onGameFailed(reason: 'Tempo esgotado!');
            return;
          }

          state = state.copyWith(
            elapsedTime: newElapsed,
            remainingTime: newRemaining,
          );
        } else {
          state = state.copyWith(
            elapsedTime: newElapsed,
          );
        }
      }
    });
  }
}
