import 'package:flutter/material.dart';

import '../../constants/settings_design_tokens.dart';

/// Standardized list tile for settings options
/// Provides consistent layout and interaction patterns
class SettingsListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;
  final bool showDivider;

  const SettingsListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor ?? 
                           (iconColor ?? SettingsDesignTokens.primaryColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: enabled 
                        ? (iconColor ?? SettingsDesignTokens.primaryColor)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: enabled 
                              ? null
                              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: enabled 
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ?? (onTap != null 
                    ? Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: enabled 
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
      ],
    );
  }
}
