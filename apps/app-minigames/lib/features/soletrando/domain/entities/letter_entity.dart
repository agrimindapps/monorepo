import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Represents a single letter in the word being guessed
class LetterEntity extends Equatable {
  final String letter;
  final int position;
  final LetterState state;

  const LetterEntity({
    required this.letter,
    required this.position,
    required this.state,
  });

  /// Create a pending letter (not yet guessed)
  factory LetterEntity.pending(String letter, int position) {
    return LetterEntity(
      letter: letter.toUpperCase(),
      position: position,
      state: LetterState.pending,
    );
  }

  /// Check if letter is revealed (correct or revealed by hint)
  bool get isRevealed =>
      state == LetterState.correct || state == LetterState.revealed;

  /// Display character (letter if revealed, underscore if pending)
  String get displayChar => isRevealed ? letter : '_';

  /// Copy with new values
  LetterEntity copyWith({
    String? letter,
    int? position,
    LetterState? state,
  }) {
    return LetterEntity(
      letter: letter ?? this.letter,
      position: position ?? this.position,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [letter, position, state];

  @override
  String toString() => 'LetterEntity(letter: $letter, pos: $position, state: $state)';
}
