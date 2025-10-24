import 'package:flutter/material.dart';
import 'package:app_minigames/features/memory/domain/entities/card_entity.dart';
import 'package:app_minigames/features/memory/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/memory/domain/entities/high_score_entity.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/snake/domain/entities/game_state.dart';
import 'package:app_minigames/features/snake/domain/entities/position.dart';
import 'package:app_minigames/features/snake/domain/entities/enums.dart';

class TestFixtures {
  // Memory Game Fixtures
  static CardEntity createCard({
    String id = 'card_0',
    int pairId = 0,
    Color color = Colors.red,
    IconData icon = Icons.star,
    CardState state = CardState.hidden,
    int position = 0,
  }) {
    return CardEntity(
      id: id,
      pairId: pairId,
      color: color,
      icon: icon,
      state: state,
      position: position,
    );
  }

  static List<CardEntity> createCardPair({
    int pairId = 0,
    Color color = Colors.red,
    IconData icon = Icons.star,
    CardState state = CardState.hidden,
  }) {
    return [
      createCard(
        id: 'card_${pairId * 2}',
        pairId: pairId,
        color: color,
        icon: icon,
        state: state,
        position: pairId * 2,
      ),
      createCard(
        id: 'card_${pairId * 2 + 1}',
        pairId: pairId,
        color: color,
        icon: icon,
        state: state,
        position: pairId * 2 + 1,
      ),
    ];
  }

  static GameStateEntity createGameState({
    List<CardEntity>? cards,
    List<CardEntity> flippedCards = const [],
    int moves = 0,
    int matches = 0,
    GameStatus status = GameStatus.initial,
    GameDifficulty difficulty = GameDifficulty.easy,
    DateTime? startTime,
    Duration? elapsedTime,
    String? errorMessage,
  }) {
    return GameStateEntity(
      cards: cards ?? _createDefaultCards(difficulty),
      flippedCards: flippedCards,
      moves: moves,
      matches: matches,
      status: status,
      difficulty: difficulty,
      startTime: startTime,
      elapsedTime: elapsedTime,
      errorMessage: errorMessage,
    );
  }

  static List<CardEntity> _createDefaultCards(GameDifficulty difficulty) {
    final List<CardEntity> cards = [];
    final totalPairs = difficulty.totalPairs;

    for (int i = 0; i < totalPairs; i++) {
      cards.addAll(createCardPair(pairId: i));
    }

    return cards;
  }

  static GameStateEntity createGameStateWithTwoFlippedCards({
    bool matching = true,
    GameDifficulty difficulty = GameDifficulty.easy,
  }) {
    final cards = [
      createCard(id: 'card_0', pairId: 0, state: CardState.revealed, position: 0),
      createCard(id: 'card_1', pairId: 0, state: CardState.revealed, position: 1),
      createCard(id: 'card_2', pairId: 1, state: CardState.hidden, position: 2),
      createCard(id: 'card_3', pairId: 1, state: CardState.hidden, position: 3),
      createCard(id: 'card_4', pairId: 2, state: CardState.hidden, position: 4),
      createCard(id: 'card_5', pairId: 2, state: CardState.hidden, position: 5),
      createCard(id: 'card_6', pairId: 3, state: CardState.hidden, position: 6),
      createCard(id: 'card_7', pairId: 3, state: CardState.hidden, position: 7),
    ];

    final flippedCards = matching
        ? [cards[0], cards[1]] // Same pairId = match
        : [cards[0], cards[2]]; // Different pairId = no match

    return GameStateEntity(
      cards: cards,
      flippedCards: flippedCards,
      moves: 1,
      matches: 0,
      status: GameStatus.playing,
      difficulty: difficulty,
    );
  }

  static GameStateEntity createGameStateWithOneFlippedCard() {
    final cards = [
      createCard(id: 'card_0', pairId: 0, state: CardState.revealed, position: 0),
      createCard(id: 'card_1', pairId: 0, state: CardState.hidden, position: 1),
      createCard(id: 'card_2', pairId: 1, state: CardState.hidden, position: 2),
      createCard(id: 'card_3', pairId: 1, state: CardState.hidden, position: 3),
    ];

    return GameStateEntity(
      cards: cards,
      flippedCards: [cards[0]],
      moves: 0,
      matches: 0,
      status: GameStatus.playing,
      difficulty: GameDifficulty.easy,
    );
  }

  static HighScoreEntity createHighScore({
    GameDifficulty difficulty = GameDifficulty.medium,
    int score = 1000,
    int moves = 20,
    Duration time = const Duration(seconds: 60),
    DateTime? achievedAt,
  }) {
    return HighScoreEntity(
      difficulty: difficulty,
      score: score,
      moves: moves,
      time: time,
      achievedAt: achievedAt ?? DateTime(2024, 1, 1),
    );
  }

  // Snake Game Fixtures
  static SnakeGameState createSnakeGameState({
    List<Position>? snake,
    Position? foodPosition,
    Direction direction = Direction.right,
    int score = 0,
    int gridSize = 20,
    SnakeGameStatus gameStatus = SnakeGameStatus.notStarted,
    SnakeDifficulty difficulty = SnakeDifficulty.medium,
  }) {
    return SnakeGameState(
      snake: snake ?? [Position(10, 10)],
      foodPosition: foodPosition ?? Position(15, 10),
      direction: direction,
      score: score,
      gridSize: gridSize,
      gameStatus: gameStatus,
      difficulty: difficulty,
    );
  }

  static SnakeGameState createSnakeGameStateMoving({
    Direction direction = Direction.right,
    int length = 3,
  }) {
    final snake = List.generate(
      length,
      (i) => Position(10 - i, 10),
    );

    return SnakeGameState(
      snake: snake,
      foodPosition: Position(15, 10),
      direction: direction,
      score: 0,
      gridSize: 20,
      gameStatus: SnakeGameStatus.running,
      difficulty: SnakeDifficulty.medium,
    );
  }

  static SnakeGameState createSnakeGameStateAboutToCollide() {
    return SnakeGameState(
      snake: [
        Position(10, 10), // head
        Position(9, 10),
        Position(8, 10),
        Position(8, 11), // will collide after up->left->up moves
      ],
      foodPosition: Position(15, 10),
      direction: Direction.right,
      score: 0,
      gridSize: 20,
      gameStatus: SnakeGameStatus.running,
      difficulty: SnakeDifficulty.medium,
    );
  }

  static SnakeGameState createSnakeGameStateAboutToEat() {
    return SnakeGameState(
      snake: [
        Position(14, 10), // head next to food
        Position(13, 10),
        Position(12, 10),
      ],
      foodPosition: Position(15, 10),
      direction: Direction.right,
      score: 5,
      gridSize: 20,
      gameStatus: SnakeGameStatus.running,
      difficulty: SnakeDifficulty.medium,
    );
  }
}
