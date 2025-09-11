import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Notifications management section
/// Handles notification settings and testing
class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Notificações',
          icon: Icons.notifications,
          showIcon: true,
        ),
        SettingsCard(
          child: Column(
            children: [
              SettingsListTile(
                leadingIcon: Icons.notifications,
                title: 'Configurar Notificações',
                subtitle: 'Gerenciar alertas e lembretes',
                onTap: () => _showNotificationSettings(context),
                showDivider: true,
              ),
              SettingsListTile(
                leadingIcon: Icons.bug_report,
                title: 'Testar Notificação',
                subtitle: 'Enviar notificação de teste',
                onTap: () => _testNotification(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showNotificationSettings(BuildContext context) async {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Configurar Notificações'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configure os tipos de notificações que deseja receber:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Lista de opções de notificação
            _buildNotificationOption(
              context,
              title: 'Pragas Detectadas',
              subtitle: 'Alertas quando uma praga for identificada',
              icon: Icons.bug_report,
              enabled:
                  context.watch<PreferencesProvider>().pragasDetectadasEnabled,
              onChanged: (value) {
                context
                    .read<PreferencesProvider>()
                    .togglePragasDetectadas(value);
              },
            ),
            const SizedBox(height: 12),

            _buildNotificationOption(
              context,
              title: 'Lembretes de Aplicação',
              subtitle: 'Lembretes para aplicar defensivos',
              icon: Icons.schedule,
              enabled: context
                  .watch<PreferencesProvider>()
                  .lembretesAplicacaoEnabled,
              onChanged: (value) {
                context
                    .read<PreferencesProvider>()
                    .toggleLembretesAplicacao(value);
              },
            ),
            const SizedBox(height: 12),

            _buildNotificationOption(
              context,
              title: 'Novas Receitas',
              subtitle: 'Notificações de receitas adicionadas',
              icon: Icons.library_books,
              enabled: false,
            ),
            const SizedBox(height: 12),

            _buildNotificationOption(
              context,
              title: 'Alertas Climáticos',
              subtitle: 'Condições climáticas favoráveis',
              icon: Icons.wb_sunny,
              enabled: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<SettingsProvider>().openNotificationSettings();
            },
            child: Text(
              'Configurações do Sistema',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fechar',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    Function(bool)? onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled,
          onChanged: onChanged ??
              (value) {
                // Fallback para notificações não implementadas ainda
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Notificação ativada' : 'Notificação desativada',
                    ),
                  ),
                );
              },
        ),
      ],
    );
  }

  Future<void> _testNotification(BuildContext context) async {
    final provider = context.read<SettingsProvider>();

    try {
      final success = await provider.testNotification();

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getSuccessSnackbar(
              '🔔 Notificação de teste enviada!',
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar(
              provider.error ?? 'Erro ao enviar notificação',
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar(
              'Erro ao enviar notificação: $e'),
        );
      }
    }
  }
}
