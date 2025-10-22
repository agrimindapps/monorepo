import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'letter_entity.dart';
import 'word_entity.dart';

/// Complete game state for Soletrando
class GameStateEntity extends Equatable {
  final WordEntity currentWord;
  final List<LetterEntity> letters;
  final Set<String> guessedLetters;
  final int mistakes;
  final int hintsUsed;
  final int wordsCompleted;
  final int score;
  final int timeRemaining;
  final GameStatus status;
  final GameDifficulty difficulty;

  const GameStateEntity({
    required this.currentWord,
    required this.letters,
    required this.guessedLetters,
    required this.mistakes,
    required this.hintsUsed,
    required this.wordsCompleted,
    required this.score,
    required this.timeRemaining,
    required this.status,
    required this.difficulty,
  });

  /// Create initial empty state
  factory GameStateEntity.initial() {
    return GameStateEntity(
      currentWord: WordEntity.empty(),
      letters: const [],
      guessedLetters: const {},
      mistakes: 0,
      hintsUsed: 0,
      wordsCompleted: 0,
      score: 0,
      timeRemaining: 0,
      status: GameStatus.initial,
      difficulty: GameDifficulty.medium,
    );
  }

  /// Create state for new word
  factory GameStateEntity.forWord({
    required WordEntity word,
    required GameDifficulty difficulty,
    int score = 0,
    int wordsCompleted = 0,
  }) {
    final letters = List.generate(
      word.length,
      (i) => LetterEntity.pending(word.word[i], i),
    );

    return GameStateEntity(
      currentWord: word,
      letters: letters,
      guessedLetters: const {},
      mistakes: 0,
      hintsUsed: 0,
      wordsCompleted: wordsCompleted,
      score: score,
      timeRemaining: difficulty.timeInSeconds,
      status: GameStatus.playing,
      difficulty: difficulty,
    );
  }

  /// Check if word is completely revealed
  bool get isWordComplete => letters.every((l) => l.isRevealed);

  /// Count of correctly revealed letters
  int get correctLetters => letters.where((l) => l.isRevealed).length;

  /// Count of pending (hidden) letters
  int get pendingLetters => letters.where((l) => !l.isRevealed).length;

  /// Check if game is active (can accept inputs)
  bool get isActive => status == GameStatus.playing;

  /// Check if game is over (lost or won)
  bool get isGameOver =>
      status == GameStatus.gameOver ||
      status == GameStatus.timeUp ||
      status == GameStatus.error;

  /// Check if can use hint
  bool get canUseHint {
    final maxHints = difficulty.hints;
    return isActive && hintsUsed < maxHints && pendingLetters > 0;
  }

  /// Get available hints remaining
  int get hintsRemaining => difficulty.hints - hintsUsed;

  /// Check if letter was already guessed
  bool wasLetterGuessed(String letter) {
    return guessedLetters.contains(letter.toUpperCase());
  }

  /// Get display word as list of strings (letters or underscores)
  List<String> get displayWord => letters.map((l) => l.displayChar).toList();

  /// Get display word as single string
  String get displayWordString => displayWord.join(' ');

  /// Check if time is critical (≤10 seconds)
  bool get isCriticalTime => timeRemaining <= 10 && isActive;

  /// Copy with new values
  GameStateEntity copyWith({
    WordEntity? currentWord,
    List<LetterEntity>? letters,
    Set<String>? guessedLetters,
    int? mistakes,
    int? hintsUsed,
    int? wordsCompleted,
    int? score,
    int? timeRemaining,
    GameStatus? status,
    GameDifficulty? difficulty,
  }) {
    return GameStateEntity(
      currentWord: currentWord ?? this.currentWord,
      letters: letters ?? this.letters,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      mistakes: mistakes ?? this.mistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      wordsCompleted: wordsCompleted ?? this.wordsCompleted,
      score: score ?? this.score,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object?> get props => [
        currentWord,
        letters,
        guessedLetters,
        mistakes,
        hintsUsed,
        wordsCompleted,
        score,
        timeRemaining,
        status,
        difficulty,
      ];

  @override
  String toString() => 'GameStateEntity(word: ${currentWord.word}, '
      'revealed: $correctLetters/${letters.length}, '
      'mistakes: $mistakes, '
      'status: $status)';
}
