import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/petiveti_theme_notifier.dart';

/// Dialog para seleção de tema no PetiVeti
class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(petiVetiThemeProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.palette_outlined, color: primaryColor),
          const SizedBox(width: 12),
          const Text('Escolher Tema'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            ref: ref,
            mode: ThemeMode.system,
            title: 'Automático (Sistema)',
            subtitle: 'Segue a configuração do sistema',
            icon: Icons.brightness_auto,
            isSelected: currentThemeMode == ThemeMode.system,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context: context,
            ref: ref,
            mode: ThemeMode.light,
            title: 'Claro',
            subtitle: 'Tema claro sempre ativo',
            icon: Icons.light_mode,
            isSelected: currentThemeMode == ThemeMode.light,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context: context,
            ref: ref,
            mode: ThemeMode.dark,
            title: 'Escuro',
            subtitle: 'Tema escuro sempre ativo',
            icon: Icons.dark_mode,
            isSelected: currentThemeMode == ThemeMode.dark,
            primaryColor: primaryColor,
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

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: () {
        ref.read(petiVetiThemeProvider.notifier).setThemeMode(mode);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? primaryColor
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Mostra o dialog de seleção de tema
void showThemeSelectionDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => const ThemeSelectionDialog(),
  );
}
