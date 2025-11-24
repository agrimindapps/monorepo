// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Core imports:
import 'package:app_minigames/core/error/exceptions.dart';

// Data imports:
import '../models/quiz_question_model.dart';
import '../models/high_score_model.dart';

/// Interface for quiz local data source
abstract class QuizLocalDataSource {
  /// Get all quiz questions (hardcoded 3 questions)
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
      // Hardcoded 3 questions (preserving exact questions from legacy provider)
      const questionsJson = '''
      [
        {
          "id": 1,
          "question": "SDK de código aberto criado pelo Google para desenvolvimento de aplicativos multiplataforma",
          "correctAnswer": "Flutter",
          "options": ["Flutter", "React", "Angular", "Vue"]
        },
        {
          "id": 2,
          "question": "Elementos básicos de construção de interfaces no Flutter, tudo é um...",
          "correctAnswer": "Widget",
          "options": ["Widget", "Component", "Element", "View"]
        },
        {
          "id": 3,
          "question": "Método usado para atualizar o estado de um widget e reconstruir a interface",
          "correctAnswer": "setState",
          "options": ["setState", "updateUI", "refresh", "rebuild"]
        }
      ]
      ''';

      final List<dynamic> jsonList = json.decode(questionsJson);
      return jsonList.map((json) => QuizQuestionModel.fromJson(json as Map<String, dynamic>)).toList();
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
