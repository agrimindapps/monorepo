import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connect_four_controller.g.dart';

@immutable
class ConnectFourState {
  final List<List<int>> board; // 0 = empty, 1 = p1, 2 = p2
  final int currentPlayer;
  final int? winner;
  final bool isDraw;
  final List<List<int>> winningLine; // coordinates of winning chips

  const ConnectFourState({
    this.board = const [],
    this.currentPlayer = 1,
    this.winner,
    this.isDraw = false,
    this.winningLine = const [],
  });

  // Initial 6 rows x 7 cols
  factory ConnectFourState.initial() {
    return ConnectFourState(
      board: List.generate(6, (_) => List.filled(7, 0)),
      currentPlayer: 1,
    );
  }

  ConnectFourState copyWith({
    List<List<int>>? board,
    int? currentPlayer,
    int? winner,
    bool? isDraw,
    List<List<int>>? winningLine,
  }) {
    return ConnectFourState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: winner ?? this.winner,
      isDraw: isDraw ?? this.isDraw,
      winningLine: winningLine ?? this.winningLine,
    );
  }
}

@riverpod
class ConnectFourController extends _$ConnectFourController {
  @override
  ConnectFourState build() {
    return ConnectFourState.initial();
  }

  void dropChip(int column) {
    if (state.winner != null || state.isDraw) return;
    
    // Find the first empty cell from bottom up
    int row = -1;
    for (int r = 5; r >= 0; r--) {
      if (state.board[r][column] == 0) {
        row = r;
        break;
      }
    }

    if (row == -1) return; // Column full

    // Create new board
    final newBoard = List<List<int>>.from(
      state.board.map((row) => List<int>.from(row)),
    );
    newBoard[row][column] = state.currentPlayer;

    state = state.copyWith(board: newBoard);
    
    _checkWin(row, column);
    
    if (state.winner == null) {
      // Switch player
      state = state.copyWith(
        currentPlayer: state.currentPlayer == 1 ? 2 : 1,
        // Check for draw if board is full
        isDraw: !newBoard.any((row) => row.any((cell) => cell == 0)),
      );
    }
  }

  void _checkWin(int row, int col) {
    final player = state.board[row][col];
    final board = state.board;

    // Directions: Horizontal, Vertical, Diagonal /, Diagonal \
    final directions = [
      [0, 1], [1, 0], [1, 1], [1, -1]
    ];

    for (final dir in directions) {
      final line = <List<int>>[[row, col]];
      
      // Check forward
      for (int i = 1; i < 4; i++) {
        final r = row + (dir[0] * i);
        final c = col + (dir[1] * i);
        if (r >= 0 && r < 6 && c >= 0 && c < 7 && board[r][c] == player) {
          line.add([r, c]);
        } else {
          break;
        }
      }
      
      // Check backward
      for (int i = 1; i < 4; i++) {
        final r = row - (dir[0] * i);
        final c = col - (dir[1] * i);
        if (r >= 0 && r < 6 && c >= 0 && c < 7 && board[r][c] == player) {
          line.add([r, c]);
        } else {
          break;
        }
      }

      if (line.length >= 4) {
        state = state.copyWith(
          winner: player,
          winningLine: line,
        );
        return;
      }
    }
  }

  void reset() {
    state = ConnectFourState.initial();
  }
}
