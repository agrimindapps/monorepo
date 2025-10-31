import 'package:injectable/injectable.dart';

import '../entities/enums.dart';

/// Service responsible for game result validation
///
/// Handles:
/// - Win condition checking (rows, columns, diagonals)
/// - Draw detection
/// - Winning line calculation
/// - Game status determination
@lazySingleton
class GameResultValidationService {
  GameResultValidationService();

  // ============================================================================
  // Win Detection
  // ============================================================================

  /// Checks if a player has won
  bool hasPlayerWon({
    required List<List<Player>> board,
    required Player player,
  }) {
    return _checkRows(board, player) ||
        _checkColumns(board, player) ||
        _checkDiagonals(board, player);
  }

  /// Checks if any player has won
  WinCheckResult checkForWinner(List<List<Player>> board) {
    // Check for X win
    if (hasPlayerWon(board: board, player: Player.x)) {
      final winningLine = getWinningLine(board, Player.x);
      return WinCheckResult(
        hasWinner: true,
        winner: Player.x,
        result: GameResult.xWins,
        winningLine: winningLine,
      );
    }

    // Check for O win
    if (hasPlayerWon(board: board, player: Player.o)) {
      final winningLine = getWinningLine(board, Player.o);
      return WinCheckResult(
        hasWinner: true,
        winner: Player.o,
        result: GameResult.oWins,
        winningLine: winningLine,
      );
    }

    return WinCheckResult(
      hasWinner: false,
      winner: Player.none,
      result: GameResult.inProgress,
      winningLine: null,
    );
  }

  // ============================================================================
  // Row Checking
  // ============================================================================

  /// Checks all rows for a winner
  bool _checkRows(List<List<Player>> board, Player player) {
    for (int i = 0; i < 3; i++) {
      if (_isRowWin(board, i, player)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a specific row is a win
  bool _isRowWin(List<List<Player>> board, int row, Player player) {
    return board[row][0] == player &&
        board[row][1] == player &&
        board[row][2] == player;
  }

  /// Gets winning row index
  int? _getWinningRow(List<List<Player>> board, Player player) {
    for (int i = 0; i < 3; i++) {
      if (_isRowWin(board, i, player)) {
        return i;
      }
    }
    return null;
  }

  // ============================================================================
  // Column Checking
  // ============================================================================

  /// Checks all columns for a winner
  bool _checkColumns(List<List<Player>> board, Player player) {
    for (int i = 0; i < 3; i++) {
      if (_isColumnWin(board, i, player)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a specific column is a win
  bool _isColumnWin(List<List<Player>> board, int col, Player player) {
    return board[0][col] == player &&
        board[1][col] == player &&
        board[2][col] == player;
  }

  /// Gets winning column index
  int? _getWinningColumn(List<List<Player>> board, Player player) {
    for (int i = 0; i < 3; i++) {
      if (_isColumnWin(board, i, player)) {
        return i;
      }
    }
    return null;
  }

  // ============================================================================
  // Diagonal Checking
  // ============================================================================

  /// Checks both diagonals for a winner
  bool _checkDiagonals(List<List<Player>> board, Player player) {
    return _isMainDiagonalWin(board, player) ||
        _isSecondaryDiagonalWin(board, player);
  }

  /// Checks main diagonal (top-left to bottom-right)
  bool _isMainDiagonalWin(List<List<Player>> board, Player player) {
    return board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == player;
  }

  /// Checks secondary diagonal (top-right to bottom-left)
  bool _isSecondaryDiagonalWin(List<List<Player>> board, Player player) {
    return board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == player;
  }

  // ============================================================================
  // Winning Line Detection
  // ============================================================================

  /// Gets the indices of the winning line
  List<int>? getWinningLine(List<List<Player>> board, Player player) {
    // Check rows
    final rowIndex = _getWinningRow(board, player);
    if (rowIndex != null) {
      return [rowIndex * 3, rowIndex * 3 + 1, rowIndex * 3 + 2];
    }

    // Check columns
    final colIndex = _getWinningColumn(board, player);
    if (colIndex != null) {
      return [colIndex, colIndex + 3, colIndex + 6];
    }

    // Check main diagonal
    if (_isMainDiagonalWin(board, player)) {
      return [0, 4, 8];
    }

    // Check secondary diagonal
    if (_isSecondaryDiagonalWin(board, player)) {
      return [2, 4, 6];
    }

    return null;
  }

  // ============================================================================
  // Draw Detection
  // ============================================================================

  /// Checks if the board is full
  bool isBoardFull(List<List<Player>> board) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          return false;
        }
      }
    }
    return true;
  }

  /// Checks if the game is a draw
  bool isDraw(List<List<Player>> board) {
    return isBoardFull(board) &&
        !hasPlayerWon(board: board, player: Player.x) &&
        !hasPlayerWon(board: board, player: Player.o);
  }

  // ============================================================================
  // Complete Game Result
  // ============================================================================

  /// Gets complete game result
  GameResultAnalysis analyzeGameResult(List<List<Player>> board) {
    // Check for winner
    final winCheck = checkForWinner(board);

    if (winCheck.hasWinner) {
      return GameResultAnalysis(
        result: winCheck.result,
        hasWinner: true,
        winner: winCheck.winner,
        winningLine: winCheck.winningLine,
        isDraw: false,
        isInProgress: false,
      );
    }

    // Check for draw
    if (isDraw(board)) {
      return GameResultAnalysis(
        result: GameResult.draw,
        hasWinner: false,
        winner: Player.none,
        winningLine: null,
        isDraw: true,
        isInProgress: false,
      );
    }

    // Game still in progress
    return GameResultAnalysis(
      result: GameResult.inProgress,
      hasWinner: false,
      winner: Player.none,
      winningLine: null,
      isDraw: false,
      isInProgress: true,
    );
  }

  // ============================================================================
  // Move Validation
  // ============================================================================

  /// Checks if a move would result in a win
  bool wouldMoveWin({
    required List<List<Player>> board,
    required int row,
    required int col,
    required Player player,
  }) {
    // Create test board
    final testBoard = List.generate(
      3,
      (i) => List<Player>.from(board[i]),
    );
    testBoard[row][col] = player;

    return hasPlayerWon(board: testBoard, player: player);
  }

  /// Checks if cell is empty
  bool isCellEmpty({
    required List<List<Player>> board,
    required int row,
    required int col,
  }) {
    return board[row][col] == Player.none;
  }

  /// Validates position bounds
  bool isValidPosition({required int row, required int col}) {
    return row >= 0 && row < 3 && col >= 0 && col < 3;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets board statistics
  BoardStatistics getStatistics(List<List<Player>> board) {
    int xCount = 0;
    int oCount = 0;
    int emptyCount = 0;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        switch (board[i][j]) {
          case Player.x:
            xCount++;
            break;
          case Player.o:
            oCount++;
            break;
          case Player.none:
            emptyCount++;
            break;
        }
      }
    }

    final totalMoves = xCount + oCount;
    final progress = totalMoves / 9.0;

    return BoardStatistics(
      xCount: xCount,
      oCount: oCount,
      emptyCount: emptyCount,
      totalMoves: totalMoves,
      progress: progress,
      isFull: emptyCount == 0,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Win check result
class WinCheckResult {
  final bool hasWinner;
  final Player winner;
  final GameResult result;
  final List<int>? winningLine;

  const WinCheckResult({
    required this.hasWinner,
    required this.winner,
    required this.result,
    required this.winningLine,
  });
}

/// Game result analysis
class GameResultAnalysis {
  final GameResult result;
  final bool hasWinner;
  final Player winner;
  final List<int>? winningLine;
  final bool isDraw;
  final bool isInProgress;

  const GameResultAnalysis({
    required this.result,
    required this.hasWinner,
    required this.winner,
    required this.winningLine,
    required this.isDraw,
    required this.isInProgress,
  });

  /// Gets result message
  String get message => result.message;

  /// Checks if game is over
  bool get isGameOver => hasWinner || isDraw;
}

/// Board statistics
class BoardStatistics {
  final int xCount;
  final int oCount;
  final int emptyCount;
  final int totalMoves;
  final double progress;
  final bool isFull;

  const BoardStatistics({
    required this.xCount,
    required this.oCount,
    required this.emptyCount,
    required this.totalMoves,
    required this.progress,
    required this.isFull,
  });

  /// Gets progress as percentage
  double get progressPercentage => progress * 100;

  /// Checks if board is empty
  bool get isEmpty => totalMoves == 0;

  /// Gets turn balance (who has more moves)
  int get turnBalance => xCount - oCount;
}
