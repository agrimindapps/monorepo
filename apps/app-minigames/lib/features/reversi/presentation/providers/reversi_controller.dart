import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/reversi_entities.dart';

part 'reversi_controller.g.dart';

@immutable
class ReversiState {
  final List<List<ReversiPlayer?>> board;
  final ReversiPlayer currentPlayer;
  final Set<List<int>> validMoves;
  final bool isGameOver;
  final int blackCount;
  final int whiteCount;

  const ReversiState({
    required this.board,
    this.currentPlayer = ReversiPlayer.black,
    this.validMoves = const {},
    this.isGameOver = false,
    this.blackCount = 2,
    this.whiteCount = 2,
  });

  factory ReversiState.initial() {
    final board = List.generate(8, (_) => List<ReversiPlayer?>.filled(8, null));

    // Initial 4 pieces in center
    board[3][3] = ReversiPlayer.white;
    board[3][4] = ReversiPlayer.black;
    board[4][3] = ReversiPlayer.black;
    board[4][4] = ReversiPlayer.white;

    return ReversiState(board: board);
  }

  ReversiPlayer? get winner {
    if (!isGameOver) return null;
    if (blackCount > whiteCount) return ReversiPlayer.black;
    if (whiteCount > blackCount) return ReversiPlayer.white;
    return null; // Draw
  }

  ReversiState copyWith({
    List<List<ReversiPlayer?>>? board,
    ReversiPlayer? currentPlayer,
    Set<List<int>>? validMoves,
    bool? isGameOver,
    int? blackCount,
    int? whiteCount,
  }) {
    return ReversiState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      validMoves: validMoves ?? this.validMoves,
      isGameOver: isGameOver ?? this.isGameOver,
      blackCount: blackCount ?? this.blackCount,
      whiteCount: whiteCount ?? this.whiteCount,
    );
  }
}

@riverpod
class ReversiController extends _$ReversiController {
  // 8 directions: N, NE, E, SE, S, SW, W, NW
  static const List<List<int>> _directions = [
    [-1, 0], [-1, 1], [0, 1], [1, 1],
    [1, 0], [1, -1], [0, -1], [-1, -1],
  ];

  @override
  ReversiState build() {
    final initialState = ReversiState.initial();
    return initialState.copyWith(
      validMoves: _calculateValidMoves(initialState.board, initialState.currentPlayer),
    );
  }

  void makeMove(int row, int col) {
    if (state.isGameOver) return;
    if (!_isValidMove(row, col)) return;

    final newBoard = List.generate(
      8,
      (r) => List<ReversiPlayer?>.from(state.board[r]),
    );

    // Place piece
    newBoard[row][col] = state.currentPlayer;

    // Flip pieces in all directions
    for (final dir in _directions) {
      _flipInDirection(newBoard, row, col, dir[0], dir[1], state.currentPlayer);
    }

    // Count pieces
    int blackCount = 0;
    int whiteCount = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (newBoard[r][c] == ReversiPlayer.black) blackCount++;
        if (newBoard[r][c] == ReversiPlayer.white) whiteCount++;
      }
    }

    // Switch player
    var nextPlayer = state.currentPlayer.opponent;
    var validMoves = _calculateValidMoves(newBoard, nextPlayer);

    // If no valid moves, try other player
    if (validMoves.isEmpty) {
      nextPlayer = nextPlayer.opponent;
      validMoves = _calculateValidMoves(newBoard, nextPlayer);
    }

    // If still no valid moves, game is over
    final isGameOver = validMoves.isEmpty;

    state = ReversiState(
      board: newBoard,
      currentPlayer: nextPlayer,
      validMoves: validMoves,
      isGameOver: isGameOver,
      blackCount: blackCount,
      whiteCount: whiteCount,
    );
  }

  bool _isValidMove(int row, int col) {
    return state.validMoves.any((m) => m[0] == row && m[1] == col);
  }

  Set<List<int>> _calculateValidMoves(List<List<ReversiPlayer?>> board, ReversiPlayer player) {
    final moves = <List<int>>{};

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board[row][col] != null) continue;

        if (_wouldFlipAny(board, row, col, player)) {
          moves.add([row, col]);
        }
      }
    }

    return moves;
  }

  bool _wouldFlipAny(List<List<ReversiPlayer?>> board, int row, int col, ReversiPlayer player) {
    for (final dir in _directions) {
      if (_wouldFlipInDirection(board, row, col, dir[0], dir[1], player)) {
        return true;
      }
    }
    return false;
  }

  bool _wouldFlipInDirection(
    List<List<ReversiPlayer?>> board,
    int row,
    int col,
    int dRow,
    int dCol,
    ReversiPlayer player,
  ) {
    int r = row + dRow;
    int c = col + dCol;
    bool foundOpponent = false;

    while (r >= 0 && r < 8 && c >= 0 && c < 8) {
      final cell = board[r][c];

      if (cell == null) return false;
      if (cell == player) return foundOpponent;

      foundOpponent = true;
      r += dRow;
      c += dCol;
    }

    return false;
  }

  void _flipInDirection(
    List<List<ReversiPlayer?>> board,
    int row,
    int col,
    int dRow,
    int dCol,
    ReversiPlayer player,
  ) {
    if (!_wouldFlipInDirection(board, row, col, dRow, dCol, player)) return;

    int r = row + dRow;
    int c = col + dCol;

    while (board[r][c] != player) {
      board[r][c] = player;
      r += dRow;
      c += dCol;
    }
  }

  void reset() {
    final initialState = ReversiState.initial();
    state = initialState.copyWith(
      validMoves: _calculateValidMoves(initialState.board, initialState.currentPlayer),
    );
  }
}
