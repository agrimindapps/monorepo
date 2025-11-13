import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/usecases/check_match_usecase.dart';
import '../../domain/usecases/flip_card_usecase.dart';
import '../../domain/usecases/generate_cards_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';

part 'memory_game_notifier.g.dart';

@riverpod
class MemoryGameNotifier extends _$MemoryGameNotifier {
  Timer? _gameTimer;
  HighScoreEntity? _currentHighScore;
  bool _isMounted = true;

  @override
  GameStateEntity build() {
    ref.onDispose(() {
      _isMounted = false;
      _gameTimer?.cancel();
    });

    return const GameStateEntity(cards: []);
  }

  Future<void> startGame(GameDifficulty difficulty) async {
    final restartGameUseCase = ref.read(restartGameUseCaseProvider);

    final result = restartGameUseCase(
      RestartGameParams(difficulty: difficulty),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: GameStatus.error,
          errorMessage: failure.message,
        );
      },
      (gameState) {
        state = gameState.copyWith(
          status: GameStatus.playing,
          startTime: DateTime.now(),
        );
        _startTimer();
        _loadHighScore(difficulty);
      },
    );
  }

  Future<void> _loadHighScore(GameDifficulty difficulty) async {
    final loadHighScoreUseCase = ref.read(loadHighScoreUseCaseProvider);
    final result = await loadHighScoreUseCase(
      LoadHighScoreParams(difficulty: difficulty),
    );

    result.fold(
      (failure) {},
      (highScore) {
        _currentHighScore = highScore;
      },
    );
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isMounted) return;

      if (state.status == GameStatus.playing) {
        final elapsed = DateTime.now().difference(state.startTime!);
        if (!_isMounted) return;
        state = state.copyWith(elapsedTime: elapsed);
      }
    });
  }

  Future<void> flipCard(String cardId) async {
    if (!state.canFlipCard) return;

    final flipCardUseCase = ref.read(flipCardUseCaseProvider);
    final result = flipCardUseCase(
      FlipCardParams(currentState: state, cardId: cardId),
    );

    result.fold(
      (failure) {},
      (newState) {
        state = newState;
        HapticFeedback.lightImpact();

        if (newState.flippedCards.length == 2) {
          _checkMatch();
        }
      },
    );
  }

  Future<void> _checkMatch() async {
    await Future.delayed(Duration(milliseconds: state.difficulty.matchTime));
    if (!_isMounted) return;

    final checkMatchUseCase = ref.read(checkMatchUseCaseProvider);
    final result = checkMatchUseCase(state);

    result.fold(
      (failure) {},
      (newState) {
        if (!_isMounted) return;
        state = newState;

        if (newState.status == GameStatus.completed) {
          _handleVictory();
        } else {
          final isMatch = newState.matches > state.matches;
          if (isMatch) {
            HapticFeedback.mediumImpact();
          } else {
            HapticFeedback.lightImpact();
          }
        }
      },
    );
  }

  Future<void> _handleVictory() async {
    _gameTimer?.cancel();
    HapticFeedback.heavyImpact();

    final currentScore = state.calculateScore();
    final shouldSave = _currentHighScore == null ||
        currentScore > _currentHighScore!.score;

    if (shouldSave && state.elapsedTime != null) {
      final newHighScore = HighScoreEntity(
        difficulty: state.difficulty,
        score: currentScore,
        moves: state.moves,
        time: state.elapsedTime!,
        achievedAt: DateTime.now(),
      );

      final saveHighScoreUseCase = ref.read(saveHighScoreUseCaseProvider);
      await saveHighScoreUseCase(newHighScore);
      _currentHighScore = newHighScore;
    }
  }

  void togglePause() {
    if (state.status == GameStatus.playing) {
      _gameTimer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    } else if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _startTimer();
    }
  }

  Future<void> restartGame() async {
    _gameTimer?.cancel();
    await startGame(state.difficulty);
  }

  Future<void> changeDifficulty(GameDifficulty newDifficulty) async {
    if (newDifficulty == state.difficulty) return;
    await startGame(newDifficulty);
  }

  HighScoreEntity? get currentHighScore => _currentHighScore;

  bool get isNewRecord {
    if (_currentHighScore == null || state.elapsedTime == null) {
      return false;
    }
    final currentScore = state.calculateScore();
    return currentScore > _currentHighScore!.score;
  }
}

@riverpod
GenerateCardsUseCase generateCardsUseCase(GenerateCardsUseCaseRef ref) {
  return GenerateCardsUseCase();
}

@riverpod
FlipCardUseCase flipCardUseCase(FlipCardUseCaseRef ref) {
  return FlipCardUseCase();
}

@riverpod
CheckMatchUseCase checkMatchUseCase(CheckMatchUseCaseRef ref) {
  return CheckMatchUseCase();
}

@riverpod
RestartGameUseCase restartGameUseCase(RestartGameUseCaseRef ref) {
  final generateCardsUseCase = ref.watch(generateCardsUseCaseProvider);
  return RestartGameUseCase(generateCardsUseCase);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  return GetIt.instance.get<LoadHighScoreUseCase>();
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  return GetIt.instance.get<SaveHighScoreUseCase>();
}
