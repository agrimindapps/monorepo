import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/position.dart';

/// Widget for a single grid cell in the word search
class GridCellWidget extends StatelessWidget {
  final String letter;
  final int row;
  final int col;
  final GameState gameState;
  final VoidCallback onTap;

  const GridCellWidget({
    super.key,
    required this.letter,
    required this.row,
    required this.col,
    required this.gameState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final position = Position(row, col);
    final isSelected = gameState.selectedPositions.contains(position);
    final isPartOfFoundWord = _isPartOfFoundWord(position);
    final isPartOfHighlightedWord = _isPartOfHighlightedWord(position);

    Color backgroundColor;
    Color textColor = Colors.black87;

    if (isPartOfFoundWord) {
      backgroundColor = Colors.green.shade300;
      textColor = Colors.white;
    } else if (isPartOfHighlightedWord) {
      backgroundColor = Colors.blue.shade200;
    } else if (isSelected) {
      backgroundColor = Colors.amber.shade300;
    } else {
      backgroundColor = Colors.grey.shade100;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Checks if position is part of a found word
  bool _isPartOfFoundWord(Position position) {
    return gameState.words
        .where((word) => word.isFound)
        .any((word) => word.positions.contains(position));
  }

  /// Checks if position is part of a highlighted word
  bool _isPartOfHighlightedWord(Position position) {
    return gameState.words
        .where((word) => word.isHighlighted && !word.isFound)
        .any((word) => word.positions.contains(position));
  }
}
