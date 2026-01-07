import 'package:flutter/material.dart';

class NumberPadWidget extends StatelessWidget {
  final bool notesMode;
  final Function(int number) onNumberTap;
  final VoidCallback onClearTap;

  const NumberPadWidget({
    super.key,
    required this.notesMode,
    required this.onNumberTap,
    required this.onClearTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Numbers 1-5
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final number = index + 1;
              return _buildNumberButton(number, theme);
            }),
          ),
          const SizedBox(height: 8),
          // Numbers 6-9 and Clear
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...List.generate(4, (index) {
                final number = index + 6;
                return _buildNumberButton(number, theme);
              }),
              _buildClearButton(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number, ThemeData theme) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => onNumberTap(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: notesMode
              ? theme.primaryColor.withValues(alpha: 0.2)
              : theme.primaryColor,
          foregroundColor: notesMode ? theme.primaryColor : Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(ThemeData theme) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onClearTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Icon(Icons.backspace_outlined, size: 24),
      ),
    );
  }
}
