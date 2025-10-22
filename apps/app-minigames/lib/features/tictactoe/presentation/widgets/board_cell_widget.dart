import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

/// Widget for a single cell in the TicTacToe board
class BoardCellWidget extends StatelessWidget {
  final Player player;
  final bool isWinningCell;
  final VoidCallback? onTap;

  const BoardCellWidget({
    super.key,
    required this.player,
    this.isWinningCell = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isWinningCell
              ? player.color.withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isWinningCell ? player.color : Colors.grey[300]!,
            width: isWinningCell ? 3 : 1,
          ),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isWinningCell
                  ? player.color
                  : player.color.withValues(alpha: 0.8),
            ),
            child: Text(
              player.symbol,
              semanticsLabel: player.symbol.isNotEmpty
                  ? 'Célula com ${player.symbol}'
                  : 'Célula vazia',
            ),
          ),
        ),
      ),
    );
  }
}
