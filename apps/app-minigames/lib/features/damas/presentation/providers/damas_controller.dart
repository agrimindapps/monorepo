import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/damas_entities.dart';

part 'damas_controller.g.dart';

@immutable
class DamasState {
  final List<List<Piece?>> board;
  final Player currentPlayer;
  final Position? selectedPosition;
  final List<Move> validMoves;
  final Player? winner;
  final bool mustContinueCapture;
  final int redCount;
  final int blackCount;

  const DamasState({
    required this.board,
    this.currentPlayer = Player.red,
    this.selectedPosition,
    this.validMoves = const [],
    this.winner,
    this.mustContinueCapture = false,
    this.redCount = 12,
    this.blackCount = 12,
  });

  factory DamasState.initial() {
    final board = List.generate(8, (row) {
      return List.generate(8, (col) {
        // Only place pieces on dark squares
        if ((row + col) % 2 == 1) {
          if (row < 3) {
            return const Piece(player: Player.black);
          } else if (row > 4) {
            return const Piece(player: Player.red);
          }
        }
        return null;
      });
    });

    return DamasState(board: board);
  }

  DamasState copyWith({
    List<List<Piece?>>? board,
    Player? currentPlayer,
    Position? selectedPosition,
    List<Move>? validMoves,
    Player? winner,
    bool? mustContinueCapture,
    int? redCount,
    int? blackCount,
    bool clearSelection = false,
  }) {
    return DamasState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      selectedPosition: clearSelection ? null : (selectedPosition ?? this.selectedPosition),
      validMoves: validMoves ?? this.validMoves,
      winner: winner ?? this.winner,
      mustContinueCapture: mustContinueCapture ?? this.mustContinueCapture,
      redCount: redCount ?? this.redCount,
      blackCount: blackCount ?? this.blackCount,
    );
  }
}

@riverpod
class DamasController extends _$DamasController {
  @override
  DamasState build() => DamasState.initial();

  void selectPosition(Position pos) {
    final piece = state.board[pos.row][pos.col];

    // If we must continue capturing, only allow selecting the piece that just captured
    if (state.mustContinueCapture) {
      if (pos == state.selectedPosition) {
        // Already selected, do nothing
        return;
      }
      // Check if this is a valid move destination
      final move = state.validMoves.where((m) => m.to == pos).firstOrNull;
      if (move != null) {
        _executeMove(move);
      }
      return;
    }

    // If clicking on own piece, select it
    if (piece != null && piece.player == state.currentPlayer) {
      final moves = _getValidMoves(pos, piece);
      state = state.copyWith(
        selectedPosition: pos,
        validMoves: moves,
      );
      return;
    }

    // If a piece is selected and clicking on valid move destination
    if (state.selectedPosition != null) {
      final move = state.validMoves.where((m) => m.to == pos).firstOrNull;
      if (move != null) {
        _executeMove(move);
      }
    }
  }

  List<Move> _getValidMoves(Position pos, Piece piece) {
    final moves = <Move>[];
    final directions = _getMoveDirections(piece);

    // Check for captures first (captures are mandatory)
    final captures = _getCaptureMoves(pos, piece, directions);
    if (captures.isNotEmpty) {
      return captures;
    }

    // If any piece can capture, player must capture
    if (_anyPieceCanCapture()) {
      return [];
    }

    // Regular moves
    for (final dir in directions) {
      final newRow = pos.row + dir[0];
      final newCol = pos.col + dir[1];

      if (_isValidPosition(newRow, newCol) && state.board[newRow][newCol] == null) {
        moves.add(Move(from: pos, to: Position(newRow, newCol)));
      }
    }

    return moves;
  }

  List<List<int>> _getMoveDirections(Piece piece) {
    if (piece.isKing) {
      return [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    }
    // Red moves up (decreasing row), Black moves down (increasing row)
    return piece.player == Player.red
        ? [[-1, -1], [-1, 1]]
        : [[1, -1], [1, 1]];
  }

  List<Move> _getCaptureMoves(Position pos, Piece piece, List<List<int>> directions) {
    final captures = <Move>[];

    // Kings can capture in all directions
    final captureDirections = piece.isKing
        ? [[-1, -1], [-1, 1], [1, -1], [1, 1]]
        : directions;

    for (final dir in captureDirections) {
      final midRow = pos.row + dir[0];
      final midCol = pos.col + dir[1];
      final endRow = pos.row + dir[0] * 2;
      final endCol = pos.col + dir[1] * 2;

      if (_isValidPosition(endRow, endCol)) {
        final midPiece = state.board[midRow][midCol];
        final endCell = state.board[endRow][endCol];

        if (midPiece != null &&
            midPiece.player != piece.player &&
            endCell == null) {
          captures.add(Move(
            from: pos,
            to: Position(endRow, endCol),
            captured: Position(midRow, midCol),
          ));
        }
      }
    }

    return captures;
  }

  bool _anyPieceCanCapture() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board[row][col];
        if (piece != null && piece.player == state.currentPlayer) {
          final directions = _getMoveDirections(piece);
          if (_getCaptureMoves(Position(row, col), piece, directions).isNotEmpty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _executeMove(Move move) {
    final newBoard = List.generate(8, (row) => List<Piece?>.from(state.board[row]));

    final piece = newBoard[move.from.row][move.from.col]!;
    newBoard[move.from.row][move.from.col] = null;

    // Check if piece becomes king
    var movedPiece = piece;
    if (!piece.isKing) {
      if ((piece.player == Player.red && move.to.row == 0) ||
          (piece.player == Player.black && move.to.row == 7)) {
        movedPiece = piece.toKing();
      }
    }
    newBoard[move.to.row][move.to.col] = movedPiece;

    int redCount = state.redCount;
    int blackCount = state.blackCount;

    // Handle capture
    if (move.isCapture) {
      final capturedPiece = newBoard[move.captured!.row][move.captured!.col]!;
      newBoard[move.captured!.row][move.captured!.col] = null;

      if (capturedPiece.player == Player.red) {
        redCount--;
      } else {
        blackCount--;
      }
    }

    // Check for winner
    Player? winner;
    if (redCount == 0) {
      winner = Player.black;
    } else if (blackCount == 0) {
      winner = Player.red;
    }

    // Check for multi-capture
    if (move.isCapture) {
      final furtherCaptures = _getCaptureMoves(
        move.to,
        movedPiece,
        _getMoveDirections(movedPiece),
      );

      if (furtherCaptures.isNotEmpty) {
        state = DamasState(
          board: newBoard,
          currentPlayer: state.currentPlayer,
          selectedPosition: move.to,
          validMoves: furtherCaptures,
          winner: winner,
          mustContinueCapture: true,
          redCount: redCount,
          blackCount: blackCount,
        );
        return;
      }
    }

    // Switch player
    final nextPlayer = state.currentPlayer == Player.red ? Player.black : Player.red;

    state = DamasState(
      board: newBoard,
      currentPlayer: nextPlayer,
      winner: winner,
      redCount: redCount,
      blackCount: blackCount,
    );
  }

  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  void reset() {
    state = DamasState.initial();
  }
}
