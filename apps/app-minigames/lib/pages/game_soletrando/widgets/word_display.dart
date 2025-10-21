// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'letter_display.dart';

class WordDisplayPanel extends StatelessWidget {
  final List<String> displayWord;
  final String hint;
  final bool showHint;

  const WordDisplayPanel({
    super.key,
    required this.displayWord,
    required this.hint,
    this.showHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            if (showHint)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Dica: $hint',
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: displayWord.map((letter) {
                return LetterDisplay(
                  letter: letter,
                  isRevealed: letter != '_',
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
