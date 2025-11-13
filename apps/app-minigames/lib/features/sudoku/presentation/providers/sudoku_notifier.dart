import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/position_entity.dart';
import '../../domain/usecases/check_completion_usecase.dart';
import '../../domain/usecases/generate_puzzle_usecase.dart';
import '../../domain/usecases/get_hint_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/place_number_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/toggle_notes_usecase.dart';
import '../../domain/usecases/update_conflicts_usecase.dart';
import '../../domain/usecases/validate_move_usecase.dart';

part 'sudoku_notifier.g.dart';

@riverpod
class SudokuGame extends _$SudokuGame {
  Timer? _gameTimer;
  bool _isMounted = true;

  // Use cases injected via providers (TODO: implement in DI)
  late final GeneratePuzzleUseCase _generatePuzzleUseCase;
  late final PlaceNumberUseCase _placeNumberUseCase;
  late final ToggleNotesUseCase _toggleNotesUseCase;
  late final GetHintUseCase _getHintUseCase;
  late final CheckCompletionUseCase _checkCompletionUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  @override
  GameStateEntity build() {
    // Dispose timer on cleanup
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
    });

    // Initialize use cases (will be replaced with DI)
    _generatePuzzleUseCase = GeneratePuzzleUseCase();
    _placeNumberUseCase = PlaceNumberUseCase(
      ref.read(validateMoveUseCaseProvider),
      ref.read(updateConflictsUseCaseProvider),
    );
    _toggleNotesUseCase = ToggleNotesUseCase();
    _getHintUseCase = GetHintUseCase();
    _checkCompletionUseCase = CheckCompletionUseCase();

    // Return initial state
    return GameStateEntity.initial();
  }

  /// Start new game
  Future<void> startNewGame(GameDifficulty difficulty) async {
    // Generate puzzle
    final result = await _generatePuzzleUseCase(difficulty);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          status: GameStatus.initial,
        );
      },
      (grid) async {
        // Load high score
        final highScoreResult = await _loadHighScoreUseCase(difficulty);
        final highScore = highScoreResult.fold(
          (_) => null,
          (score) => score,
        );

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

    state = state.copyWith(
      grid: updatedGrid,
      selectedCell: position,
    );
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
      final result = _placeNumberUseCase(
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
    final updateConflicts = UpdateConflictsUseCase();
    updatedGrid = updateConflicts(updatedGrid);

    state = state.copyWith(grid: updatedGrid);
  }

  /// Toggle notes mode
  void toggleNotesMode() {
    state = state.copyWith(notesMode: !state.notesMode);
  }

  /// Toggle note on cell
  void _toggleNote(int row, int col, int note) {
    final result = _toggleNotesUseCase(
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

    final result = _getHintUseCase(state.grid);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (hint) {
        final position = hint.$1;
        final value = hint.$2;

        // Place hint value
        final placeResult = _placeNumberUseCase(
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
    final result = _checkCompletionUseCase(state.grid);

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

      await _saveHighScoreUseCase(updatedHighScore);

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

// TODO: Implement proper DI - temporary providers
@riverpod
UpdateConflictsUseCase updateConflictsUseCase(UpdateConflictsUseCaseRef ref) {
  return UpdateConflictsUseCase();
}

@riverpod
ValidateMoveUseCase validateMoveUseCase(ValidateMoveUseCaseRef ref) {
  return ValidateMoveUseCase();
}
