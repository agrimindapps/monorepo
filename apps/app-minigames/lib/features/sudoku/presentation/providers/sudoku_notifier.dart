import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/position_entity.dart';
import 'sudoku_providers.dart';

part 'sudoku_notifier.g.dart';

@riverpod
class SudokuGame extends _$SudokuGame {
  Timer? _gameTimer;
  bool _isMounted = true;

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

  /// Start new game
  Future<void> startNewGame(GameDifficulty difficulty) async {
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

        // Update state
        state = GameStateEntity(
          grid: grid,
          difficulty: difficulty,
          status: GameStatus.playing,
          moves: 0,
          mistakes: 0,
          elapsedTime: Duration.zero,
          notesMode: false,
          selectedCell: null,
          highScore: highScore,
          errorMessage: null,
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
          state = state.copyWith(
            mistakes: state.mistakes + 1,
            errorMessage: failure.message,
          );
        },
        (updatedGrid) {
          // Valid move
          state = state.copyWith(
            grid: updatedGrid,
            moves: state.moves + 1,
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

    if (cell.isFixed) return;

    // Clear value
    final clearedCell = cell.copyWith(clearValue: true);
    var updatedGrid = state.grid.updateCell(clearedCell);

    // Update conflicts
    final updateConflicts = ref.read(updateConflictsUseCaseProvider);
    updatedGrid = updateConflicts(updatedGrid);

    state = state.copyWith(grid: updatedGrid);
  }

  /// Toggle notes mode
  void toggleNotesMode() {
    state = state.copyWith(notesMode: !state.notesMode);
  }

  /// Toggle note on cell
  void _toggleNote(int row, int col, int note) {
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
        state = state.copyWith(grid: updatedGrid, clearError: true);
      },
    );
  }

  /// Get hint
  void getHint() {
    if (!state.canUseHint) return;

    final getHintUseCase = ref.read(getHintUseCaseProvider);
    final result = getHintUseCase(state.grid);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (hint) {
        final position = hint.$1;
        final value = hint.$2;

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
            state = state.copyWith(
              grid: updatedGrid,
              moves: state.moves + 1,
              selectedCell: position,
              clearError: true,
            );

            // Check completion
            _checkCompletion();
          },
        );
      },
    );
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

  /// Restart game
  Future<void> restartGame() async {
    await startNewGame(state.difficulty);
  }

  /// Check if puzzle is complete
  void _checkCompletion() {
    final checkCompletionUseCase = ref.read(checkCompletionUseCaseProvider);
    final result = checkCompletionUseCase(state.grid);

    result.fold(
      (_) {}, // Ignore errors
      (isComplete) {
        if (isComplete) {
          _onGameComplete();
        }
      },
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
  }

  /// Start game timer
  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isMounted) return;

      if (state.isPlaying) {
        if (!_isMounted) return;
        state = state.copyWith(
          elapsedTime: state.elapsedTime + const Duration(seconds: 1),
        );
      }
    });
  }
}
