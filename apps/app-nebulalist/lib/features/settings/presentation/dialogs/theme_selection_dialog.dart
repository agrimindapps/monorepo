import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_notifier.dart';

/// Dialog para seleção de tema da aplicação
/// Permite escolher entre claro, escuro ou automático
class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return AlertDialog(
      title: const Text('Escolher Tema'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOption(
            mode: ThemeMode.system,
            title: 'Automático (Sistema)',
            subtitle: 'Segue a configuração do sistema',
            icon: Icons.brightness_auto,
            isSelected: currentTheme == ThemeMode.system,
            onTap: () => _handleThemeSelection(context, ref, ThemeMode.system),
          ),
          _ThemeOption(
            mode: ThemeMode.light,
            title: 'Claro',
            subtitle: 'Tema claro sempre ativo',
            icon: Icons.brightness_high,
            isSelected: currentTheme == ThemeMode.light,
            onTap: () => _handleThemeSelection(context, ref, ThemeMode.light),
          ),
          _ThemeOption(
            mode: ThemeMode.dark,
            title: 'Escuro',
            subtitle: 'Tema escuro sempre ativo',
            icon: Icons.brightness_2,
            isSelected: currentTheme == ThemeMode.dark,
            onTap: () => _handleThemeSelection(context, ref, ThemeMode.dark),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Future<void> _handleThemeSelection(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    await ref.read(themeProvider.notifier).setThemeMode(mode);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tema "${_getThemeName(mode)}" selecionado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Automático';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
    }
  }
}

/// Widget interno para cada opção de tema
class _ThemeOption extends StatelessWidget {
  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
