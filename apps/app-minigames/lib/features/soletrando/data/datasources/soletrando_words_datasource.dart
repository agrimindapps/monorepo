import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/word_entity.dart';

/// Word data structure
class WordData {
  final String word;
  final String category;
  final String? definition;
  final String? example;

  const WordData(
    this.word,
    this.category, {
    this.definition,
    this.example,
  });

  factory WordData.fromJson(Map<String, dynamic> json, String category) {
    return WordData(
      json['word'] as String,
      category,
      definition: json['definition'] as String?,
      example: json['example'] as String?,
    );
  }
}

/// Data source for word lists by category and difficulty
class SoletrandoWordsDataSource {
  Map<WordCategory, List<WordData>> _wordsByCategory = {};
  bool _isLoaded = false;

  /// Load words from JSON asset
  Future<void> _loadWords() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('assets/soletrando_data/words.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final categoriesData = data['categories'] as Map<String, dynamic>;

      final newWordsMap = <WordCategory, List<WordData>>{};

      for (final key in categoriesData.keys) {
        final categoryEnum = _getCategoryFromString(key);
        if (categoryEnum != null) {
          final wordsList = (categoriesData[key] as List)
              .map((w) => WordData.fromJson(w, categoryEnum.name))
              .toList();
          newWordsMap[categoryEnum] = wordsList;
        }
      }

      _wordsByCategory = newWordsMap;
      _isLoaded = true;
    } catch (e) {
      print('Error loading words: $e');
      // Fallback or empty map
    }
  }

  WordCategory? _getCategoryFromString(String key) {
    switch (key) {
      case 'fruits': return WordCategory.fruits;
      case 'animals': return WordCategory.animals;
      case 'countries': return WordCategory.countries;
      case 'professions': return WordCategory.professions;
      default: return null;
    }
  }

  /// Get random word for category and difficulty
  Future<WordEntity> getRandomWord({
    required WordCategory category,
    required GameDifficulty difficulty,
  }) async {
    await _loadWords();

    final categoryWords = _wordsByCategory[category] ?? [];

    if (categoryWords.isEmpty) {
      // Return a fallback word if json loading failed or empty
      return WordEntity(
        word: 'ERRO',
        category: category,
        difficulty: difficulty,
        definition: 'Erro ao carregar palavras',
        example: 'Tente reiniciar o jogo',
      );
    }

    // Filter words by difficulty based on length
    List<WordData> filteredWords;
    switch (difficulty) {
      case GameDifficulty.easy:
        // Easy: 3-6 letters
        filteredWords = categoryWords.where((w) => w.word.length >= 3 && w.word.length <= 6).toList();
        break;
      case GameDifficulty.medium:
        // Medium: 5-9 letters
        filteredWords = categoryWords.where((w) => w.word.length >= 5 && w.word.length <= 9).toList();
        break;
      case GameDifficulty.hard:
        // Hard: 8+ letters
        filteredWords = categoryWords.where((w) => w.word.length >= 8).toList();
        break;
    }

    // Fallback to all words if filter is too restrictive
    if (filteredWords.isEmpty) {
      filteredWords = categoryWords;
    }

    // Select random word
    final randomIndex = Random().nextInt(filteredWords.length);
    final wordData = filteredWords[randomIndex];

    return WordEntity(
      word: wordData.word,
      category: category,
      difficulty: difficulty,
      definition: wordData.definition,
      example: wordData.example,
    );
  }

  /// Get all words for a category
  Future<List<WordEntity>> getAllWords(WordCategory category, GameDifficulty difficulty) async {
    await _loadWords();
    final categoryWords = _wordsByCategory[category] ?? [];
    return categoryWords
        .map((data) => WordEntity(
              word: data.word,
              category: category,
              difficulty: difficulty,
              definition: data.definition,
              example: data.example,
            ))
        .toList();
  }

  /// Get word count for category
  Future<int> getWordCount(WordCategory category) async {
    await _loadWords();
    return _wordsByCategory[category]?.length ?? 0;
  }

  /// Get total word count
  Future<int> get totalWordCount async {
    await _loadWords();
    return _wordsByCategory.values.fold(0, (sum, words) => sum + words.length);
  }
}
