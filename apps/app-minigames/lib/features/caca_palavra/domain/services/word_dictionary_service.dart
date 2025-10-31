import 'package:injectable/injectable.dart';

/// Service responsible for providing word lists for the game
/// Follows SRP by handling only word data
@lazySingleton
class WordDictionaryService {
  /// Get available words for the game
  /// Words are organized by categories for easy management
  List<String> getAvailableWords() {
    return [
      ...getNatureWords(),
      ...getEmotionWords(),
      ...getObjectWords(),
      ...getAnimalWords(),
      ...getActivityWords(),
    ];
  }

  /// Nature-related words
  List<String> getNatureWords() {
    return [
      'SOL',
      'LUA',
      'TERRA',
      'CEU',
      'MAR',
      'FLOR',
      'AGUA',
      'VENTO',
      'CHUVA',
      'ESTRELA',
      'NUVEM',
      'JARDIM',
      'ARVORE',
      'MONTANHA',
      'PRAIA',
      'FRUTA',
    ];
  }

  /// Emotion and feeling words
  List<String> getEmotionWords() {
    return [
      'AMOR',
      'VIDA',
      'PAZ',
      'FELIZ',
      'SAUDE',
      'SONHO',
    ];
  }

  /// Object and place words
  List<String> getObjectWords() {
    return [
      'CASA',
      'LIVRO',
      'TEMPO',
      'FOGO',
      'ARTE',
      'CINEMA',
      'MUSICA',
      'PINTURA',
    ];
  }

  /// Animal words
  List<String> getAnimalWords() {
    return [
      'GATO',
      'CACHORRO',
      'PEIXE',
      'PASSARO',
    ];
  }

  /// Activity words
  List<String> getActivityWords() {
    return [
      'TRABALHO',
      'ESTUDO',
      'DANCA',
      'ESPORTE',
    ];
  }

  /// Get words by category
  List<String> getWordsByCategory(WordCategory category) {
    switch (category) {
      case WordCategory.nature:
        return getNatureWords();
      case WordCategory.emotions:
        return getEmotionWords();
      case WordCategory.objects:
        return getObjectWords();
      case WordCategory.animals:
        return getAnimalWords();
      case WordCategory.activities:
        return getActivityWords();
      case WordCategory.all:
        return getAvailableWords();
    }
  }

  /// Get words filtered by difficulty
  /// Easy: 3-5 letters, Medium: 4-7 letters, Hard: 6+ letters
  List<String> getWordsByDifficulty(WordDifficulty difficulty) {
    final allWords = getAvailableWords();

    switch (difficulty) {
      case WordDifficulty.easy:
        return allWords
            .where((word) => word.length >= 3 && word.length <= 5)
            .toList();
      case WordDifficulty.medium:
        return allWords
            .where((word) => word.length >= 4 && word.length <= 7)
            .toList();
      case WordDifficulty.hard:
        return allWords.where((word) => word.length >= 6).toList();
    }
  }

  /// Get random words
  List<String> getRandomWords(int count) {
    final allWords = getAvailableWords()..shuffle();
    return allWords.take(count).toList();
  }

  /// Get words that fit in grid size
  List<String> getWordsThatFit(int gridSize) {
    return getAvailableWords()
        .where((word) => word.length <= gridSize)
        .toList();
  }

  /// Check if word exists in dictionary
  bool isValidWord(String word) {
    return getAvailableWords().contains(word.toUpperCase());
  }

  /// Get total word count
  int getTotalWordCount() {
    return getAvailableWords().length;
  }

  /// Get word count by category
  int getWordCountByCategory(WordCategory category) {
    return getWordsByCategory(category).length;
  }

  /// Add custom words (for extensibility)
  List<String> addCustomWords(List<String> customWords) {
    final allWords = getAvailableWords();
    final validCustomWords = customWords
        .map((word) => word.toUpperCase())
        .where((word) => word.length >= 3 && word.length <= 12)
        .where((word) => !allWords.contains(word))
        .toList();

    return [...allWords, ...validCustomWords];
  }
}

// Enums

enum WordCategory {
  all,
  nature,
  emotions,
  objects,
  animals,
  activities,
}

enum WordDifficulty {
  easy,
  medium,
  hard,
}
