// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing a position on the grid
class Position extends Equatable {
  final int x;
  final int y;

  const Position(this.x, this.y);

  /// Create a copy with modified fields
  Position copyWith({int? x, int? y}) {
    return Position(x ?? this.x, y ?? this.y);
  }

  @override
  List<Object?> get props => [x, y];
}
