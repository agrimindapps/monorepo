import 'package:flutter/material.dart';

enum PieceType { normal, king }
enum Player { red, black }

class Piece {
  final Player player;
  final PieceType type;

  const Piece({
    required this.player,
    this.type = PieceType.normal,
  });

  Piece toKing() => Piece(player: player, type: PieceType.king);

  Color get color => player == Player.red ? Colors.red : Colors.grey.shade900;
  
  bool get isKing => type == PieceType.king;
}

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col)';
}

class Move {
  final Position from;
  final Position to;
  final Position? captured; // Position of captured piece (if any)

  const Move({
    required this.from,
    required this.to,
    this.captured,
  });

  bool get isCapture => captured != null;
}
