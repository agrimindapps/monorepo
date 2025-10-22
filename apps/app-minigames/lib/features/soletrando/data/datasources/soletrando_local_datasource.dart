import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/high_score_model.dart';

/// Local data source for Soletrando using SharedPreferences
class SoletrandoLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _highScoresKey = 'soletrando_high_scores';
  static const String _settingsKey = 'soletrando_settings';

  SoletrandoLocalDataSource(this.sharedPreferences);

  /// Load high scores from local storage
  Future<HighScoresCollectionModel> loadHighScores() async {
    try {
      final jsonString = sharedPreferences.getString(_highScoresKey);

      if (jsonString == null) {
        return HighScoresCollectionModel.empty();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoresCollectionModel.fromJson(json);
    } catch (e) {
      // Return empty on error
      return HighScoresCollectionModel.empty();
    }
  }

  /// Save high scores to local storage
  Future<void> saveHighScores(HighScoresCollectionModel highScores) async {
    final jsonString = jsonEncode(highScores.toJson());
    await sharedPreferences.setString(_highScoresKey, jsonString);
  }

  /// Load settings from local storage
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final jsonString = sharedPreferences.getString(_settingsKey);

      if (jsonString == null) {
        return _defaultSettings();
      }

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return _defaultSettings();
    }
  }

  /// Save settings to local storage
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final jsonString = jsonEncode(settings);
    await sharedPreferences.setString(_settingsKey, jsonString);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await sharedPreferences.remove(_highScoresKey);
    await sharedPreferences.remove(_settingsKey);
  }

  /// Default settings
  Map<String, dynamic> _defaultSettings() {
    return {
      'difficulty': 'medium',
      'soundEnabled': true,
      'animationsEnabled': true,
      'hapticFeedback': true,
    };
  }
}
