import 'package:equatable/equatable.dart';

/// Represents a position on the game grid
class PositionEntity extends Equatable {
  final int row;
  final int col;

  const PositionEntity({
    required this.row,
    required this.col,
  });

  /// Creates a copy with optional new values
  PositionEntity copyWith({
    int? row,
    int? col,
  }) {
    return PositionEntity(
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }

  /// Checks if position is equal to another position
  bool isSameAs(PositionEntity other) {
    return row == other.row && col == other.col;
  }

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => 'Position($row, $col)';
}
