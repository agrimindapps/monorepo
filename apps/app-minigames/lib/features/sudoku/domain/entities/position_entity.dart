import 'package:equatable/equatable.dart';

class PositionEntity extends Equatable {
  final int row;
  final int col;

  const PositionEntity({
    required this.row,
    required this.col,
  });

  /// Block index (0-8) for 3x3 subgrid
  int get blockIndex => (row ~/ 3) * 3 + (col ~/ 3);

  /// Block row (0-2) within the 3x3 subgrid
  int get blockRow => row ~/ 3;

  /// Block col (0-2) within the 3x3 subgrid
  int get blockCol => col ~/ 3;

  /// Position within block (0-8)
  int get positionInBlock => (row % 3) * 3 + (col % 3);

  /// Check if position is valid (within 0-8 range)
  bool get isValid => row >= 0 && row < 9 && col >= 0 && col < 9;

  /// Check if two positions are in the same row
  bool isSameRow(PositionEntity other) => row == other.row;

  /// Check if two positions are in the same column
  bool isSameCol(PositionEntity other) => col == other.col;

  /// Check if two positions are in the same 3x3 block
  bool isSameBlock(PositionEntity other) => blockIndex == other.blockIndex;

  /// Check if two positions are related (same row, col, or block)
  bool isRelated(PositionEntity other) =>
      isSameRow(other) || isSameCol(other) || isSameBlock(other);

  PositionEntity copyWith({
    int? row,
    int? col,
  }) {
    return PositionEntity(
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => 'Position($row, $col)';
}
