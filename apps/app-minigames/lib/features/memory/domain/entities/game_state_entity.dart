import 'package:equatable/equatable.dart';
import 'card_entity.dart';
import 'enums.dart';

class GameStateEntity extends Equatable {
  final List<CardEntity> cards;
  final List<CardEntity> flippedCards;
  final int moves;
  final int matches;
  final GameStatus status;
  final GameDifficulty difficulty;
  final DateTime? startTime;
  final Duration? elapsedTime;
  final String? errorMessage;

  const GameStateEntity({
    required this.cards,
    this.flippedCards = const [],
    this.moves = 0,
    this.matches = 0,
    this.status = GameStatus.initial,
    this.difficulty = GameDifficulty.medium,
    this.startTime,
    this.elapsedTime,
    this.errorMessage,
  });

  bool get isGameWon => matches == totalPairs && status == GameStatus.completed;
  int get totalPairs => difficulty.totalPairs;
  int get totalCards => difficulty.totalCards;
  bool get canFlipCard =>
      status.canInteract && flippedCards.length < 2 && !isProcessingMatch;
  bool get isProcessingMatch => flippedCards.length == 2;

  int calculateScore() {
    if (moves == 0 || elapsedTime == null || elapsedTime!.inSeconds == 0) {
      return 0;
    }

    final efficiency = totalPairs.toDouble() / moves;
    final speedFactor = totalPairs.toDouble() * 10 / elapsedTime!.inSeconds;
    final efficiencyFactor = (efficiency * speedFactor).clamp(0.1, 3.0);

    return ((matches * 100 * difficulty.difficultyMultiplier) * efficiencyFactor)
        .round();
  }

  GameStateEntity copyWith({
    List<CardEntity>? cards,
    List<CardEntity>? flippedCards,
    int? moves,
    int? matches,
    GameStatus? status,
    GameDifficulty? difficulty,
    DateTime? startTime,
    Duration? elapsedTime,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GameStateEntity(
      cards: cards ?? this.cards,
      flippedCards: flippedCards ?? this.flippedCards,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        cards,
        flippedCards,
        moves,
        matches,
        status,
        difficulty,
        startTime,
        elapsedTime,
        errorMessage,
      ];

  @override
  String toString() =>
      'GameStateEntity(moves: $moves, matches: $matches, status: $status, difficulty: ${difficulty.label})';
}
