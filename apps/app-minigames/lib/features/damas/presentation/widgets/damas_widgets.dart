import 'package:flutter/material.dart';

import '../../domain/entities/damas_entities.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final bool isSelected;
  final double size;

  const PieceWidget({
    super.key,
    required this.piece,
    this.isSelected = false,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: piece.color,
        border: Border.all(
          color: isSelected ? Colors.yellow : Colors.black,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        gradient: RadialGradient(
          colors: [
            piece.color.withValues(alpha: 0.8),
            piece.color,
          ],
          center: const Alignment(-0.3, -0.3),
        ),
      ),
      child: piece.isKing
          ? Center(
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: size * 0.5,
              ),
            )
          : null,
    );
  }
}

class BoardSquare extends StatelessWidget {
  final bool isDark;
  final bool isValidMove;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;

  const BoardSquare({
    super.key,
    required this.isDark,
    required this.onTap,
    this.isValidMove = false,
    this.isSelected = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF769656) 
              : const Color(0xFFEEEED2),
          border: isSelected
              ? Border.all(color: Colors.yellow, width: 3)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isValidMove)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.5),
                ),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
