import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

/// Widget for a single cell in the TicTacToe board
class BoardCellWidget extends StatelessWidget {
  final Player player;
  final bool isWinningCell;
  final bool isFocused;

  const BoardCellWidget({
    super.key,
    required this.player,
    this.isWinningCell = false,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isWinningCell
            ? player.color.withValues(alpha: 0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: isWinningCell
            ? Border.all(color: player.color, width: 3)
            : isFocused
                ? Border.all(color: const Color(0xFF6A11CB), width: 2)
                : null,
      ),
      child: Center(
        child: _buildPlayerIcon(),
      ),
    );
  }

  Widget _buildPlayerIcon() {
    if (player == Player.none) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            player == Player.x ? Icons.close : Icons.circle_outlined,
            size: 64,
            color: isWinningCell ? player.color : player.color.withValues(alpha: 0.8),
          ),
        );
      },
    );
  }
}
