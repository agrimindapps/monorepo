import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'position.dart';
import 'word_entity.dart';

/// Immutable entity representing the complete game state
class GameState extends Equatable {
  final List<List<String>> grid;
  final List<WordEntity> words;
  final List<Position> selectedPositions;
  final GameDifficulty difficulty;
  final GameStatus status;
  final int foundWordsCount;

  const GameState({
    required this.grid,
    required this.words,
    required this.selectedPositions,
    required this.difficulty,
    required this.status,
    required this.foundWordsCount,
  });

  factory GameState.initial({
    GameDifficulty difficulty = GameDifficulty.medium,
  }) {
    final gridSize = difficulty.gridSize;
    return GameState(
      grid: List.generate(gridSize, (_) => List.filled(gridSize, '')),
      words: const [],
      selectedPositions: const [],
      difficulty: difficulty,
      status: GameStatus.playing,
      foundWordsCount: 0,
    );
  }

  // Computed properties (NOT business logic)

  int get gridSize => grid.length;

  bool get isCompleted => status.isCompleted;

  bool get isPlaying => status.isPlaying;

  double get progress =>
      words.isEmpty ? 0.0 : foundWordsCount / words.length;

  GameState copyWith({
    List<List<String>>? grid,
    List<WordEntity>? words,
    List<Position>? selectedPositions,
    GameDifficulty? difficulty,
    GameStatus? status,
    int? foundWordsCount,
  }) {
    return GameState(
      grid: grid ?? this.grid.map((row) => List<String>.from(row)).toList(),
      words: words ?? this.words,
      selectedPositions: selectedPositions ?? this.selectedPositions,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      foundWordsCount: foundWordsCount ?? this.foundWordsCount,
    );
  }

  @override
  List<Object?> get props => [
        grid,
        words,
        selectedPositions,
        difficulty,
        status,
        foundWordsCount,
      ];
}
