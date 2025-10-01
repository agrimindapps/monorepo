import 'package:flutter/material.dart';
import 'package:core/core.dart' hide ThemeNotifier;

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_mode_enum.dart';
import '../../features/tasks/presentation/providers/theme_provider.dart';

class ThemeToggleSwitch extends ConsumerWidget {
  final bool showLabel;
  final MainAxisAlignment alignment;

  const ThemeToggleSwitch({
    super.key,
    this.showLabel = true,
    this.alignment = MainAxisAlignment.spaceBetween,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTheme = ref.watch(themeNotifierProvider);
    final currentTheme = ref.watch(currentThemeProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    
    return asyncTheme.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (themeMode) => _buildContent(context, currentTheme, themeNotifier),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeMode currentTheme, ThemeNotifier themeNotifier) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (showLabel)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tema',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  currentTheme.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        
        // Toggle buttons para os três modos
        SegmentedButton<AppThemeMode>(
          segments: AppThemeMode.values.map((mode) => ButtonSegment<AppThemeMode>(
            value: mode,
            icon: Icon(
              mode.icon,
              size: 20,
            ),
            label: Text(
              mode.displayName,
              style: const TextStyle(fontSize: 12),
            ),
          )).toList(),
          selected: {currentTheme},
          onSelectionChanged: (Set<AppThemeMode> selected) {
            if (selected.isNotEmpty) {
              themeNotifier.setThemeMode(selected.first);
            }
          },
          multiSelectionEnabled: false,
          showSelectedIcon: false,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Theme.of(context).colorScheme.surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.onPrimary;
              }
              return Theme.of(context).colorScheme.onSurface;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (showLabel)
          const Expanded(
            child: Text(
              'Carregando tema...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (showLabel)
          const Expanded(
            child: Text(
              'Erro ao carregar tema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        const Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 20,
        ),
      ],
    );
  }
}

// Widget alternativo mais simples - apenas ícone com tooltip
class ThemeToggleIcon extends ConsumerWidget {
  final double size;

  const ThemeToggleIcon({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    
    return IconButton(
      onPressed: () => themeNotifier.toggleTheme(),
      icon: Icon(
        currentTheme.icon,
        size: size,
      ),
      tooltip: 'Alternar para ${_getNextThemeDisplayName(currentTheme)}',
    );
  }

  String _getNextThemeDisplayName(AppThemeMode current) {
    switch (current) {
      case AppThemeMode.light:
        return 'tema escuro';
      case AppThemeMode.dark:
        return 'tema claro';
      case AppThemeMode.system:
        return 'tema claro';
    }
  }
}

// Widget para lista de opções (para uso em Settings)
class ThemeSelectionList extends ConsumerWidget {
  const ThemeSelectionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Aparência',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...AppThemeMode.values.map((mode) => RadioListTile<AppThemeMode>(
          title: Row(
            children: [
              Icon(
                mode.icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(mode.displayName),
            ],
          ),
          subtitle: Text(mode.description),
          value: mode,
          groupValue: currentTheme,
          onChanged: (value) {
            if (value != null) {
              themeNotifier.setThemeMode(value);
            }
          },
        )),
      ],
    );
  }
}