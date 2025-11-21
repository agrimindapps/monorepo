import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../presentation/providers/index.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';

/// Theme Settings Section
/// Allows users to toggle dark mode
class NewThemeSection extends ConsumerWidget {
  const NewThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeSettingsNotifierProvider);

    return Column(
      children: [
        const SectionHeader(title: 'Aparência'),
        SettingsCard(
          child: Column(
            children: [
              _buildDarkModeToggle(context, ref, themeState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDarkModeToggle(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo Escuro',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Use tema escuro para melhor conforto visual',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: themeState.settings.isDarkTheme,
            onChanged: (value) {
              ref.read(themeSettingsNotifierProvider.notifier).toggleDarkMode();
            },
          ),
        ],
      ),
    );
  }
}
