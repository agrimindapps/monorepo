import 'package:flutter/material.dart';

import '../../domain/entities/reversi_entities.dart';

class ReversiBoardCell extends StatelessWidget {
  final ReversiPlayer? piece;
  final bool isValidMove;
  final VoidCallback onTap;

  const ReversiBoardCell({
    super.key,
    required this.piece,
    required this.isValidMove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        child: Center(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (piece != null) {
      return _buildPiece(piece!);
    }
    
    if (isValidMove) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade300.withValues(alpha: 0.5),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildPiece(ReversiPlayer player) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.8;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: player == ReversiPlayer.black ? Colors.black : Colors.white,
            border: Border.all(
              color: player == ReversiPlayer.black ? Colors.grey.shade800 : Colors.grey.shade400,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScoreDisplay extends StatelessWidget {
  final int blackCount;
  final int whiteCount;
  final ReversiPlayer currentPlayer;
  final bool isGameOver;

  const ScoreDisplay({
    super.key,
    required this.blackCount,
    required this.whiteCount,
    required this.currentPlayer,
    required this.isGameOver,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPlayerScore(
          ReversiPlayer.black,
          blackCount,
          currentPlayer == ReversiPlayer.black && !isGameOver,
        ),
        _buildPlayerScore(
          ReversiPlayer.white,
          whiteCount,
          currentPlayer == ReversiPlayer.white && !isGameOver,
        ),
      ],
    );
  }

  Widget _buildPlayerScore(ReversiPlayer player, int count, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade700 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player == ReversiPlayer.black ? Colors.black : Colors.white,
              border: Border.all(color: Colors.grey, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
