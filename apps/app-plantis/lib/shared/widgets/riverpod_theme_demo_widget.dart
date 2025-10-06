import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/providers/theme_providers.dart';

/// Widget de demonstração da migração Theme Provider → Riverpod
///
/// Este widget mostra ambas as abordagens funcionando lado a lado:
/// - Provider (legacy): Via Consumer widget
/// - Riverpod (novo): Via ConsumerWidget e ref.watch()
///
/// Durante a migração, ambos os providers funcionam simultaneamente,
/// permitindo validação antes da remoção completa do Provider legacy.
class RiverpodThemeDemoWidget extends ConsumerWidget {
  const RiverpodThemeDemoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riverpodThemeState = ref.watch(themeNotifierProvider);
    final riverpodThemeSettings = riverpodThemeState.settings;
    final isRiverpodLoading = riverpodThemeState.isLoading;
    final riverpodError = riverpodThemeState.errorMessage;
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Migração Provider → Riverpod',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '🚀 Novo: Riverpod ThemeProvider',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRiverpodLoading)
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Carregando configurações...'),
                      ],
                    ),

                  if (riverpodError != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              riverpodError,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!isRiverpodLoading && riverpodError == null) ...[
                    _buildInfoRow(
                      context,
                      'Modo atual',
                      _getThemeModeText(riverpodThemeSettings.themeMode),
                    ),
                    _buildInfoRow(
                      context,
                      'Seguir sistema',
                      riverpodThemeSettings.followSystemTheme ? 'Sim' : 'Não',
                    ),
                    _buildInfoRow(
                      context,
                      'É modo escuro',
                      riverpodThemeSettings.isDarkMode ? 'Sim' : 'Não',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => themeNotifier.setLightTheme(),
                          icon: const Icon(Icons.light_mode, size: 16),
                          label: const Text('Claro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                riverpodThemeSettings.isLightMode
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                            foregroundColor:
                                riverpodThemeSettings.isLightMode
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => themeNotifier.setDarkTheme(),
                          icon: const Icon(Icons.dark_mode, size: 16),
                          label: const Text('Escuro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                riverpodThemeSettings.isDarkMode
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                            foregroundColor:
                                riverpodThemeSettings.isDarkMode
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => themeNotifier.setSystemTheme(),
                          icon: const Icon(Icons.settings_brightness, size: 16),
                          label: const Text('Sistema'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                riverpodThemeSettings.followSystemTheme
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                            foregroundColor:
                                riverpodThemeSettings.followSystemTheme
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '⚡ Providers de Conveniência',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildProviderDemo(context, ref)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDemo(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(plantisIsDarkModeProvider);
    final isLightMode = ref.watch(plantisIsLightModeProvider);
    final followSystemTheme = ref.watch(plantisFollowSystemThemeProvider);
    final themeStatusText = ref.watch(themeStatusTextProvider);
    final themeIcon = ref.watch(themeIconProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(themeIcon, size: 16),
            const SizedBox(width: 8),
            Text(themeStatusText),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            _buildBooleanChip(context, 'Modo Escuro', isDarkMode),
            _buildBooleanChip(context, 'Modo Claro', isLightMode),
            _buildBooleanChip(context, 'Seguir Sistema', followSystemTheme),
          ],
        ),
      ],
    );
  }

  Widget _buildBooleanChip(BuildContext context, String label, bool value) {
    return Chip(
      label: Text(
        '$label: ${value ? "✓" : "✗"}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      backgroundColor:
          value
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}
