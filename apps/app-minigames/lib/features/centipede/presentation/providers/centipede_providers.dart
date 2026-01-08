import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'centipede_providers.g.dart';

/// Provider for Centipede game high score
@riverpod
class CentipedeHighScore extends _$CentipedeHighScore {
  static const String _key = 'centipede_high_score';

  @override
  Future<int> build() async {
    return await _loadHighScore();
  }

  Future<int> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> saveHighScore(int score) async {
    final currentHigh = state.value ?? 0;
    if (score > currentHigh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_key, score);
        state = AsyncValue.data(score);
      } catch (e) {
        // Ignore save errors
      }
    }
  }
}
