import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'enums.dart';

/// Immutable entity representing the complete state of the Tower game
class GameState extends Equatable {
  final List<BlockData> blocks;
  final double currentBlockPosX;
  final double currentBlockWidth;
  final double lastBlockX;
  final bool movingRight;
  final int score;
  final int combo;
  final int lastDropScore;
  final double blockSpeed;
  final GameDifficulty difficulty;
  final bool isPaused;
  final bool isGameOver;
  final bool isPerfectPlacement;
  final double screenWidth;

  const GameState({
    required this.blocks,
    required this.currentBlockPosX,
    required this.currentBlockWidth,
    required this.lastBlockX,
    required this.movingRight,
    required this.score,
    required this.combo,
    required this.lastDropScore,
    required this.blockSpeed,
    required this.difficulty,
    required this.isPaused,
    required this.isGameOver,
    required this.isPerfectPlacement,
    required this.screenWidth,
  });

  /// Factory constructor for initial game state
  factory GameState.initial({
    required double screenWidth,
    GameDifficulty difficulty = GameDifficulty.medium,
  }) {
    return GameState(
      blocks: const [],
      currentBlockPosX: 0,
      currentBlockWidth: 200.0,
      lastBlockX: 0,
      movingRight: true,
      score: 0,
      combo: 0,
      lastDropScore: 0,
      blockSpeed: 5.0 * difficulty.speedMultiplier,
      difficulty: difficulty,
      isPaused: false,
      isGameOver: false,
      isPerfectPlacement: false,
      screenWidth: screenWidth,
    );
  }

  /// Block colors cycle
  static const List<Color> blockColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.cyan,
    Colors.indigo,
  ];

  /// Get color for next block
  Color get nextBlockColor {
    return blockColors[blocks.length % blockColors.length];
  }

  /// Block height constant
  static const double blockHeight = 30.0;

  /// Creates a copy of this game state with updated fields
  GameState copyWith({
    List<BlockData>? blocks,
    double? currentBlockPosX,
    double? currentBlockWidth,
    double? lastBlockX,
    bool? movingRight,
    int? score,
    int? combo,
    int? lastDropScore,
    double? blockSpeed,
    GameDifficulty? difficulty,
    bool? isPaused,
    bool? isGameOver,
    bool? isPerfectPlacement,
    double? screenWidth,
  }) {
    return GameState(
      blocks: blocks ?? this.blocks,
      currentBlockPosX: currentBlockPosX ?? this.currentBlockPosX,
      currentBlockWidth: currentBlockWidth ?? this.currentBlockWidth,
      lastBlockX: lastBlockX ?? this.lastBlockX,
      movingRight: movingRight ?? this.movingRight,
      score: score ?? this.score,
      combo: combo ?? this.combo,
      lastDropScore: lastDropScore ?? this.lastDropScore,
      blockSpeed: blockSpeed ?? this.blockSpeed,
      difficulty: difficulty ?? this.difficulty,
      isPaused: isPaused ?? this.isPaused,
      isGameOver: isGameOver ?? this.isGameOver,
      isPerfectPlacement: isPerfectPlacement ?? this.isPerfectPlacement,
      screenWidth: screenWidth ?? this.screenWidth,
    );
  }

  @override
  List<Object?> get props => [
        blocks,
        currentBlockPosX,
        currentBlockWidth,
        lastBlockX,
        movingRight,
        score,
        combo,
        lastDropScore,
        blockSpeed,
        difficulty,
        isPaused,
        isGameOver,
        isPerfectPlacement,
        screenWidth,
      ];
}
