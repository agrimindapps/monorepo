import 'package:flutter/material.dart';

/// Reusable theme option widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of rendering a theme selection option
/// Follows OCP: Open for extension via theme mode enum
class ThemeOption extends StatelessWidget {
  const ThemeOption({
    super.key,
    required this.themeMode,
    required this.currentTheme,
    required this.onChanged,
    required this.title,
    required this.icon,
  });

  final ThemeMode themeMode;
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onChanged;
  final String title;
  final IconData icon;

  bool get isSelected => themeMode == currentTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(themeMode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
