import 'dart:ui';
import '../entities/block_data.dart';

/// Model representing block generation result
class BlockGenerationResult {
  /// The newly created block
  final BlockData block;

  /// The X position for the block
  final double posX;

  /// The width of the new block
  final double width;

  /// The color of the new block
  final Color color;

  const BlockGenerationResult({
    required this.block,
    required this.posX,
    required this.width,
    required this.color,
  });
}

/// Service responsible for creating and managing blocks
///
/// This service handles all block-related operations:
/// - New block creation
/// - Color cycling through palette
/// - Block positioning and sizing
/// - Initial block generation
class BlockGenerationService {
  /// Color palette for blocks (cycles through these colors)
  static const List<Color> blockColors = [
    Color(0xFFE53935), // Red
    Color(0xFF1E88E5), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFFF6F00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFF00ACC1), // Teal
    Color(0xFFFFB300), // Amber
    Color(0xFFD81B60), // Pink
    Color(0xFF00897B), // Cyan
    Color(0xFF5E35B1), // Indigo
  ];

  /// Standard block height (all blocks have the same height)
  static const double blockHeight = 30.0;

  /// Initial block width for new games
  static const double initialBlockWidth = 100.0;

  /// Creates a new block with specified dimensions
  ///
  /// [width] Width of the new block
  /// [posX] X position of the block
  /// [colorIndex] Index in the color palette (0 to blockColors.length - 1)
  ///
  /// Returns a [BlockGenerationResult] with the created block
  BlockGenerationResult createBlock({
    required double width,
    required double posX,
    required int colorIndex,
  }) {
    // Get color from palette, cycling if index exceeds length
    final color = blockColors[colorIndex % blockColors.length];

    // Create the block data
    final block = BlockData(
      width: width,
      height: blockHeight,
      posX: posX,
      color: color,
    );

    return BlockGenerationResult(
      block: block,
      posX: posX,
      width: width,
      color: color,
    );
  }

  /// Creates the initial block for a new game
  ///
  /// [screenWidth] Width of the game screen
  ///
  /// Returns a [BlockGenerationResult] with the first block
  BlockGenerationResult createInitialBlock(double screenWidth) {
    // First block is centered on screen
    final posX = (screenWidth - initialBlockWidth) / 2;

    return createBlock(
      width: initialBlockWidth,
      posX: posX,
      colorIndex: 0, // Start with first color
    );
  }

  /// Creates a new moving block after a drop
  ///
  /// The new block starts with the same width as the previous placed block
  /// and appears at the left edge of the screen.
  ///
  /// [previousBlockWidth] Width of the last placed block
  /// [colorIndex] Index for the next color in the palette
  ///
  /// Returns a [BlockGenerationResult] with the new moving block
  BlockGenerationResult createMovingBlock({
    required double previousBlockWidth,
    required int colorIndex,
  }) {
    // New block starts at left edge
    return createBlock(
      width: previousBlockWidth,
      posX: 0,
      colorIndex: colorIndex,
    );
  }

  /// Gets the next color index in the palette
  ///
  /// [currentBlocks] List of currently placed blocks
  ///
  /// Returns the index for the next color
  int getNextColorIndex(List<BlockData> currentBlocks) {
    // Color index is based on number of blocks placed
    return currentBlocks.length % blockColors.length;
  }

  /// Gets a color by index from the palette
  ///
  /// [index] The color index (will wrap around if > palette size)
  ///
  /// Returns the color at that index
  Color getColorByIndex(int index) {
    return blockColors[index % blockColors.length];
  }

  /// Calculates the width for the next block after a drop
  ///
  /// In Tower games, the next block width matches the overlap/precision
  /// of the previous drop to increase difficulty.
  ///
  /// [overlap] The overlap distance from the drop
  /// [minimumWidth] Minimum width to maintain (prevents blocks from becoming too small)
  ///
  /// Returns the calculated width for the next block
  double calculateNextBlockWidth({
    required double overlap,
    double minimumWidth = 20.0,
  }) {
    // Next block width equals overlap, but never below minimum
    return overlap.clamp(minimumWidth, double.infinity);
  }

  /// Creates a block at a specific position with custom color
  ///
  /// [width] Width of the block
  /// [posX] X position of the block
  /// [color] Custom color for the block
  ///
  /// Returns the created BlockData
  BlockData createCustomBlock({
    required double width,
    required double posX,
    required Color color,
  }) {
    return BlockData(
      width: width,
      height: blockHeight,
      posX: posX,
      color: color,
    );
  }

  /// Validates if a block width is acceptable
  ///
  /// [width] The width to validate
  /// [minimumWidth] Minimum acceptable width
  /// [maximumWidth] Maximum acceptable width
  ///
  /// Returns true if width is within bounds
  bool isValidBlockWidth({
    required double width,
    double minimumWidth = 20.0,
    double maximumWidth = 500.0,
  }) {
    return width >= minimumWidth && width <= maximumWidth;
  }

  /// Gets the total number of available colors
  ///
  /// Returns the size of the color palette
  int getColorPaletteSize() {
    return blockColors.length;
  }

  /// Gets all colors in the palette
  ///
  /// Returns a list of all available colors
  List<Color> getAllColors() {
    return List.unmodifiable(blockColors);
  }

  /// Calculates the center position for a block given screen width
  ///
  /// [blockWidth] Width of the block to center
  /// [screenWidth] Width of the screen
  ///
  /// Returns the X position that centers the block
  double calculateCenterPosition({
    required double blockWidth,
    required double screenWidth,
  }) {
    return (screenWidth - blockWidth) / 2;
  }

  /// Creates the foundation block for the game
  ///
  /// The foundation is the base block that all others stack on top of.
  ///
  /// [screenWidth] Width of the game screen
  /// [width] Width of the foundation block (defaults to initial width)
  ///
  /// Returns the foundation BlockData
  BlockData createFoundationBlock({
    required double screenWidth,
    double? width,
  }) {
    final blockWidth = width ?? initialBlockWidth;
    final posX = calculateCenterPosition(
      blockWidth: blockWidth,
      screenWidth: screenWidth,
    );

    return BlockData(
      width: blockWidth,
      height: blockHeight,
      posX: posX,
      color: blockColors[0], // Use first color for foundation
    );
  }

  /// Checks if a block is at a specific position
  ///
  /// [block] The block to check
  /// [targetPosX] The target X position
  /// [tolerance] Allowed distance for "close enough" matching
  ///
  /// Returns true if block position matches target within tolerance
  bool isBlockAtPosition({
    required BlockData block,
    required double targetPosX,
    double tolerance = 1.0,
  }) {
    return (block.posX - targetPosX).abs() <= tolerance;
  }

  /// Gets a descriptive name for a color
  ///
  /// [color] The color to describe
  ///
  /// Returns a Portuguese color name string
  String getColorName(Color color) {
    if (color == blockColors[0]) return 'Vermelho';
    if (color == blockColors[1]) return 'Azul';
    if (color == blockColors[2]) return 'Verde';
    if (color == blockColors[3]) return 'Laranja';
    if (color == blockColors[4]) return 'Roxo';
    if (color == blockColors[5]) return 'Turquesa';
    if (color == blockColors[6]) return 'Âmbar';
    if (color == blockColors[7]) return 'Rosa';
    if (color == blockColors[8]) return 'Ciano';
    if (color == blockColors[9]) return 'Índigo';
    return 'Desconhecido';
  }
}
