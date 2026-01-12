import 'package:flutter/material.dart';

/// Chip/botão de seleção adaptativo que responde ao tema
/// 
/// Usado para seleção de opções como culturas, espaçamentos, etc.
class AdaptiveChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const AdaptiveChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = selectedColor ?? Theme.of(context).colorScheme.primary;
    
    // Cores adaptativas
    final textColor = isSelected
        ? (isDark ? Colors.white : accentColor)
        : (isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7));
    
    final backgroundColor = isSelected
        ? (isDark ? accentColor.withValues(alpha: 0.2) : accentColor.withValues(alpha: 0.1))
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03));
    
    final borderColor = isSelected
        ? accentColor
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
