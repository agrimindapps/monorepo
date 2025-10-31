import 'package:injectable/injectable.dart';

import '../entities/enums.dart';
import '../entities/letter_entity.dart';

/// Service responsible for letter validation and checking
///
/// Handles:
/// - Letter format validation
/// - Letter existence checking in words
/// - Letter position finding
/// - Guessed letter tracking
/// - Unique letter analysis
@lazySingleton
class LetterValidationService {
  LetterValidationService();

  // ============================================================================
  // Letter Format Validation
  // ============================================================================

  /// Validates if string is a single valid letter
  bool isValidLetter(String input) {
    final trimmed = input.trim().toUpperCase();

    if (trimmed.length != 1) {
      return false;
    }

    return RegExp(r'^[A-ZÁÀÂÃÉÊÍÓÔÕÚÇ]$').hasMatch(trimmed);
  }

  /// Validates letter input with detailed result
  LetterInputValidation validateLetterInput({
    required String input,
    required Set<String> guessedLetters,
  }) {
    final errors = <String>[];
    final trimmed = input.trim().toUpperCase();

    // Check length
    if (trimmed.isEmpty) {
      errors.add('Letra não pode ser vazia');
    } else if (trimmed.length > 1) {
      errors.add('Deve fornecer apenas uma letra');
    }

    // Check format
    if (trimmed.length == 1 &&
        !RegExp(r'^[A-ZÁÀÂÃÉÊÍÓÔÕÚÇ]$').hasMatch(trimmed)) {
      errors.add('Letra inválida');
    }

    // Check if already guessed
    if (trimmed.length == 1 && guessedLetters.contains(trimmed)) {
      errors.add('Letra já foi tentada');
    }

    return LetterInputValidation(
      isValid: errors.isEmpty,
      normalizedLetter: trimmed,
      errors: errors,
    );
  }

  /// Normalizes letter (uppercase and trim)
  String normalizeLetter(String input) {
    return input.trim().toUpperCase();
  }

  // ============================================================================
  // Letter Existence Checking
  // ============================================================================

  /// Checks if letter exists in word
  bool containsLetter({
    required String word,
    required String letter,
  }) {
    return word.toUpperCase().contains(letter.toUpperCase());
  }

  /// Gets all positions of letter in word
  List<int> getLetterPositions({
    required String word,
    required String letter,
  }) {
    final positions = <int>[];
    final upperWord = word.toUpperCase();
    final upperLetter = letter.toUpperCase();

    for (int i = 0; i < upperWord.length; i++) {
      if (upperWord[i] == upperLetter) {
        positions.add(i);
      }
    }

    return positions;
  }

  /// Gets letter check result with details
  LetterCheckResult checkLetter({
    required String word,
    required String letter,
  }) {
    final exists = containsLetter(word: word, letter: letter);
    final positions =
        exists ? getLetterPositions(word: word, letter: letter) : <int>[];

    return LetterCheckResult(
      exists: exists,
      letter: letter.toUpperCase(),
      positions: positions,
      occurrences: positions.length,
    );
  }

  // ============================================================================
  // Letter Reveal Logic
  // ============================================================================

  /// Reveals all occurrences of a letter in letter list
  List<LetterEntity> revealLetter({
    required List<LetterEntity> currentLetters,
    required List<int> positions,
    required LetterState revealState,
  }) {
    final updatedLetters = List<LetterEntity>.from(currentLetters);

    for (final pos in positions) {
      if (pos >= 0 && pos < updatedLetters.length) {
        updatedLetters[pos] = updatedLetters[pos].copyWith(state: revealState);
      }
    }

    return updatedLetters;
  }

  /// Checks if all letters are revealed
  bool areAllLettersRevealed(List<LetterEntity> letters) {
    return letters.every((l) => l.isRevealed);
  }

  /// Gets count of revealed letters
  int getRevealedCount(List<LetterEntity> letters) {
    return letters.where((l) => l.isRevealed).length;
  }

  /// Gets count of pending (hidden) letters
  int getPendingCount(List<LetterEntity> letters) {
    return letters.where((l) => !l.isRevealed).length;
  }

  // ============================================================================
  // Unique Letters Analysis
  // ============================================================================

  /// Gets unique letters in word
  Set<String> getUniqueLetters(String word) {
    return word.toUpperCase().split('').toSet();
  }

  /// Gets count of unique letters
  int getUniqueLetterCount(String word) {
    return getUniqueLetters(word).length;
  }

  /// Checks if word has repeated letters
  bool hasRepeatedLetters(String word) {
    return getUniqueLetterCount(word) < word.length;
  }

  /// Gets letter frequency map
  Map<String, int> getLetterFrequency(String word) {
    final frequency = <String, int>{};
    final upperWord = word.toUpperCase();

    for (final char in upperWord.split('')) {
      frequency[char] = (frequency[char] ?? 0) + 1;
    }

    return frequency;
  }

  // ============================================================================
  // Guessed Letters Tracking
  // ============================================================================

  /// Adds letter to guessed set
  Set<String> addGuessedLetter({
    required Set<String> currentGuessed,
    required String letter,
  }) {
    return Set<String>.from(currentGuessed)..add(letter.toUpperCase());
  }

  /// Checks if letter was already guessed
  bool wasLetterGuessed({
    required Set<String> guessedLetters,
    required String letter,
  }) {
    return guessedLetters.contains(letter.toUpperCase());
  }

  /// Gets remaining letters to guess
  Set<String> getRemainingLetters({
    required String word,
    required Set<String> guessedLetters,
  }) {
    final uniqueLetters = getUniqueLetters(word);
    return uniqueLetters.difference(guessedLetters);
  }

  /// Gets progress percentage (0.0 to 1.0)
  double getGuessProgress({
    required String word,
    required Set<String> guessedLetters,
  }) {
    final uniqueLetters = getUniqueLetters(word);
    final correctGuesses = guessedLetters.intersection(uniqueLetters);

    if (uniqueLetters.isEmpty) return 0.0;
    return correctGuesses.length / uniqueLetters.length;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets letter statistics
  LetterStatistics getStatistics({
    required String word,
    required List<LetterEntity> letters,
    required Set<String> guessedLetters,
  }) {
    final uniqueCount = getUniqueLetterCount(word);
    final revealedCount = getRevealedCount(letters);
    final pendingCount = getPendingCount(letters);
    final progress =
        getGuessProgress(word: word, guessedLetters: guessedLetters);
    final hasRepeated = hasRepeatedLetters(word);

    return LetterStatistics(
      totalLetters: word.length,
      uniqueLetters: uniqueCount,
      revealedLetters: revealedCount,
      pendingLetters: pendingCount,
      guessedLetters: guessedLetters.length,
      progress: progress,
      hasRepeatedLetters: hasRepeated,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Letter input validation result
class LetterInputValidation {
  final bool isValid;
  final String normalizedLetter;
  final List<String> errors;

  const LetterInputValidation({
    required this.isValid,
    required this.normalizedLetter,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Letter check result
class LetterCheckResult {
  final bool exists;
  final String letter;
  final List<int> positions;
  final int occurrences;

  const LetterCheckResult({
    required this.exists,
    required this.letter,
    required this.positions,
    required this.occurrences,
  });

  /// Checks if letter appears multiple times
  bool get hasMultipleOccurrences => occurrences > 1;

  /// Gets message about the result
  String get message {
    if (!exists) {
      return 'A letra "$letter" não está na palavra';
    } else if (occurrences == 1) {
      return 'A letra "$letter" aparece 1 vez';
    } else {
      return 'A letra "$letter" aparece $occurrences vezes';
    }
  }
}

/// Letter statistics
class LetterStatistics {
  final int totalLetters;
  final int uniqueLetters;
  final int revealedLetters;
  final int pendingLetters;
  final int guessedLetters;
  final double progress;
  final bool hasRepeatedLetters;

  const LetterStatistics({
    required this.totalLetters,
    required this.uniqueLetters,
    required this.revealedLetters,
    required this.pendingLetters,
    required this.guessedLetters,
    required this.progress,
    required this.hasRepeatedLetters,
  });

  /// Gets progress as percentage
  double get progressPercentage => progress * 100;

  /// Checks if word is complete
  bool get isComplete => revealedLetters == totalLetters;
}
