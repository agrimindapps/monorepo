import 'dart:math';

import 'package:injectable/injectable.dart';

import '../entities/grid_entity.dart';
import '../entities/position_entity.dart';
import '../entities/tile_entity.dart';

/// Service responsible for spawning new tiles in the game grid
///
/// Handles:
/// - Random position selection
/// - Tile value determination (2 or 4)
/// - Probability distribution (90% = 2, 10% = 4)
@lazySingleton
class TileSpawnerService {
  final Random _random;

  TileSpawnerService({Random? random}) : _random = random ?? Random();

  // ============================================================================
  // Constants
  // ============================================================================

  /// Probability threshold for spawning a 2 tile (90%)
  static const int value2Threshold = 9;

  /// Value for common tiles (90% chance)
  static const int commonValue = 2;

  /// Value for rare tiles (10% chance)
  static const int rareValue = 4;

  /// Maximum probability range (10 = 0-9)
  static const int probabilityRange = 10;

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Spawns a new tile in a random empty position
  ///
  /// Returns null if no empty positions available
  TileEntity? spawnTile(GridEntity grid) {
    final emptyPositions = grid.getEmptyPositions();

    if (emptyPositions.isEmpty) {
      return null;
    }

    final position = selectRandomPosition(emptyPositions);
    final value = determineValue();

    return TileEntity.spawn(
      value: value,
      position: position,
    );
  }

  /// Spawns multiple tiles (used for game initialization)
  ///
  /// Returns list of successfully spawned tiles
  List<TileEntity> spawnMultipleTiles(GridEntity grid, int count) {
    final List<TileEntity> spawnedTiles = [];
    GridEntity currentGrid = grid;

    for (int i = 0; i < count; i++) {
      final tile = spawnTile(currentGrid);

      if (tile == null) {
        break; // No more space
      }

      spawnedTiles.add(tile);
      currentGrid = currentGrid.addTile(tile);
    }

    return spawnedTiles;
  }

  /// Determines value for new tile (2 or 4)
  ///
  /// Distribution:
  /// - 90% chance of 2
  /// - 10% chance of 4
  int determineValue() {
    final roll = _random.nextInt(probabilityRange);
    return roll < value2Threshold ? commonValue : rareValue;
  }

  /// Selects random position from list of available positions
  PositionEntity selectRandomPosition(List<PositionEntity> positions) {
    if (positions.isEmpty) {
      throw ArgumentError('Cannot select position from empty list');
    }

    final index = _random.nextInt(positions.length);
    return positions[index];
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Checks if grid has space for new tile
  bool canSpawnTile(GridEntity grid) {
    return grid.getEmptyPositions().isNotEmpty;
  }

  /// Gets number of available positions
  int getAvailableSpaceCount(GridEntity grid) {
    return grid.getEmptyPositions().length;
  }

  /// Calculates spawn probability for specific value
  double getSpawnProbability(int value) {
    if (value == commonValue) {
      return value2Threshold / probabilityRange; // 0.9 = 90%
    } else if (value == rareValue) {
      return (probabilityRange - value2Threshold) /
          probabilityRange; // 0.1 = 10%
    }
    return 0.0;
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates spawn configuration
  SpawnValidation validateSpawnConfig({
    required int gridSize,
    required int spawnCount,
  }) {
    final maxTiles = gridSize * gridSize;

    return SpawnValidation(
      isValid: spawnCount > 0 && spawnCount <= maxTiles,
      maxPossibleTiles: maxTiles,
      requestedCount: spawnCount,
      errorMessage: spawnCount <= 0
          ? 'Spawn count must be positive'
          : spawnCount > maxTiles
              ? 'Cannot spawn more tiles than grid capacity'
              : null,
    );
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets spawner statistics
  SpawnStatistics getStatistics({
    required GridEntity grid,
    required int totalSpawned,
  }) {
    final emptyCount = grid.getEmptyPositions().length;
    final totalCells = grid.size * grid.size;

    return SpawnStatistics(
      totalSpawned: totalSpawned,
      availablePositions: emptyCount,
      occupiedCells: totalCells - emptyCount,
      fillPercentage: ((totalCells - emptyCount) / totalCells * 100),
      canSpawnMore: emptyCount > 0,
    );
  }

  // ============================================================================
  // Testing Utilities
  // ============================================================================

  /// Creates spawn configuration for testing
  SpawnTestConfig createTestConfig({
    int? forcedValue,
    PositionEntity? forcedPosition,
  }) {
    return SpawnTestConfig(
      forcedValue: forcedValue,
      forcedPosition: forcedPosition,
    );
  }

  /// Spawns tile with test configuration (deterministic)
  TileEntity? spawnWithConfig(
    GridEntity grid,
    SpawnTestConfig config,
  ) {
    final emptyPositions = grid.getEmptyPositions();

    if (emptyPositions.isEmpty) {
      return null;
    }

    final position =
        config.forcedPosition ?? selectRandomPosition(emptyPositions);
    final value = config.forcedValue ?? determineValue();

    return TileEntity.spawn(
      value: value,
      position: position,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Validation result for spawn operations
class SpawnValidation {
  final bool isValid;
  final int maxPossibleTiles;
  final int requestedCount;
  final String? errorMessage;

  const SpawnValidation({
    required this.isValid,
    required this.maxPossibleTiles,
    required this.requestedCount,
    this.errorMessage,
  });
}

/// Statistics about spawn operations
class SpawnStatistics {
  final int totalSpawned;
  final int availablePositions;
  final int occupiedCells;
  final double fillPercentage;
  final bool canSpawnMore;

  const SpawnStatistics({
    required this.totalSpawned,
    required this.availablePositions,
    required this.occupiedCells,
    required this.fillPercentage,
    required this.canSpawnMore,
  });
}

/// Test configuration for deterministic spawning
class SpawnTestConfig {
  final int? forcedValue;
  final PositionEntity? forcedPosition;

  const SpawnTestConfig({
    this.forcedValue,
    this.forcedPosition,
  });
}
