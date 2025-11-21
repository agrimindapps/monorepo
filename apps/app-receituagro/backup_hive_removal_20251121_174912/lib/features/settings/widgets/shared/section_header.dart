import 'package:flutter/material.dart';

import '../../constants/settings_design_tokens.dart';

/// Standardized section header for settings pages
/// Provides consistent title styling and spacing
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? action;
  final EdgeInsets? padding;
  final bool showIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.action,
    this.padding,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, 12, 16, 4),
      child: Row(
        children: [
          if (showIcon && icon != null) ...[
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: SettingsDesignTokens.getSectionTitleStyle(context)
                  .copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
