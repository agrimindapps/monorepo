// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'letter_button.dart';

class LettersKeyboard extends StatelessWidget {
  final List<String> letters;
  final Map<String, Color> letterColors;
  final Function(String) onLetterPressed;
  final bool isGameOver;

  const LettersKeyboard({
    super.key,
    required this.letters,
    required this.letterColors,
    required this.onLetterPressed,
    this.isGameOver = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: letters.map((letter) {
        final isDisabled = isGameOver || letterColors[letter] == Colors.grey;

        return LetterButton(
          letter: letter,
          backgroundColor: letterColors[letter] ?? Colors.blue,
          isDisabled: isDisabled,
          onTap: () => onLetterPressed(letter),
        );
      }).toList(),
    );
  }
}
