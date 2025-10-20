import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_notifier.dart';

/// Dialog simplificado de seleção de tema
/// - Header compacto com X para fechar
/// - Opções sem descrições
/// - Sem bordas ao redor
/// - Layout minimalista
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context, theme),
            const SizedBox(height: 16),
            _buildThemeOptions(context, theme, ref, currentThemeMode),
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
            Icons.palette,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tema do Aplicativo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildThemeOptions(BuildContext context, ThemeData theme, WidgetRef ref, ThemeMode currentThemeMode) {
    return Column(
      children: [
        _buildThemeOption(
          context,
          theme,
          ref,
          currentThemeMode,
          ThemeMode.light,
          'Tema Claro',
          Icons.light_mode,
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          context,
          theme,
          ref,
          currentThemeMode,
          ThemeMode.dark,
          'Tema Escuro',
          Icons.dark_mode,
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          context,
          theme,
          ref,
          currentThemeMode,
          ThemeMode.system,
          'Automático',
          Icons.brightness_auto,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    ThemeMode currentThemeMode,
    ThemeMode themeMode,
    String title,
    IconData icon,
  ) {
    final isSelected = currentThemeMode == themeMode;

    return Semantics(
      label: title,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => _onThemeSelected(context, ref, themeMode, title),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
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
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
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
