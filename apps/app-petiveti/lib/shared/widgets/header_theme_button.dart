import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/providers/petiveti_theme_notifier.dart';
import '../../features/settings/presentation/widgets/theme_selection_dialog.dart';

/// Botão de tema para usar em headers
/// Mostra o ícone do tema atual e abre dialog ao clicar
class HeaderThemeButton extends ConsumerWidget {
  const HeaderThemeButton({
    super.key,
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.size = 20.0,
    this.padding = 8.0,
  });

  final Color iconColor;
  final Color? backgroundColor;
  final double size;
  final double padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(petiVetiThemeProvider);

    return Semantics(
      label: 'Alterar tema',
      hint:
          'Abre diálogo para escolher entre tema claro, escuro ou automático. Atualmente: ${_getThemeDescription(themeMode)}',
      button: true,
      child: InkWell(
        onTap: () => showThemeSelectionDialog(context),
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            _getThemeIcon(themeMode),
            color: iconColor,
            size: size,
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Tema claro';
      case ThemeMode.dark:
        return 'Tema escuro';
      case ThemeMode.system:
        return 'Automático';
    }
  }
}
