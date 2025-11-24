import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/game_stats_model.dart';
import '../models/game_settings_model.dart';

/// Interface for TicTacToe local data source operations
abstract class TicTacToeLocalDataSource {
  /// Gets game statistics from local storage
  /// Throws [CacheException] on error
  Future<GameStatsModel> getStats();

  /// Saves game statistics to local storage
  /// Throws [CacheException] on error
  Future<void> saveStats(GameStatsModel stats);

  /// Resets game statistics to zero
  /// Throws [CacheException] on error
  Future<void> resetStats();

  /// Gets game settings from local storage
  /// Throws [CacheException] on error
  Future<GameSettingsModel> getSettings();

  /// Saves game settings to local storage
  /// Throws [CacheException] on error
  Future<void> saveSettings(GameSettingsModel settings);
}

/// Implementation of TicTacToe local data source using SharedPreferences
class TicTacToeLocalDataSourceImpl implements TicTacToeLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Storage keys
  static const String _xWinsKey = 'tictactoe_x_wins';
  static const String _oWinsKey = 'tictactoe_o_wins';
  static const String _drawsKey = 'tictactoe_draws';
  static const String _gameModeKey = 'tictactoe_game_mode';
  static const String _difficultyKey = 'tictactoe_difficulty';

  TicTacToeLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<GameStatsModel> getStats() async {
    try {
      final xWins = sharedPreferences.getInt(_xWinsKey) ?? 0;
      final oWins = sharedPreferences.getInt(_oWinsKey) ?? 0;
      final draws = sharedPreferences.getInt(_drawsKey) ?? 0;

      return GameStatsModel(
        xWins: xWins,
        oWins: oWins,
        draws: draws,
      );
    } catch (e) {
      throw CacheException('Failed to load stats: $e');
    }
  }

  @override
  Future<void> saveStats(GameStatsModel stats) async {
    try {
      await sharedPreferences.setInt(_xWinsKey, stats.xWins);
      await sharedPreferences.setInt(_oWinsKey, stats.oWins);
      await sharedPreferences.setInt(_drawsKey, stats.draws);
    } catch (e) {
      throw CacheException('Failed to save stats: $e');
    }
  }

  @override
  Future<void> resetStats() async {
    try {
      await sharedPreferences.remove(_xWinsKey);
      await sharedPreferences.remove(_oWinsKey);
      await sharedPreferences.remove(_drawsKey);
    } catch (e) {
      throw CacheException('Failed to reset stats: $e');
    }
  }

  @override
  Future<GameSettingsModel> getSettings() async {
    try {
      final gameModeString = sharedPreferences.getString(_gameModeKey);
      final difficultyString = sharedPreferences.getString(_difficultyKey);

      // Use fromJson to parse or return defaults
      return GameSettingsModel.fromJson({
        'gameMode': gameModeString ?? 'vsPlayer',
        'difficulty': difficultyString ?? 'medium',
      });
    } catch (e) {
      throw CacheException('Failed to load settings: $e');
    }
  }

  @override
  Future<void> saveSettings(GameSettingsModel settings) async {
    try {
      await sharedPreferences.setString(
        _gameModeKey,
        settings.gameMode.name,
      );
      await sharedPreferences.setString(
        _difficultyKey,
        settings.difficulty.name,
      );
    } catch (e) {
      throw CacheException('Failed to save settings: $e');
    }
  }
}
