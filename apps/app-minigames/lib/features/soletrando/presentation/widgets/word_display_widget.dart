import 'package:flutter/material.dart';

import '../../domain/entities/game_state_entity.dart';

/// Widget to display the word with revealed/hidden letters
class WordDisplayWidget extends StatelessWidget {
  final GameStateEntity gameState;

  const WordDisplayWidget({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Category hint
            Text(
              gameState.currentWord.category.hint,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 16),

            // Word letters
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: gameState.letters.map((letter) {
                return _LetterBox(
                  letter: letter.displayChar,
                  isRevealed: letter.isRevealed,
                );
              }).toList(),
            ),

            if (gameState.currentWord.definition != null) ...[
              const SizedBox(height: 16),
              Text(
                gameState.currentWord.definition!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LetterBox extends StatelessWidget {
  final String letter;
  final bool isRevealed;

  const _LetterBox({
    required this.letter,
    required this.isRevealed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: isRevealed ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRevealed ? Colors.blue.shade400 : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isRevealed ? Colors.blue.shade900 : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
