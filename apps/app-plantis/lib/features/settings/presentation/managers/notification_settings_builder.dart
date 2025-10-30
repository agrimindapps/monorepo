import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../providers/settings_notifier.dart';

/// Manager para construir e gerenciar componentes de notificações
/// Responsabilidade: Isolar construção de items e switches de notificações
class NotificationSettingsBuilder {
  /// Constrói card de status de notificações
  static Widget buildNotificationStatusCard(
    BuildContext context,
    WidgetRef ref,
    SettingsState settingsData,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  settingsData.notificationStatusIcon,
                  color: settingsData.notificationStatusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status das Notificações',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              settingsData.notificationStatusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: settingsData.notificationStatusColor,
              ),
            ),
            if (!settingsData.hasPermissionsGranted &&
                !settingsData.isWebPlatform)
              Column(
                children: [
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .openNotificationSettings();
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Abrir Configurações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Constrói item com switch de notificação
  static Widget buildNotificationSwitchItem(
    BuildContext context,
    SettingsState settingsState,
  ) {
    final theme = Theme.of(context);
    final isEnabled = settingsState.settings.notifications.taskRemindersEnabled;
    const isWebPlatform = kIsWeb;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isWebPlatform ? Colors.grey : PlantisColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isWebPlatform
                  ? Icons.web
                  : isEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: isWebPlatform ? Colors.grey : PlantisColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificações',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isWebPlatform ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWebPlatform
                      ? 'Não disponível na versão web'
                      : isEnabled
                      ? 'Receba lembretes sobre suas plantas'
                      : 'Notificações desabilitadas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isWebPlatform ? false : isEnabled,
            onChanged: isWebPlatform
                ? null
                : (value) {
                    _handleToggleTaskReminders(context, value);
                  },
            activeThumbColor: PlantisColors.primary,
          ),
        ],
      ),
    );
  }

  /// Handle para toggle de lembretes
  static void _handleToggleTaskReminders(BuildContext context, bool value) {
    // Será chamado do manager quando integrado
  }
}
