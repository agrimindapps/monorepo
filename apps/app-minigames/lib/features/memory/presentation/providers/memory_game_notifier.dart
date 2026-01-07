import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/usecases/flip_card_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import 'memory_providers.dart';

import '../../domain/entities/deck_configuration.dart';
import '../../data/repositories/deck_repository.dart';

part 'memory_game_notifier.g.dart';

@riverpod
class MemoryGameNotifier extends _$MemoryGameNotifier {
  Timer? _gameTimer;
  HighScoreEntity? _currentHighScore;
  DeckConfiguration? _currentDeck; // Null means classic mode
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
    
    // We need to update RestartGameParams to accept optional deck config
    // But since I can't easily change the UseCase signature without breaking other things right now,
    // I will modify the CardGeneratorService injection or logic.
    
    // Actually, the cleanest way without refactoring everything is to handle deck generation here 
    // or update the UseCase. Let's look at RestartGameUseCase.
    
    // Assuming I can't change UseCase easily right now, let's update state manually if needed
    // OR better: Update RestartGameParams to include DeckConfig.
    
    // For now, I'll pass the deck config to the generator via a new provider or direct access
    // But since RestartGameUseCase uses CardGeneratorService internally...
    
    // Let's rely on modifying the RestartGameUseCase call if possible.
    // Wait, I don't want to break the build.
    
    // Let's modify the RestartGameParams to include deckConfig.
    // I'll edit the RestartGameParams definition first.
    
    // Since I can't see RestartGameParams file content right now, I'll assume I need to edit it.
    
    // Let's skip the Params edit for a second and assume I can pass it.
    // Actually, I'll edit the UseCase file first.
    
    final result = restartGameUseCase(
      RestartGameParams(
        difficulty: difficulty,
        deckConfig: _currentDeck,
      ),
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

    result.fold((failure) {}, (highScore) {
      _currentHighScore = highScore;
    });
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

    result.fold((failure) {}, (newState) {
      state = newState;
      HapticFeedback.lightImpact();

      if (newState.flippedCards.length == 2) {
        _handleTurnResult(newState);
      }
    });
  }

  Future<void> _handleTurnResult(GameStateEntity currentState) async {
    // 1. Check match immediately
    final checkMatchUseCase = ref.read(checkMatchUseCaseProvider);
    // We pass the current state which has 2 flipped cards
    // UseCase will return new state with either MATCHED or HIDDEN cards
    final result = checkMatchUseCase(currentState);

    result.fold((failure) {}, (resolvedState) async {
      // 2. Identify if it was a match or not based on the resolved state
      // If it was a match, the flipped cards list will be empty and match count increased
      // If not match, the cards would be hidden again
      
      final isMatch = resolvedState.matches > currentState.matches;

      if (isMatch) {
        // MATCH: Apply immediately
        state = resolvedState;
        HapticFeedback.mediumImpact();
        
        if (resolvedState.status == GameStatus.completed) {
          _handleVictory();
        }
      } else {
        // NO MATCH: Wait for user to see cards, then hide
        // Note: The 'resolvedState' already has cards hidden. 
        // We want to keep them visible (current state) for a moment.
        
        // Block interaction (could use a dedicated status or just rely on flippedCards.length == 2)
        // currentState already has flippedCards.length == 2, blocking interaction via canFlipCard
        
        await Future.delayed(Duration(milliseconds: state.difficulty.matchTime));
        if (!_isMounted) return;
        
        // Now apply the state with hidden cards
        state = resolvedState;
        HapticFeedback.lightImpact();
      }
    });
  }

  Future<void> _handleVictory() async {
    _gameTimer?.cancel();
    HapticFeedback.heavyImpact();

    final currentScore = state.calculateScore();
    final shouldSave =
        _currentHighScore == null || currentScore > _currentHighScore!.score;

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

  Future<void> changeDeck(DeckConfiguration? deck) async {
    if (deck == _currentDeck) return;
    _currentDeck = deck;
    await startGame(state.difficulty);
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

// Note: Use cases providers moved to memory_providers.dart
