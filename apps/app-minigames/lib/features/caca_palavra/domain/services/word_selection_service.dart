import 'dart:math';
import 'package:injectable/injectable.dart';

/// Service responsible for word selection logic
/// Follows SRP by handling only word selection strategies
@lazySingleton
class WordSelectionService {
  final Random _random = Random();

  /// Selects random words that fit in the grid
  List<String> selectRandomWords(
    List<String> availableWords,
    int count,
    int gridSize,
  ) {
    final shuffled = List<String>.from(availableWords)..shuffle(_random);

    return shuffled
        .where((word) => word.length <= gridSize)
        .take(count)
        .map((word) => word.toUpperCase())
        .toList();
  }

  /// Selects words with balanced lengths
  List<String> selectBalancedWords(
    List<String> availableWords,
    int count,
    int gridSize,
  ) {
    final validWords = availableWords
        .where((word) => word.length <= gridSize)
        .toList()
      ..shuffle(_random);

    if (validWords.isEmpty) return [];

    final selectedWords = <String>[];
    final lengthGroups = _groupByLength(validWords, gridSize);

    // Try to get words from different length groups
    int index = 0;
    while (selectedWords.length < count && index < lengthGroups.length * 3) {
      final groupIndex = index % lengthGroups.length;
      final group = lengthGroups[groupIndex];

      if (group.isNotEmpty) {
        final word = group.removeAt(_random.nextInt(group.length));
        if (!selectedWords.contains(word)) {
          selectedWords.add(word.toUpperCase());
        }
      }

      index++;
    }

    return selectedWords;
  }

  /// Groups words by length ranges
  List<List<String>> _groupByLength(List<String> words, int gridSize) {
    final short = <String>[];
    final medium = <String>[];
    final long = <String>[];

    final shortMax = (gridSize * 0.4).floor();
    final mediumMax = (gridSize * 0.7).floor();

    for (final word in words) {
      if (word.length <= shortMax) {
        short.add(word);
      } else if (word.length <= mediumMax) {
        medium.add(word);
      } else {
        long.add(word);
      }
    }

    return [short, medium, long]..removeWhere((group) => group.isEmpty);
  }

  /// Selects words by difficulty
  List<String> selectWordsByDifficulty(
    List<String> availableWords,
    int count,
    int gridSize,
    WordSelectionDifficulty difficulty,
  ) {
    switch (difficulty) {
      case WordSelectionDifficulty.easy:
        return _selectEasyWords(availableWords, count, gridSize);
      case WordSelectionDifficulty.medium:
        return selectBalancedWords(availableWords, count, gridSize);
      case WordSelectionDifficulty.hard:
        return _selectHardWords(availableWords, count, gridSize);
    }
  }

  /// Selects easier words (shorter, more common patterns)
  List<String> _selectEasyWords(
    List<String> availableWords,
    int count,
    int gridSize,
  ) {
    final maxLength = (gridSize * 0.6).floor();

    final easyWords = availableWords
        .where((word) => word.length >= 3 && word.length <= maxLength)
        .toList()
      ..shuffle(_random);

    return easyWords.take(count).map((word) => word.toUpperCase()).toList();
  }

  /// Selects harder words (longer, more complex)
  List<String> _selectHardWords(
    List<String> availableWords,
    int count,
    int gridSize,
  ) {
    final minLength = (gridSize * 0.5).floor();

    final hardWords = availableWords
        .where((word) => word.length >= minLength && word.length <= gridSize)
        .toList()
      ..shuffle(_random);

    return hardWords.take(count).map((word) => word.toUpperCase()).toList();
  }

  /// Selects words without duplicates
  List<String> selectUniqueWords(
    List<String> availableWords,
    int count,
    int gridSize,
  ) {
    final uniqueWords = availableWords.toSet().toList()..shuffle(_random);

    return uniqueWords
        .where((word) => word.length <= gridSize)
        .take(count)
        .map((word) => word.toUpperCase())
        .toList();
  }

  /// Selects words with minimum length
  List<String> selectWordsWithMinLength(
    List<String> availableWords,
    int count,
    int gridSize,
    int minLength,
  ) {
    final validWords = availableWords
        .where((word) => word.length >= minLength && word.length <= gridSize)
        .toList()
      ..shuffle(_random);

    return validWords.take(count).map((word) => word.toUpperCase()).toList();
  }

  /// Validates selected words
  WordSelectionValidation validateSelection(
    List<String> selectedWords,
    int gridSize,
  ) {
    if (selectedWords.isEmpty) {
      return WordSelectionValidation(
        isValid: false,
        errorMessage: 'No words selected',
      );
    }

    final tooLong =
        selectedWords.where((word) => word.length > gridSize).toList();

    if (tooLong.isNotEmpty) {
      return WordSelectionValidation(
        isValid: false,
        errorMessage: 'Words too long for grid: ${tooLong.join(", ")}',
      );
    }

    final duplicates = selectedWords.toSet().length != selectedWords.length;
    if (duplicates) {
      return WordSelectionValidation(
        isValid: false,
        errorMessage: 'Duplicate words found',
      );
    }

    return WordSelectionValidation(isValid: true);
  }

  /// Gets selection statistics
  SelectionStatistics getStatistics(List<String> selectedWords) {
    if (selectedWords.isEmpty) {
      return SelectionStatistics(
        totalWords: 0,
        averageLength: 0,
        shortestLength: 0,
        longestLength: 0,
        totalLetters: 0,
      );
    }

    final lengths = selectedWords.map((w) => w.length).toList();

    return SelectionStatistics(
      totalWords: selectedWords.length,
      averageLength: lengths.reduce((a, b) => a + b) / lengths.length,
      shortestLength: lengths.reduce(min),
      longestLength: lengths.reduce(max),
      totalLetters: lengths.reduce((a, b) => a + b),
    );
  }
}

// Enums and Models

enum WordSelectionDifficulty {
  easy,
  medium,
  hard,
}

class WordSelectionValidation {
  final bool isValid;
  final String? errorMessage;

  WordSelectionValidation({
    required this.isValid,
    this.errorMessage,
  });
}

class SelectionStatistics {
  final int totalWords;
  final double averageLength;
  final int shortestLength;
  final int longestLength;
  final int totalLetters;

  SelectionStatistics({
    required this.totalWords,
    required this.averageLength,
    required this.shortestLength,
    required this.longestLength,
    required this.totalLetters,
  });
}
