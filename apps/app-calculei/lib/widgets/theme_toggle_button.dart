import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_providers.dart';

/// Botão de alternância de tema (claro/escuro)
/// 
/// Exibe um ícone de sol/lua que alterna entre os temas
/// Usa animação suave para transição de ícones
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({
    super.key,
    this.iconSize = 24.0,
    this.color,
    this.tooltip,
    this.showSnackBar = true,
  });

  /// Tamanho do ícone
  final double iconSize;
  
  /// Cor do ícone (usa cor do tema se null)
  final Color? color;
  
  /// Tooltip customizado
  final String? tooltip;
  
  /// Se deve mostrar SnackBar ao trocar tema
  final bool showSnackBar;

  void _showThemeSnackBar(BuildContext context, bool isDark) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isDark ? 'Tema Escuro ativado' : 'Tema Claro ativado',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween(begin: 0.5, end: 1.0).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          size: iconSize,
          color: color,
        ),
      ),
      tooltip: tooltip ?? (isDark ? 'Tema Claro' : 'Tema Escuro'),
      onPressed: () {
        ref.read(themeModeProvider.notifier).toggleTheme();
        if (showSnackBar) {
          // Show snackbar with the NEW theme (opposite of current)
          _showThemeSnackBar(context, !isDark);
        }
      },
    );
  }
}

/// Botão de tema com estilo de chip/badge
/// 
/// Versão mais elaborada com fundo e label
class ThemeToggleChip extends ConsumerWidget {
  const ThemeToggleChip({
    super.key,
    this.showLabel = true,
    this.showSnackBar = true,
  });

  /// Se deve mostrar o label "Claro"/"Escuro"
  final bool showLabel;
  
  /// Se deve mostrar SnackBar ao trocar tema
  final bool showSnackBar;

  void _showThemeSnackBar(BuildContext context, bool isDark) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isDark ? 'Tema Escuro ativado' : 'Tema Claro ativado',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).toggleTheme();
          if (showSnackBar) {
            _showThemeSnackBar(context, !isDark);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDark),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  isDark ? 'Escuro' : 'Claro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
