import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/high_score_entity.dart';
import 'game_2048_providers.dart';

part 'game_2048_notifier.g.dart';

@riverpod
class Game2048Notifier extends _$Game2048Notifier {
  HighScoreEntity _currentBestScore = HighScoreEntity.empty(BoardSize.size4x4);

  @override
  GameStateEntity build() {
    // Load high score and initialize game
    _loadHighScore();

    return GameStateEntity.initial(boardSize: BoardSize.size4x4);
  }

  /// Initializes a new game
  Future<void> initializeGame([BoardSize? boardSize]) async {
    final size = boardSize ?? BoardSize.size4x4;

    // Load high score for this board size
    await _loadHighScore(size);

    // Create new game
    final restartUseCase = ref.read(restartGameUseCaseProvider);
    final result = await restartUseCase.callWithNewSize(
      size,
      _currentBestScore.score,
    );

    result.fold(
      (failure) {
        // Handle error - keep current state
      },
      (newState) {
        state = newState;
      },
    );
  }

  /// Loads high score from storage
  Future<void> _loadHighScore([BoardSize? boardSize]) async {
    final size = boardSize ?? state.boardSize;

    final loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    final result = await loadHighScoreUseCase(size);

    result.fold(
      (failure) {
        _currentBestScore = HighScoreEntity.empty(size);
      },
      (highScore) {
        _currentBestScore = highScore;
        state = state.copyWith(bestScore: highScore.score);
      },
    );
  }

  /// Handles swipe/move in specified direction
  Future<void> move(Direction direction) async {
    // Only allow moves when playing
    if (state.status != GameStatus.playing) {
      return;
    }

    // Execute move
    final moveTilesUseCase = ref.read(moveTilesUseCaseProvider);
    final moveResult = await moveTilesUseCase(state, direction);

    await moveResult.fold(
      (failure) async {
        // Move failed - likely validation error
      },
      (movedState) async {
        // Check if board actually changed
        if (movedState.grid.tiles.length == state.grid.tiles.length) {
          final oldIds = state.grid.tiles.map((t) => t.id).toSet();
          final newIds = movedState.grid.tiles.map((t) => t.id).toSet();

          if (oldIds.difference(newIds).isEmpty &&
              newIds.difference(oldIds).isEmpty) {
            // No change - invalid move
            return;
          }
        }

        // Update state with moved tiles
        state = movedState;

        // Small delay for move animation
        await Future.delayed(const Duration(milliseconds: 150));

        // Clear animations
        state = state.copyWith(
          grid: state.grid.clearAnimations(),
        );

        // Spawn new tile
        final spawnTileUseCase = ref.read(spawnTileUseCaseProvider);
        final spawnResult = await spawnTileUseCase(state.grid);

        spawnResult.fold(
          (failure) {
            // Failed to spawn - grid might be full
          },
          (gridWithNewTile) {
            state = state.copyWith(grid: gridWithNewTile);
          },
        );

        // Small delay for spawn animation
        await Future.delayed(const Duration(milliseconds: 200));

        // Clear spawn animation
        state = state.copyWith(
          grid: state.grid.clearAnimations(),
        );

        // Check for win
        if (state.hasWon && state.status == GameStatus.playing) {
          state = state.markAsWon();
          await _saveCurrentScore();
          return;
        }

        // Check for game over
        final checkGameOverUseCase = ref.read(checkGameOverUseCaseProvider);
        final gameOverResult = await checkGameOverUseCase(state.grid);

        gameOverResult.fold(
          (failure) {
            // Error checking game over
          },
          (isGameOver) {
            if (isGameOver) {
              state = state.markAsGameOver();
              _saveCurrentScore();
            }
          },
        );
      },
    );
  }

  /// Restarts the game
  Future<void> restart() async {
    final restartUseCase = ref.read(restartGameUseCaseProvider);
    final result = await restartUseCase(state);

    result.fold(
      (failure) {
        // Handle error
      },
      (newState) {
        state = newState;
      },
    );
  }

  /// Changes board size and restarts
  Future<void> changeBoardSize(BoardSize newSize) async {
    await initializeGame(newSize);
  }

  /// Pauses the game
  void pauseGame() {
    if (state.status == GameStatus.playing) {
      state = state.pause();
    }
  }

  /// Resumes the game
  void resumeGame(Duration pauseDuration) {
    if (state.status == GameStatus.paused) {
      state = state.resume(pauseDuration);
    }
  }

  /// Continues game after win
  void continueAfterWin() {
    if (state.status == GameStatus.won) {
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  /// Saves current score if it's a high score
  Future<void> _saveCurrentScore() async {
    final currentScore = HighScoreEntity(
      score: state.score,
      moves: state.moves,
      duration: state.gameDuration,
      boardSize: state.boardSize,
      achievedAt: DateTime.now(),
    );

    final saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);
    final result = await saveHighScoreUseCase(
      currentScore,
      _currentBestScore,
    );

    result.fold(
      (failure) {
        // Error saving
      },
      (isNewHighScore) {
        if (isNewHighScore) {
          _currentBestScore = currentScore;
          state = state.copyWith(bestScore: currentScore.score);
        }
      },
    );
  }

  /// Checks if current score is a new high score
  bool get isNewHighScore => state.score > _currentBestScore.score;

  /// Updates score from external source (Flame game)
  void updateScore(int score) {
    state = state.copyWith(score: score);
    if (score > state.bestScore) {
      state = state.copyWith(bestScore: score);
    }
  }

  /// Marks game as over and saves score
  void gameOver() {
    state = state.markAsGameOver();
    _saveCurrentScore();
  }

  /// Marks game as won and saves score
  void win() {
    state = state.markAsWon();
    _saveCurrentScore();
  }
}
