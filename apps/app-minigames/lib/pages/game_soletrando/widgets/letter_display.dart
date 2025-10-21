// Flutter imports:
import 'package:flutter/material.dart';

class LetterDisplay extends StatelessWidget {
  final String letter;
  final bool isRevealed;

  const LetterDisplay({
    super.key,
    required this.letter,
    required this.isRevealed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: isRevealed ? Colors.blue.withValues(alpha: 0.2) : Colors.white,
        border: Border.all(
          color: isRevealed ? Colors.blue : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isRevealed
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isRevealed ? Colors.indigo : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
