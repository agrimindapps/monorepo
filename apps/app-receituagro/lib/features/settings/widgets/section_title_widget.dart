import 'package:flutter/material.dart';
import '../constants/settings_design_tokens.dart';

/// Reusable section title widget following consistent design
class SectionTitleWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  
  const SectionTitleWidget({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? SettingsDesignTokens.primaryColor;
    
    return Padding(
      padding: SettingsDesignTokens.sectionPadding,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  SettingsDesignTokens.iconContainerRadius,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: SettingsDesignTokens.getSectionTitleStyle(context),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}