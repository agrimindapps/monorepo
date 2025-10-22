import 'package:equatable/equatable.dart';
import 'cell_data.dart';
import 'enums.dart';

/// Immutable entity representing the complete state of the Campo Minado game
class GameState extends Equatable {
  final List<List<CellData>> grid;
  final GameStatus status;
  final Difficulty difficulty;
  final GameConfig config;
  final int timeSeconds;
  final int flaggedCells;
  final int revealedCells;
  final bool isPaused;
  final bool isFirstClick;

  const GameState({
    required this.grid,
    required this.status,
    required this.difficulty,
    required this.config,
    required this.timeSeconds,
    required this.flaggedCells,
    required this.revealedCells,
    required this.isPaused,
    required this.isFirstClick,
  });

  /// Factory constructor for initial game state
  factory GameState.initial({
    Difficulty difficulty = Difficulty.beginner,
    GameConfig? customConfig,
  }) {
    final config = customConfig ?? difficulty.config;

    // Create empty grid
    final grid = List.generate(
      config.rows,
      (row) => List.generate(
        config.cols,
        (col) => CellData.initial(row: row, col: col),
      ),
    );

    return GameState(
      grid: grid,
      status: GameStatus.ready,
      difficulty: difficulty,
      config: config,
      timeSeconds: 0,
      flaggedCells: 0,
      revealedCells: 0,
      isPaused: false,
      isFirstClick: true,
    );
  }

  // Helper computed properties
  bool get isGameOver => status.isGameOver;
  bool get isPlaying => status.isPlaying;
  bool get canInteract => !isGameOver && !isPaused;
  int get remainingMines => config.mines - flaggedCells;
  int get rows => config.rows;
  int get cols => config.cols;

  /// Formats time as MM:SS
  String get formattedTime {
    final minutes = timeSeconds ~/ 60;
    final seconds = timeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Gets cell at position
  CellData? getCellAt(int row, int col) {
    if (row < 0 || row >= config.rows || col < 0 || col >= config.cols) {
      return null;
    }
    return grid[row][col];
  }

  /// Gets valid neighbor positions
  List<List<int>> getNeighborPositions(int row, int col) {
    final neighbors = <List<int>>[];

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final newRow = row + dr;
        final newCol = col + dc;

        if (newRow >= 0 &&
            newRow < config.rows &&
            newCol >= 0 &&
            newCol < config.cols) {
          neighbors.add([newRow, newCol]);
        }
      }
    }

    return neighbors;
  }

  /// Creates a copy with updated fields
  GameState copyWith({
    List<List<CellData>>? grid,
    GameStatus? status,
    Difficulty? difficulty,
    GameConfig? config,
    int? timeSeconds,
    int? flaggedCells,
    int? revealedCells,
    bool? isPaused,
    bool? isFirstClick,
  }) {
    return GameState(
      grid: grid ?? this.grid.map((row) => row.toList()).toList(),
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      config: config ?? this.config,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      flaggedCells: flaggedCells ?? this.flaggedCells,
      revealedCells: revealedCells ?? this.revealedCells,
      isPaused: isPaused ?? this.isPaused,
      isFirstClick: isFirstClick ?? this.isFirstClick,
    );
  }

  @override
  List<Object?> get props => [
        grid,
        status,
        difficulty,
        config,
        timeSeconds,
        flaggedCells,
        revealedCells,
        isPaused,
        isFirstClick,
      ];
}
