import 'package:flutter/material.dart';

/// Standardized card widget for settings sections
/// Provides consistent styling across all settings components
class NewSettingsCard extends StatelessWidget {

  const NewSettingsCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.showBorder = false,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final bool showBorder;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ??
            (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF)),
        borderRadius: BorderRadius.circular(16.0),
        border: showBorder
            ? Border.all(
                color:
                    borderColor ??
                    theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF000000).withValues(alpha: 0.12),
            offset: const Offset(0, 3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : const Color(0xFF000000).withValues(alpha: 0.06),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}
