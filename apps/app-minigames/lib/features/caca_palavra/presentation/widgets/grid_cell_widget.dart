import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/position.dart';

/// Widget for a single grid cell in the word search
class GridCellWidget extends StatelessWidget {
  final String letter;
  final int row;
  final int col;
  final GameState gameState;

  const GridCellWidget({
    super.key,
    required this.letter,
    required this.row,
    required this.col,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final position = Position(row, col);
    final isSelected = gameState.selectedPositions.contains(position);
    final isPartOfFoundWord = _isPartOfFoundWord(position);
    final isPartOfHighlightedWord = _isPartOfHighlightedWord(position);

    Color backgroundColor;
    Color textColor;

    if (isPartOfFoundWord) {
      backgroundColor = isDark ? Colors.green.shade700 : Colors.green.shade300;
      textColor = Colors.white;
    } else if (isPartOfHighlightedWord) {
      backgroundColor = isDark ? Colors.blue.shade800 : Colors.blue.shade200;
      textColor = isDark ? Colors.white : Colors.black87;
    } else if (isSelected) {
      backgroundColor = isDark ? Colors.amber.shade700 : Colors.amber.shade300;
      textColor = isDark ? Colors.white : Colors.black87;
    } else {
      backgroundColor = isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100;
      textColor = isDark ? Colors.white70 : Colors.black87;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: (isDark ? Colors.amber.shade700 : Colors.amber.shade300)
                      .withAlpha((0.6 * 255).round()),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
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
