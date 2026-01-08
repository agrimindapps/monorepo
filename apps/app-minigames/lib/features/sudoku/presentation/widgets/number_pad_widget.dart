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
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Numbers 1-5
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final number = index + 1;
              return _buildNumberButton(number, theme, isDark);
            }),
          ),
          const SizedBox(height: 8),
          // Numbers 6-9 and Clear
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...List.generate(4, (index) {
                final number = index + 6;
                return _buildNumberButton(number, theme, isDark);
              }),
              _buildClearButton(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number, ThemeData theme, bool isDark) {
    // Colors for dark theme
    final normalBgColor = isDark
        ? const Color(0xFF4A3C6E) // Purple for dark theme
        : theme.primaryColor;
    final notesBgColor = isDark
        ? const Color(0xFF2A2A3E) // Subtle dark for notes mode
        : theme.primaryColor.withValues(alpha: 0.2);
    final normalTextColor = Colors.white;
    final notesTextColor = isDark
        ? const Color(0xFF9C7CF2)
        : theme.primaryColor;

    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => onNumberTap(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: notesMode ? notesBgColor : normalBgColor,
          foregroundColor: notesMode ? notesTextColor : normalTextColor,
          padding: EdgeInsets.zero,
          elevation: notesMode ? 0 : 4,
          shadowColor: isDark ? Colors.black54 : Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: notesMode
                ? BorderSide(
                    color: notesTextColor.withValues(alpha: 0.5),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildClearButton(bool isDark) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onClearTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF5C3A3A) // Dark red for dark theme
              : Colors.red.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          elevation: 4,
          shadowColor: isDark ? Colors.black54 : Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(Icons.backspace_outlined, size: 24),
      ),
    );
  }
}
