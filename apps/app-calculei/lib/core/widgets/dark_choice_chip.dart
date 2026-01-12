import 'package:flutter/material.dart';

/// Theme-adaptive choice chip for calculators
/// Works properly in both dark and light modes
class DarkChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color accentColor;

  const DarkChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.2)
          : isDark 
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : isDark 
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check,
                  size: 16,
                  color: accentColor,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? accentColor
                      : isDark 
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
