import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/simon_score.dart';
import 'simon_data_providers.dart';

part 'simon_says_controller.g.dart';

enum SimonGameState { idle, showingSequence, waitingForInput, gameOver }

@immutable
class SimonState {
  final SimonGameState gameState;
  final List<int> sequence;
  final List<int> userSequence;
  final int score;
  final int? activeIndex;
  final DateTime? gameStartTime;
  final int perfectRounds;
  final int colorCount;

  const SimonState({
    this.gameState = SimonGameState.idle,
    this.sequence = const [],
    this.userSequence = const [],
    this.score = 0,
    this.activeIndex,
    this.gameStartTime,
    this.perfectRounds = 0,
    this.colorCount = 4,
  });

  Duration? get gameDuration {
    if (gameStartTime == null) return null;
    return DateTime.now().difference(gameStartTime!);
  }

  SimonState copyWith({
    SimonGameState? gameState,
    List<int>? sequence,
    List<int>? userSequence,
    int? score,
    int? activeIndex,
    bool clearActiveIndex = false,
    DateTime? gameStartTime,
    int? perfectRounds,
    int? colorCount,
  }) {
    return SimonState(
      gameState: gameState ?? this.gameState,
      sequence: sequence ?? this.sequence,
      userSequence: userSequence ?? this.userSequence,
      score: score ?? this.score,
      activeIndex: clearActiveIndex ? null : (activeIndex ?? this.activeIndex),
      gameStartTime: gameStartTime ?? this.gameStartTime,
      perfectRounds: perfectRounds ?? this.perfectRounds,
      colorCount: colorCount ?? this.colorCount,
    );
  }
}

@riverpod
class SimonSaysController extends _$SimonSaysController {
  final Random _random = Random();
  
  @override
  SimonState build() {
    return const SimonState();
  }

  Future<void> startGame() async {
    final settings = await ref.read(simonSettingsProvider.future);
    state = SimonState(
      gameState: SimonGameState.showingSequence,
      gameStartTime: DateTime.now(),
      colorCount: settings.colorCount,
    );
    await _addToSequenceAndShow();
  }

  Future<void> _addToSequenceAndShow() async {
    // Add new random color (0 to colorCount-1)
    final newSequence = List<int>.from(state.sequence)..add(_random.nextInt(state.colorCount));
    
    state = state.copyWith(
      sequence: newSequence,
      userSequence: [],
      gameState: SimonGameState.showingSequence,
      clearActiveIndex: true,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Show sequence
    for (final index in state.sequence) {
      if (state.gameState != SimonGameState.showingSequence) return;
      
      state = state.copyWith(activeIndex: index);
      await Future.delayed(const Duration(milliseconds: 600));
      
      state = state.copyWith(clearActiveIndex: true);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    state = state.copyWith(gameState: SimonGameState.waitingForInput);
  }

  Future<void> handleInput(int index) async {
    if (state.gameState != SimonGameState.waitingForInput) return;

    // Visual feedback for tap
    state = state.copyWith(activeIndex: index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (state.gameState == SimonGameState.waitingForInput) {
        state = state.copyWith(clearActiveIndex: true);
      }
    });

    final expectedIndex = state.sequence[state.userSequence.length];
    
    if (index != expectedIndex) {
      // Wrong input
      state = state.copyWith(gameState: SimonGameState.gameOver);
      await _saveScore();
      return;
    }

    final newUserSequence = List<int>.from(state.userSequence)..add(index);
    state = state.copyWith(userSequence: newUserSequence);

    // Check if sequence completed
    if (newUserSequence.length == state.sequence.length) {
      state = state.copyWith(
        score: state.score + 1,
        gameState: SimonGameState.showingSequence,
      );
      
      await Future.delayed(const Duration(seconds: 1));
      await _addToSequenceAndShow();
    }
  }

  void reset() {
    state = const SimonState();
  }

  Future<void> _saveScore() async {
    if (state.gameDuration == null) return;

    final score = SimonScore(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: state.score,
      longestSequence: state.sequence.length,
      duration: state.gameDuration!,
      completedAt: DateTime.now(),
    );

    final saver = ref.read(simonScoreSaverProvider.notifier);
    await saver.saveScore(score);
  }
}
