import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/app_settings.dart';
import '../dialogs/feedback_dialog.dart';
import '../managers/settings_sections_builder.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_toggle.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

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
        data: (AppSettings settings) => ListView(
          padding: const EdgeInsets.all(8),
          children: [
            // User Section
            SettingsSectionsBuilder.buildUserSection(
              context,
              theme,
              authState.user,
              authState,
            ),
            const SizedBox(height: 8),

            // Premium Section
            SettingsSectionsBuilder.buildPremiumSectionCard(context, theme),
            const SizedBox(height: 16),

            // Preferences Section
            SettingsSectionsBuilder.buildSectionHeader(context, 'Preferências'),
            SettingsSectionsBuilder.buildSettingsCard(context, [
              // Appearance
              SettingsToggle(
                title: 'Modo Escuro',
                subtitle: 'Usar tema escuro no aplicativo',
                value: settings.darkMode,
                icon: Icons.dark_mode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateDarkMode(value);
                },
              ),
              const Divider(),
              // Notifications - Now navigates to dedicated page
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    settings.notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: const Text('Notificações'),
                subtitle: Text(
                  settings.notificationsEnabled
                      ? 'Ativadas - Toque para configurar'
                      : 'Desativadas - Toque para ativar',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/notifications-settings'),
              ),
              const Divider(),
              // Sounds
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
              // Vibration
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
            ]),
            const SizedBox(height: 16),

            // Language & Region
            SettingsSectionsBuilder.buildSectionHeader(
              context,
              'Idioma e Região',
            ),
            SettingsSectionsBuilder.buildSettingsCard(context, [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.translate),
                title: const Text('Idioma do Aplicativo'),
                subtitle: Text(_getLanguageName(settings.language)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showLanguageDialog(context, ref, settings.language),
              ),
            ]),
            const SizedBox(height: 16),

            // Sync Section
            SettingsSectionsBuilder.buildSectionHeader(
              context,
              'Sincronização',
            ),
            SettingsSectionsBuilder.buildSettingsCard(context, [
              SettingsToggle(
                title: 'Sincronização Automática',
                subtitle: 'Sincronizar dados automaticamente',
                value: settings.autoSync,
                icon: Icons.cloud_sync,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateAutoSync(value);
                },
              ),
              if (settings.lastSyncAt != null) ...[
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.history),
                  title: const Text('Última Sincronização'),
                  subtitle: Text(_formatDateTime(settings.lastSyncAt!)),
                ),
              ],
            ]),
            const SizedBox(height: 16),

            // Support Section
            SettingsSectionsBuilder.buildSectionHeader(context, 'Suporte'),
            SettingsSectionsBuilder.buildSettingsCard(context, [
              SettingsSectionsBuilder.buildSettingsItem(
                context,
                icon: Icons.star_rate,
                title: 'Avaliar o App',
                subtitle: 'Avalie nossa experiência na loja',
                onTap: () => _showRateAppDialog(context),
              ),
              SettingsSectionsBuilder.buildSettingsItem(
                context,
                icon: Icons.feedback,
                title: 'Enviar Feedback',
                subtitle: 'Ajude-nos a melhorar o app',
                onTap: () => _showFeedbackDialog(context),
              ),
              SettingsSectionsBuilder.buildSettingsItem(
                context,
                icon: Icons.help_outline,
                title: 'Central de Ajuda',
                subtitle: 'Perguntas frequentes e tutoriais',
                onTap: () => _launchHelpUrl(),
              ),
              SettingsSectionsBuilder.buildSettingsItem(
                context,
                icon: Icons.support_agent,
                title: 'Fale Conosco',
                subtitle: 'Entre em contato com o suporte',
                onTap: () => _launchSupportEmail(),
              ),
            ]),
            const SizedBox(height: 16),

            // Legal Section
            SettingsSectionsBuilder.buildSectionHeader(context, 'Legal'),
            SettingsSectionsBuilder.buildSettingsCard(context, [
              SettingsSectionsBuilder.buildSettingsItem(
                context,
                icon: Icons.privacy_tip,
                title: 'Política de Privacidade',
                subtitle: 'Como protegemos seus dados',
                onTap: () => context.push('/privacy-policy'),
              ),
              SettingsSectionsBuilder.buildSettingsItem(
                context,
                icon: Icons.description,
                title: 'Termos de Uso',
                subtitle: 'Termos e condições de uso',
                onTap: () => context.push('/terms-of-service'),
              ),
              SettingsSectionsBuilder.buildSettingsItem(
                context,
                icon: Icons.delete_forever,
                title: 'Política de Exclusão de Conta',
                subtitle: 'Como seus dados são removidos',
                onTap: () => context.push('/account-deletion-policy'),
              ),
            ]),
            const SizedBox(height: 32),

            // Reset Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: OutlinedButton.icon(
                onPressed: () => _showResetConfirmation(context, ref),
                icon: const Icon(Icons.restore),
                label: const Text('Restaurar Padrões'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
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

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLanguage,
  ) {
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
              onChanged: (value) {
                // ignore: deprecated_member_use
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

  void _showFeedbackDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  Future<void> _showRateAppDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avaliar o PetiVeti'),
        content: const Text(
          'Você está gostando do PetiVeti? Sua avaliação nos ajuda muito!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora Não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Avaliar'),
          ),
        ],
      ),
    );

    if (result == true) {
      // TODO: Implement actual app store opening
      // For now, just show a message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abrindo loja de aplicativos...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://petiveti.com/ajuda');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'suporte@petiveti.com',
      query: 'subject=Suporte PetiVeti',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
