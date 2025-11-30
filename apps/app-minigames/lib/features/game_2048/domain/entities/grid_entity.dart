import 'package:equatable/equatable.dart';

import 'position_entity.dart';
import 'tile_entity.dart';

/// Represents the game grid (4x4, 5x5, or 6x6)
class GridEntity extends Equatable {
  final List<TileEntity> tiles;
  final int size;

  const GridEntity({
    required this.tiles,
    required this.size,
  });

  /// Creates an empty grid
  factory GridEntity.empty(int size) {
    return GridEntity(tiles: const [], size: size);
  }

  /// Gets tile at specific position (nullable)
  TileEntity? getTileAt(PositionEntity position) {
    try {
      return tiles.firstWhere(
        (tile) => tile.position.isSameAs(position),
      );
    } catch (_) {
      return null;
    }
  }

  /// Checks if position is empty
  bool isEmptyAt(PositionEntity position) {
    return getTileAt(position) == null;
  }

  /// Gets all empty positions
  List<PositionEntity> getEmptyPositions() {
    final List<PositionEntity> emptyPositions = [];

    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final position = PositionEntity(row: row, col: col);
        if (isEmptyAt(position)) {
          emptyPositions.add(position);
        }
      }
    }

    return emptyPositions;
  }

  /// Checks if grid is full
  bool get isFull => tiles.length == size * size;

  /// Gets highest tile value
  int get maxTileValue {
    if (tiles.isEmpty) return 0;
    return tiles.map((t) => t.value).reduce((a, b) => a > b ? a : b);
  }

  /// Checks if player has reached 2048
  bool get has2048Tile => tiles.any((tile) => tile.value >= 2048);

  /// Adds a tile to the grid
  GridEntity addTile(TileEntity tile) {
    final newTiles = List<TileEntity>.from(tiles)..add(tile);
    return GridEntity(tiles: newTiles, size: size);
  }

  /// Removes a tile from the grid
  GridEntity removeTile(String tileId) {
    final newTiles = tiles.where((t) => t.id != tileId).toList();
    return GridEntity(tiles: newTiles, size: size);
  }

  /// Updates a tile in the grid
  GridEntity updateTile(TileEntity updatedTile) {
    final newTiles = tiles.map((t) {
      return t.id == updatedTile.id ? updatedTile : t;
    }).toList();
    return GridEntity(tiles: newTiles, size: size);
  }

  /// Replaces all tiles
  GridEntity replaceTiles(List<TileEntity> newTiles) {
    return GridEntity(tiles: newTiles, size: size);
  }

  /// Clears all animation flags
  GridEntity clearAnimations() {
    final clearedTiles = tiles.map((t) => t.clearAnimation()).toList();
    return GridEntity(tiles: clearedTiles, size: size);
  }

  /// Gets tiles as 2D array for easier manipulation
  List<List<TileEntity?>> toMatrix() {
    final matrix = List.generate(
      size,
      (_) => List<TileEntity?>.filled(size, null),
    );

    for (final tile in tiles) {
      matrix[tile.position.row][tile.position.col] = tile;
    }

    return matrix;
  }

  @override
  List<Object?> get props => [tiles, size];

  @override
  String toString() => 'Grid(size: $size, tiles: ${tiles.length})';
}
