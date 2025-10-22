import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'position.dart';

/// Immutable entity representing a word in the grid
class WordEntity extends Equatable {
  final String text;
  final WordDirection direction;
  final List<Position> positions;
  final bool isFound;
  final bool isHighlighted;

  const WordEntity({
    required this.text,
    required this.direction,
    required this.positions,
    this.isFound = false,
    this.isHighlighted = false,
  });

  /// Verifies if selected positions match this word (in any direction)
  bool matchesPositions(List<Position> selectedPositions) {
    if (selectedPositions.length != positions.length) return false;

    // Check forward match
    final forwardMatch = selectedPositions.first == positions.first &&
        selectedPositions.last == positions.last;

    // Check reverse match
    final reverseMatch = selectedPositions.first == positions.last &&
        selectedPositions.last == positions.first;

    return forwardMatch || reverseMatch;
  }

  WordEntity copyWith({
    bool? isFound,
    bool? isHighlighted,
  }) {
    return WordEntity(
      text: text,
      direction: direction,
      positions: positions,
      isFound: isFound ?? this.isFound,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  @override
  List<Object?> get props => [
        text,
        direction,
        positions,
        isFound,
        isHighlighted,
      ];

  @override
  String toString() => 'WordEntity($text, ${direction.label}, found: $isFound)';
}
