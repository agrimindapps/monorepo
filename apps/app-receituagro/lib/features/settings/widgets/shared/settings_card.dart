import 'package:flutter/material.dart';

import '../../constants/settings_design_tokens.dart';

/// Standardized card widget for settings sections
/// Provides consistent styling across all settings components
class SettingsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final bool showBorder;
  final Color? borderColor;

  const SettingsCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(SettingsDesignTokens.cardBorderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}