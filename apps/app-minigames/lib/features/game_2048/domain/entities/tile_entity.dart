import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'enums.dart';
import 'position_entity.dart';

/// Represents a single tile on the game board
class TileEntity extends Equatable {
  final String id;
  final int value;
  final PositionEntity position;
  final AnimationType animationType;

  const TileEntity({
    required this.id,
    required this.value,
    required this.position,
    this.animationType = AnimationType.none,
  });

  /// Creates a new tile with spawn animation
  factory TileEntity.spawn({
    required int value,
    required PositionEntity position,
  }) {
    return TileEntity(
      id: const Uuid().v4(),
      value: value,
      position: position,
      animationType: AnimationType.spawn,
    );
  }

  /// Creates a copy with optional new values
  TileEntity copyWith({
    String? id,
    int? value,
    PositionEntity? position,
    AnimationType? animationType,
  }) {
    return TileEntity(
      id: id ?? this.id,
      value: value ?? this.value,
      position: position ?? this.position,
      animationType: animationType ?? this.animationType,
    );
  }

  /// Clears animation flags
  TileEntity clearAnimation() {
    return copyWith(animationType: AnimationType.none);
  }

  /// Marks tile as merged
  TileEntity markAsMerged() {
    return copyWith(animationType: AnimationType.merge);
  }

  /// Marks tile as moved
  TileEntity markAsMoved() {
    return copyWith(animationType: AnimationType.move);
  }

  /// Checks if this tile is at the same position as another
  bool isAtSamePosition(TileEntity other) {
    return position.isSameAs(other.position);
  }

  /// Checks if this tile can merge with another tile
  bool canMergeWith(TileEntity other) {
    return value == other.value && !isAtSamePosition(other);
  }

  @override
  List<Object?> get props => [id, value, position, animationType];

  @override
  String toString() =>
      'Tile(id: $id, value: $value, pos: $position, anim: $animationType)';
}
