import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/petiveti_theme_notifier.dart';
import '../../providers/settings_providers.dart';
import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção de preferências - tema, sons, vibração, etc
class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({
    this.onThemeChanged,
    this.onNotificationsTap,
    super.key,
  });

  final ValueChanged<bool>? onThemeChanged;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.value;
    final currentThemeMode = ref.watch(petiVetiThemeProvider);
    final isDarkMode = currentThemeMode == ThemeMode.dark;

    return Column(
      children: [
        const SectionHeader(title: 'Preferências'),
        NewSettingsCard(
          child: Column(
            children: [
              // Modo Escuro
              NewSettingsListTile(
                leadingIcon: Icons.dark_mode,
                title: 'Modo Escuro',
                subtitle: 'Usar tema escuro no aplicativo',
                showDivider: true,
                trailing: Switch.adaptive(
                  value: isDarkMode,
                  onChanged: settingsAsync.isLoading
                      ? null
                      : (value) {
                          // Atualiza o provider de tema dedicado
                          ref
                              .read(petiVetiThemeProvider.notifier)
                              .updateFromDarkMode(value);
                          // Atualiza também no settings para persistência
                          ref
                              .read(settingsProvider.notifier)
                              .updateDarkMode(value);
                          onThemeChanged?.call(value);
                        },
                ),
              ),
              // Sons
              NewSettingsListTile(
                leadingIcon: Icons.music_note,
                title: 'Sons',
                subtitle: 'Reproduzir sons no aplicativo',
                showDivider: true,
                trailing: Switch.adaptive(
                  value: settings?.soundsEnabled ?? true,
                  onChanged: settingsAsync.isLoading
                      ? null
                      : (value) {
                          ref.read(settingsProvider.notifier).updateSoundsEnabled(value);
                        },
                ),
              ),
              // Vibração
              NewSettingsListTile(
                leadingIcon: Icons.vibration,
                title: 'Vibração',
                subtitle: 'Feedback háptico ao interagir',
                trailing: Switch.adaptive(
                  value: settings?.vibrationEnabled ?? true,
                  onChanged: settingsAsync.isLoading
                      ? null
                      : (value) {
                          ref.read(settingsProvider.notifier).updateVibrationEnabled(value);
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
