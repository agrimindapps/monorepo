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
    // Dark theme optimized colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cellColor = isDark 
        ? const Color(0xFF2A2A3E) // Dark purple-gray
        : Colors.white;
    final cellBorderColor = isDark
        ? const Color(0xFF3E3E52) // Lighter purple-gray for border
        : Colors.black.withValues(alpha: 0.1);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isWinningCell
            ? player.color.withValues(alpha: 0.25)
            : cellColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinningCell
              ? player.color
              : isFocused
                  ? const Color(0xFF6A11CB)
                  : cellBorderColor,
          width: isWinningCell ? 3 : (isFocused ? 2 : 1.5),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          if (isDark && isWinningCell)
            BoxShadow(
              color: player.color.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
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
        final iconColor = isWinningCell 
            ? player.color 
            : player.color.withValues(alpha: 0.95);
            
        return Transform.scale(
          scale: value,
          child: Icon(
            player == Player.x ? Icons.close : Icons.circle_outlined,
            size: 64,
            color: iconColor,
            weight: 3.0, // Make icons bolder
          ),
        );
      },
    );
  }
}
