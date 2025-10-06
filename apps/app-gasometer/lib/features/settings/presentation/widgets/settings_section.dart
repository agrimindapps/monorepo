import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';

/// Reusable settings section widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of rendering a settings section with title
/// Follows OCP: Open for extension via child widgets customization
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.subtitle,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

}