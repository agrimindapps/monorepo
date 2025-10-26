import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/repositories/soletrando_repository.dart';
import '../../domain/usecases/check_letter_usecase.dart';
import '../../domain/usecases/generate_word_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/reveal_hint_usecase.dart';
import '../../domain/usecases/skip_word_usecase.dart';

part 'soletrando_game_notifier.g.dart';

@riverpod
class SoletrandoGame extends _$SoletrandoGame {
  Timer? _timer;
  bool _isMounted = true;

  @override
  GameStateEntity build() {
    ref.onDispose(() {
      _isMounted = false;
      _timer?.cancel();
    });

    return GameStateEntity.initial();
  }

  /// Start new game with difficulty and category
  Future<void> startGame({
    required GameDifficulty difficulty,
    required WordCategory category,
  }) async {
    // Stop existing timer
    _timer?.cancel();

    // Generate word
    final generateUseCase = ref.read(generateWordUseCaseProvider);
    final result = await generateUseCase(GenerateWordParams(
      difficulty: difficulty,
      category: category,
    ));

    result.fold(
      (failure) {
        state = state.copyWith(
          status: GameStatus.error,
        );
      },
      (word) {
        state = GameStateEntity.forWord(
          word: word,
          difficulty: difficulty,
        );

        // Start timer
        _startTimer();
      },
    );
  }

  /// Check typed letter
  Future<void> checkLetter(String letter) async {
    if (!state.isActive) return;

    // Haptic feedback
    HapticFeedback.selectionClick();

    final checkLetterUseCase = CheckLetterUseCase();
    final result = await checkLetterUseCase(CheckLetterParams(
      currentState: state,
      letter: letter,
    ));

    result.fold(
      (failure) {
        // Could show error message
      },
      (newState) {
        state = newState;

        // If word completed, handle victory
        if (newState.status == GameStatus.wordCompleted) {
          _timer?.cancel();
          HapticFeedback.heavyImpact();
        }

        // If game over, stop timer
        if (newState.status == GameStatus.gameOver) {
          _timer?.cancel();
          HapticFeedback.heavyImpact();
        }
      },
    );
  }

  /// Use hint to reveal a letter
  Future<void> useHint() async {
    if (!state.canUseHint) return;

    HapticFeedback.mediumImpact();

    final revealHintUseCase = RevealHintUseCase();
    final result = await revealHintUseCase(state);

    result.fold(
      (failure) {
        // Could show error message
      },
      (newState) {
        state = newState;
      },
    );
  }

  /// Skip current word
  Future<void> skipWord() async {
    if (!state.isActive) return;

    final skipWordUseCase = ref.read(skipWordUseCaseProvider);
    final result = await skipWordUseCase(state);

    result.fold(
      (failure) {
        state = state.copyWith(status: GameStatus.error);
      },
      (newState) {
        state = newState;
        // Restart timer for new word
        _timer?.cancel();
        _startTimer();
      },
    );
  }

  /// Restart game with current settings
  Future<void> restartGame() async {
    final restartUseCase = ref.read(restartGameUseCaseProvider);
    final result = await restartUseCase(RestartGameParams(
      difficulty: state.difficulty,
      category: state.currentWord.category,
    ));

    result.fold(
      (failure) {
        state = state.copyWith(status: GameStatus.error);
      },
      (newState) {
        state = newState;
        _timer?.cancel();
        _startTimer();
      },
    );
  }

  /// Pause game
  void pauseGame() {
    if (state.isActive) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  /// Resume game
  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _startTimer();
    }
  }

  /// Start countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isMounted) return;

      if (state.timeRemaining > 0) {
        if (!_isMounted) return;
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _timer?.cancel();
        if (!_isMounted) return;
        state = state.copyWith(status: GameStatus.timeUp);
        HapticFeedback.heavyImpact();
      }
    });
  }
}

// Provider for dependencies using GetIt
@riverpod
GenerateWordUseCase generateWordUseCase(GenerateWordUseCaseRef ref) {
  final repository = GetIt.I<SoletrandoRepository>();
  return GenerateWordUseCase(repository);
}

@riverpod
SkipWordUseCase skipWordUseCase(SkipWordUseCaseRef ref) {
  final repository = GetIt.I<SoletrandoRepository>();
  return SkipWordUseCase(repository);
}

@riverpod
RestartGameUseCase restartGameUseCase(RestartGameUseCaseRef ref) {
  final repository = GetIt.I<SoletrandoRepository>();
  return RestartGameUseCase(repository);
}
