import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'simon_says_controller.g.dart';

enum SimonGameState { idle, showingSequence, waitingForInput, gameOver }

@immutable
class SimonState {
  final SimonGameState gameState;
  final List<int> sequence;
  final List<int> userSequence;
  final int score;
  final int? activeIndex; // The button currently lit up

  const SimonState({
    this.gameState = SimonGameState.idle,
    this.sequence = const [],
    this.userSequence = const [],
    this.score = 0,
    this.activeIndex,
  });

  SimonState copyWith({
    SimonGameState? gameState,
    List<int>? sequence,
    List<int>? userSequence,
    int? score,
    int? activeIndex,
    bool clearActiveIndex = false,
  }) {
    return SimonState(
      gameState: gameState ?? this.gameState,
      sequence: sequence ?? this.sequence,
      userSequence: userSequence ?? this.userSequence,
      score: score ?? this.score,
      activeIndex: clearActiveIndex ? null : (activeIndex ?? this.activeIndex),
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
    state = const SimonState(gameState: SimonGameState.showingSequence);
    await _addToSequenceAndShow();
  }

  Future<void> _addToSequenceAndShow() async {
    // Add new random color (0-3)
    final newSequence = List<int>.from(state.sequence)..add(_random.nextInt(4));
    
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
}
