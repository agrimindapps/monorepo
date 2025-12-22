// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Core imports:

// Domain imports:
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import 'flappbird_providers.dart';

part 'flappbird_notifier.g.dart';

@riverpod
class FlappbirdGameNotifier extends _$FlappbirdGameNotifier {
  // Use cases
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // High score (cached)
  int _highScore = 0;

  @override
  FutureOr<FlappyGameState> build() async {
    // Inject use cases
    _loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    _saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);

    // Load high score
    await _loadHighScore();

    // Return initial state
    return FlappyGameState.initial(
      screenWidth: 0,
      screenHeight: 0,
      difficulty: FlappyDifficulty.medium,
    );
  }

  /// Get current high score
  int get highScore => _highScore;

  /// Load high score from storage
  Future<void> _loadHighScore() async {
    final result = await _loadHighScoreUseCase();
    result.fold(
      (failure) => _highScore = 0,
      (highScore) => _highScore = highScore.score,
    );
  }

  /// Save high score from external source (Flame)
  Future<void> saveScore(int score) async {
    if (score > _highScore) {
      final result = await _saveHighScoreUseCase(score: score);
      result.fold(
        (failure) {}, // Ignore failure
        (_) {
          _highScore = score;
          // Update state if possible to reflect high score change in UI
          if (state.value != null) {
             state = AsyncValue.data(state.value!.copyWith(highScore: HighScoreEntity(score: _highScore)));
          }
        },
      );
    }
  }
}
