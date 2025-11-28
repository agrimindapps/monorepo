import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_toggle.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(settingsProvider),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (AppSettings settings) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              SettingsSection(
                title: 'Aparência',
                icon: Icons.palette,
                children: [
                  SettingsToggle(
                    title: 'Modo Escuro',
                    subtitle: 'Usar tema escuro no aplicativo',
                    value: settings.darkMode,
                    icon: Icons.dark_mode,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateDarkMode(value);
                    },
                  ),
                ],
              ),

              // Notifications Section
              SettingsSection(
                title: 'Notificações',
                icon: Icons.notifications,
                children: [
                  SettingsToggle(
                    title: 'Notificações',
                    subtitle: 'Receber notificações do aplicativo',
                    value: settings.notificationsEnabled,
                    icon: Icons.notifications_active,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateNotificationsEnabled(value);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: const Text('Antecedência dos Lembretes'),
                    subtitle: Text('${settings.reminderHoursBefore} horas antes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showReminderHoursDialog(context, ref, settings.reminderHoursBefore),
                  ),
                ],
              ),

              // Sound & Haptics Section
              SettingsSection(
                title: 'Som e Feedback',
                icon: Icons.volume_up,
                children: [
                  SettingsToggle(
                    title: 'Sons',
                    subtitle: 'Reproduzir sons no aplicativo',
                    value: settings.soundsEnabled,
                    icon: Icons.music_note,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateSoundsEnabled(value);
                    },
                  ),
                  const Divider(),
                  SettingsToggle(
                    title: 'Vibração',
                    subtitle: 'Feedback háptico ao interagir',
                    value: settings.vibrationEnabled,
                    icon: Icons.vibration,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateVibrationEnabled(value);
                    },
                  ),
                ],
              ),

              // Language Section
              SettingsSection(
                title: 'Idioma',
                icon: Icons.language,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.translate),
                    title: const Text('Idioma do Aplicativo'),
                    subtitle: Text(_getLanguageName(settings.language)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context, ref, settings.language),
                  ),
                ],
              ),

              // Sync Section
              SettingsSection(
                title: 'Sincronização',
                icon: Icons.sync,
                children: [
                  SettingsToggle(
                    title: 'Sincronização Automática',
                    subtitle: 'Sincronizar dados automaticamente',
                    value: settings.autoSync,
                    icon: Icons.cloud_sync,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateAutoSync(value);
                    },
                  ),
                  if (settings.lastSyncAt != null) ...[
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: const Text('Última Sincronização'),
                      subtitle: Text(_formatDateTime(settings.lastSyncAt!)),
                    ),
                  ],
                ],
              ),

              // Reset Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showResetConfirmation(context, ref),
                    icon: const Icon(Icons.restore),
                    label: const Text('Restaurar Padrões'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Erro ao carregar configurações'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(settingsProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      case 'es_ES':
        return 'Español';
      default:
        return code;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showReminderHoursDialog(BuildContext context, WidgetRef ref, int currentValue) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Antecedência dos Lembretes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [6, 12, 24, 48, 72].map((hours) {
            return RadioListTile<int>.adaptive(
              title: Text('$hours horas antes'),
              value: hours,
              groupValue: currentValue, // ignore: deprecated_member_use
              onChanged: (value) { // ignore: deprecated_member_use
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateReminderHoursBefore(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLanguage) {
    final languages = [
      {'code': 'pt_BR', 'name': 'Português (Brasil)'},
      {'code': 'en_US', 'name': 'English (US)'},
      {'code': 'es_ES', 'name': 'Español'},
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma do Aplicativo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>.adaptive(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: currentLanguage, // ignore: deprecated_member_use
              onChanged: (value) { // ignore: deprecated_member_use
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrões'),
        content: const Text(
          'Tem certeza que deseja restaurar todas as configurações para os valores padrão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}
