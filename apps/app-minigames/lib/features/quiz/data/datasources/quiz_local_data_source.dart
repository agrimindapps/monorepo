// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Core imports:
import 'package:app_minigames/core/error/exceptions.dart';

// Data imports:
import '../models/quiz_question_model.dart';
import '../models/high_score_model.dart';

/// Interface for quiz local data source
abstract class QuizLocalDataSource {
  /// Get all quiz questions from assets
  Future<List<QuizQuestionModel>> getQuestions();

  /// Load high score
  Future<HighScoreModel> loadHighScore();

  /// Save high score
  Future<void> saveHighScore(int score);
}

/// Implementation of quiz local data source
class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _highScoreKey = 'quiz_high_score';

  QuizLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<QuizQuestionModel>> getQuestions() async {
    try {
      final List<QuizQuestionModel> allQuestions = [];
      
      // List of quiz files to load
      // In a real app, you might list files in the directory or have a manifest
      final quizFiles = [
        'assets/quiz_data/flutter_quiz.json',
        'assets/quiz_data/general_quiz.json',
      ];

      for (final file in quizFiles) {
        try {
          final jsonString = await rootBundle.loadString(file);
          final Map<String, dynamic> data = json.decode(jsonString);
          
          if (data.containsKey('questions')) {
            final List<dynamic> questionsList = data['questions'];
            final questions = questionsList
                .map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>))
                .toList();
            allQuestions.addAll(questions);
          }
        } catch (e) {
          // Continue loading other files even if one fails
          print('Error loading quiz file $file: $e');
        }
      }

      // Shuffle questions to make it dynamic
      allQuestions.shuffle();
      
      return allQuestions;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<HighScoreModel> loadHighScore() async {
    try {
      final score = sharedPreferences.getInt(_highScoreKey) ?? 0;
      return HighScoreModel(score: score);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveHighScore(int score) async {
    try {
      await sharedPreferences.setInt(_highScoreKey, score);
    } catch (e) {
      throw CacheException();
    }
  }
}
