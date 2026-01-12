import 'package:flutter/material.dart';

/// Card de informação adaptativo (como hints e recomendações)
/// 
/// Responde ao tema claro/escuro
class AdaptiveInfoCard extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;
  final bool isWarning;

  const AdaptiveInfoCard({
    super.key,
    required this.message,
    this.icon,
    this.color,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isWarning ? Colors.orange : Colors.blue);
    
    final backgroundColor = isDark
        ? cardColor.withValues(alpha: 0.15)
        : cardColor.withValues(alpha: 0.1);
    
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.8);
    
    final iconColor = isDark
        ? cardColor.withValues(alpha: 0.8)
        : cardColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
