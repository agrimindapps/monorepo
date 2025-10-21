// Flutter imports:
import 'package:flutter/material.dart';

class LetterButton extends StatelessWidget {
  final String letter;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final bool isDisabled;

  const LetterButton({
    super.key,
    required this.letter,
    required this.onTap,
    this.backgroundColor = Colors.blue,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 65,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(8),
          backgroundColor: isDisabled ? Colors.grey : backgroundColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isDisabled ? null : onTap,
        child: Text(
          letter,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
