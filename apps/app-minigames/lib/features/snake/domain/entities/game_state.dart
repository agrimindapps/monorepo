// Package imports:
import 'package:equatable/equatable.dart';

// Domain imports:
import 'position.dart';
import 'enums.dart';
import 'power_up.dart';

/// Entity representing the current state of the snake game
class SnakeGameState extends Equatable {
  final List<Position> snake; // Snake body (head is first element)
  final Position foodPosition;
  final Direction direction;
  final int score;
  final int gridSize;
  final SnakeGameStatus gameStatus;
  final SnakeDifficulty difficulty;
  final bool hasWalls; // Whether walls kill the snake (true) or wrap around (false)
  final Set<Position> freePositions; // Cached free positions for performance
  final List<PowerUp> powerUpsOnGrid; // Power-ups on grid awaiting collection
  final List<ActivePowerUp> activePowerUps; // Currently active power-up effects
  final SnakeGameMode gameMode; // Current game mode
  final int elapsedSeconds; // For survival mode and stats
  final int foodEatenThisGame; // Food eaten in current game
  final Map<String, int> powerUpsCollectedThisGame; // Power-ups collected by type
  final int timeAttackRemainingSeconds; // For time attack mode
  final SnakeDeathType? lastDeathType; // How the snake died

  const SnakeGameState({
    required this.snake,
    required this.foodPosition,
    required this.direction,
    required this.score,
    required this.gridSize,
    required this.gameStatus,
    required this.difficulty,
    required this.hasWalls,
    required this.freePositions,
    this.powerUpsOnGrid = const [],
    this.activePowerUps = const [],
    this.gameMode = SnakeGameMode.classic,
    this.elapsedSeconds = 0,
    this.foodEatenThisGame = 0,
    this.powerUpsCollectedThisGame = const {},
    this.timeAttackRemainingSeconds = 120,
    this.lastDeathType,
  });

  /// Initial state (not started)
  factory SnakeGameState.initial({
    int gridSize = 20,
    SnakeDifficulty difficulty = SnakeDifficulty.medium,
    bool hasWalls = false,
    SnakeGameMode gameMode = SnakeGameMode.classic,
  }) {
    final center = gridSize ~/ 2;
    final initialSnake = [Position(center, center)];
    final freePositions = _calculateFreePositions(gridSize, initialSnake);

    return SnakeGameState(
      snake: initialSnake,
      foodPosition: Position(center + 5, center),
      direction: Direction.right,
      score: 0,
      gridSize: gridSize,
      gameStatus: SnakeGameStatus.notStarted,
      difficulty: difficulty,
      hasWalls: hasWalls,
      freePositions: freePositions,
      powerUpsOnGrid: const [],
      activePowerUps: const [],
      gameMode: gameMode,
      elapsedSeconds: 0,
      foodEatenThisGame: 0,
      powerUpsCollectedThisGame: const {},
      timeAttackRemainingSeconds: 120,
      lastDeathType: null,
    );
  }

  /// Calculates all free positions in the grid (not occupied by snake)
  static Set<Position> _calculateFreePositions(
    int gridSize,
    List<Position> snake,
  ) {
    final freePositions = <Position>{};
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final pos = Position(x, y);
        if (!snake.contains(pos)) {
          freePositions.add(pos);
        }
      }
    }
    return freePositions;
  }

  /// Get snake head position
  Position get head => snake.first;

  /// Get snake length
  int get length => snake.length;

  /// Check if position contains food
  bool isFood(int x, int y) => foodPosition == Position(x, y);

  /// Check if position contains snake
  bool isSnake(int x, int y) => snake.contains(Position(x, y));

  /// Check if position is snake head
  bool isSnakeHead(int x, int y) => head == Position(x, y);

  /// Check if position contains a power-up
  bool isPowerUp(int x, int y) =>
      powerUpsOnGrid.any((p) => p.position == Position(x, y));

  /// Get power-up at position (if any)
  PowerUp? getPowerUpAt(int x, int y) {
    final pos = Position(x, y);
    try {
      return powerUpsOnGrid.firstWhere((p) => p.position == pos);
    } catch (_) {
      return null;
    }
  }

  // Power-up status getters
  bool get hasShield =>
      activePowerUps.any((p) => p.type == PowerUpType.shield && p.isActive);

  bool get hasDoublePoints =>
      activePowerUps.any((p) => p.type == PowerUpType.doublePoints && p.isActive);

  bool get hasSpeedBoost =>
      activePowerUps.any((p) => p.type == PowerUpType.speedBoost && p.isActive);

  bool get hasSlowMotion =>
      activePowerUps.any((p) => p.type == PowerUpType.slowMotion && p.isActive);

  bool get hasMagnet =>
      activePowerUps.any((p) => p.type == PowerUpType.magnet && p.isActive);

  bool get hasGhostMode =>
      activePowerUps.any((p) => p.type == PowerUpType.ghostMode && p.isActive);

  /// Get current score multiplier based on active power-ups
  int get scoreMultiplier => hasDoublePoints ? 2 : 1;

  /// Create a copy with modified fields
  SnakeGameState copyWith({
    List<Position>? snake,
    Position? foodPosition,
    Direction? direction,
    int? score,
    int? gridSize,
    SnakeGameStatus? gameStatus,
    SnakeDifficulty? difficulty,
    bool? hasWalls,
    Set<Position>? freePositions,
    List<PowerUp>? powerUpsOnGrid,
    List<ActivePowerUp>? activePowerUps,
    SnakeGameMode? gameMode,
    int? elapsedSeconds,
    int? foodEatenThisGame,
    Map<String, int>? powerUpsCollectedThisGame,
    int? timeAttackRemainingSeconds,
    SnakeDeathType? lastDeathType,
  }) {
    // Auto-calculate freePositions if snake changed but freePositions not provided
    final newSnake = snake ?? this.snake;
    final newFreePositions = freePositions ??
        (snake != null ? _calculateFreePositions(gridSize ?? this.gridSize, newSnake) : this.freePositions);

    return SnakeGameState(
      snake: newSnake,
      foodPosition: foodPosition ?? this.foodPosition,
      direction: direction ?? this.direction,
      score: score ?? this.score,
      gridSize: gridSize ?? this.gridSize,
      gameStatus: gameStatus ?? this.gameStatus,
      difficulty: difficulty ?? this.difficulty,
      hasWalls: hasWalls ?? this.hasWalls,
      freePositions: newFreePositions,
      powerUpsOnGrid: powerUpsOnGrid ?? this.powerUpsOnGrid,
      activePowerUps: activePowerUps ?? this.activePowerUps,
      gameMode: gameMode ?? this.gameMode,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      foodEatenThisGame: foodEatenThisGame ?? this.foodEatenThisGame,
      powerUpsCollectedThisGame: powerUpsCollectedThisGame ?? this.powerUpsCollectedThisGame,
      timeAttackRemainingSeconds: timeAttackRemainingSeconds ?? this.timeAttackRemainingSeconds,
      lastDeathType: lastDeathType ?? this.lastDeathType,
    );
  }

  @override
  List<Object?> get props => [
        snake,
        foodPosition,
        direction,
        score,
        gridSize,
        gameStatus,
        difficulty,
        hasWalls,
        freePositions,
        powerUpsOnGrid,
        activePowerUps,
        gameMode,
        elapsedSeconds,
        foodEatenThisGame,
        powerUpsCollectedThisGame,
        timeAttackRemainingSeconds,
        lastDeathType,
      ];
}
