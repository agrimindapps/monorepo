import 'package:equatable/equatable.dart';

/// Configuration for a sprite sheet based deck
class DeckConfiguration extends Equatable {
  final String id;
  final String name;
  final String assetPath;
  final int rows;
  final int columns;
  final int spriteWidth;
  final int spriteHeight;
  final int totalSprites;

  const DeckConfiguration({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.rows,
    required this.columns,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.totalSprites,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        assetPath,
        rows,
        columns,
        spriteWidth,
        spriteHeight,
        totalSprites,
      ];
}
