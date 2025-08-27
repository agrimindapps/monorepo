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
        ListTile(
          enabled: enabled,
          onTap: enabled ? onTap : null,
          contentPadding: SettingsDesignTokens.sectionPadding,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor ?? 
                     (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SettingsDesignTokens.iconContainerRadius),
            ),
            child: Icon(
              leadingIcon,
              color: enabled 
                  ? (iconColor ?? theme.colorScheme.primary)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: SettingsDesignTokens.getListTitleStyle(context).copyWith(
              color: enabled 
                  ? null
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
          subtitle: subtitle != null 
              ? Text(
                  subtitle!,
                  style: SettingsDesignTokens.getListSubtitleStyle(context).copyWith(
                    color: enabled 
                        ? null
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                )
              : null,
          trailing: trailing ?? (onTap != null 
              ? Icon(
                  Icons.chevron_right,
                  color: enabled 
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                )
              : null),
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