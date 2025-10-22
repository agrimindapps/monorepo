import 'package:flutter/material.dart';

/// Virtual keyboard for letter input
class LetterKeyboardWidget extends StatelessWidget {
  final Set<String> guessedLetters;
  final Function(String) onLetterPressed;
  final bool enabled;

  const LetterKeyboardWidget({
    super.key,
    required this.guessedLetters,
    required this.onLetterPressed,
    this.enabled = true,
  });

  static const List<String> _keyboardLayout = [
    'QWERTYUIOP',
    'ASDFGHJKL',
    'ZXCVBNM',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _keyboardLayout.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              final isGuessed = guessedLetters.contains(letter);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _KeyButton(
                  letter: letter,
                  isGuessed: isGuessed,
                  enabled: enabled && !isGuessed,
                  onPressed: () => onLetterPressed(letter),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String letter;
  final bool isGuessed;
  final bool enabled;
  final VoidCallback onPressed;

  const _KeyButton({
    required this.letter,
    required this.isGuessed,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 42,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isGuessed
              ? Colors.grey.shade400
              : enabled
                  ? Colors.blue.shade500
                  : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
