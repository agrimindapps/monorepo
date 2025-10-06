import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_notifier.dart';
import '../../constants/settings_design_tokens.dart';

class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeNotifierProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context, theme),
            const SizedBox(height: 20),
            _buildThemeOptions(context, theme, ref, currentThemeMode),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            SettingsDesignTokens.paletteIcon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tema do Aplicativo',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Escolha a aparência do app',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOptions(BuildContext context, ThemeData theme, WidgetRef ref, ThemeMode currentThemeMode) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            theme,
            ref,
            currentThemeMode,
            ThemeMode.light,
            'Tema Claro',
            'Interface sempre clara',
            Icons.light_mode,
            isFirst: true,
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildThemeOption(
            context,
            theme,
            ref,
            currentThemeMode,
            ThemeMode.dark,
            'Tema Escuro',
            'Interface sempre escura',
            Icons.dark_mode,
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildThemeOption(
            context,
            theme,
            ref,
            currentThemeMode,
            ThemeMode.system,
            'Automático',
            'Segue as configurações do sistema',
            Icons.brightness_auto,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    ThemeMode currentThemeMode,
    ThemeMode themeMode,
    String title,
    String subtitle,
    IconData icon, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = currentThemeMode == themeMode;

    return Semantics(
      label: '$title. $subtitle',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => _onThemeSelected(context, ref, themeMode, title),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(8) : Radius.zero,
          bottom: isLast ? const Radius.circular(8) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(8) : Radius.zero,
              bottom: isLast ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Fechar',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onThemeSelected(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    String themeName,
  ) async {
    await ref.read(themeNotifierProvider.notifier).setThemeMode(themeMode);

    if (context.mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tema $themeName aplicado'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
