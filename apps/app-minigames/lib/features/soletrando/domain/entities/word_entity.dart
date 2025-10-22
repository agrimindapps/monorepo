import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Represents a word to be guessed in the game
class WordEntity extends Equatable {
  final String word;
  final WordCategory category;
  final GameDifficulty difficulty;
  final String? definition;
  final String? example;

  const WordEntity({
    required this.word,
    required this.category,
    required this.difficulty,
    this.definition,
    this.example,
  });

  /// Create empty word entity
  factory WordEntity.empty() {
    return const WordEntity(
      word: '',
      category: WordCategory.fruits,
      difficulty: GameDifficulty.easy,
    );
  }

  /// Create word from string with defaults
  factory WordEntity.fromString(
    String word, {
    WordCategory category = WordCategory.fruits,
    GameDifficulty difficulty = GameDifficulty.medium,
    String? definition,
    String? example,
  }) {
    return WordEntity(
      word: word.toUpperCase().trim(),
      category: category,
      difficulty: difficulty,
      definition: definition,
      example: example,
    );
  }

  /// Word length
  int get length => word.length;

  /// Check if word is valid (non-empty and contains only letters)
  bool get isValid {
    if (word.isEmpty) return false;
    return RegExp(r'^[A-ZÁÀÂÃÉÊÍÓÔÕÚÇ]+$').hasMatch(word);
  }

  /// Get unique letters in word
  Set<String> get uniqueLetters => word.split('').toSet();

  /// Check if letter exists in word
  bool containsLetter(String letter) {
    return word.contains(letter.toUpperCase());
  }

  /// Get all positions of a letter in word
  List<int> getLetterPositions(String letter) {
    final positions = <int>[];
    final upperLetter = letter.toUpperCase();

    for (int i = 0; i < word.length; i++) {
      if (word[i] == upperLetter) {
        positions.add(i);
      }
    }

    return positions;
  }

  /// Copy with new values
  WordEntity copyWith({
    String? word,
    WordCategory? category,
    GameDifficulty? difficulty,
    String? definition,
    String? example,
  }) {
    return WordEntity(
      word: word ?? this.word,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      definition: definition ?? this.definition,
      example: example ?? this.example,
    );
  }

  @override
  List<Object?> get props => [word, category, difficulty, definition, example];

  @override
  String toString() => 'WordEntity(word: $word, category: ${category.name}, difficulty: ${difficulty.label})';
}
