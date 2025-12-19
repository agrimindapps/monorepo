import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../widgets/section_header_widget.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/theme_selection_widgets.dart';
import '../widgets/language_selection_widgets.dart';
import '../widgets/default_view_selection_widgets.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeaderWidget(title: 'Aparência'),
            ThemeSelectionTile(
              currentTheme: settings.themeMode,
              onTap: () => _showThemeDialog(context, settings.themeMode),
            ),
            LanguageSelectionTile(
              currentLanguage: settings.language,
              onTap: () => _showLanguageDialog(context, settings.language),
            ),
            const Divider(height: 32),
            const SectionHeaderWidget(title: 'Notificações'),
            SettingsSwitchTile(
              title: 'Notificações',
              subtitle: 'Receber notificações do app',
              value: settings.notificationsEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleNotifications(value),
              icon: Icons.notifications_outlined,
            ),
            SettingsSwitchTile(
              title: 'Sons',
              subtitle: 'Tocar sons ao completar tarefas',
              value: settings.soundEffectsEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleSoundEffects(value),
              icon: Icons.volume_up_outlined,
            ),
            const Divider(height: 32),
            const SectionHeaderWidget(title: 'Sincronização'),
            SettingsSwitchTile(
              title: 'Sincronização Automática',
              subtitle: 'Sincronizar automaticamente com a nuvem',
              value: settings.autoSyncEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleAutoSync(value),
              icon: Icons.sync_outlined,
            ),
            const Divider(height: 32),
            const SectionHeaderWidget(title: 'Visualização'),
            DefaultViewSelectionTile(
              currentView: settings.defaultView,
              onTap: () => _showDefaultViewDialog(context, settings.defaultView),
            ),
            SettingsSwitchTile(
              title: 'Mostrar Tarefas Concluídas',
              subtitle: 'Exibir tarefas já finalizadas',
              value: settings.showCompletedTasks,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleShowCompletedTasks(value),
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar configurações: $error'),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, String currentTheme) {
    showDialog(
      context: context,
      builder: (context) => ThemeDialog(currentTheme: currentTheme),
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => LanguageDialog(currentLanguage: currentLanguage),
    );
  }

  void _showDefaultViewDialog(BuildContext context, String currentView) {
    showDialog(
      context: context,
      builder: (context) => DefaultViewDialog(currentView: currentView),
    );
  }
}
