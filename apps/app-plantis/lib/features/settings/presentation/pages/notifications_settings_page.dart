import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/settings_notifier.dart';

class NotificationsSettingsPage extends ConsumerWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Notificações'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ResponsiveLayout(
        child: settingsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erro: $error')),
          data: (settings) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationStatusCard(context, ref, settings),

                const SizedBox(height: 24),
                _buildGeneralSettings(context, ref, settings),

                const SizedBox(height: 24),
                _buildTimeSettings(context, ref, settings),

                const SizedBox(height: 24),
                _buildTaskTypeSettings(context, ref, settings),

                const SizedBox(height: 32),
                _buildActions(context, ref, settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationStatusCard(BuildContext context, WidgetRef ref, SettingsState settingsData) {
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

            if (!settingsData.hasPermissionsGranted && !settingsData.isWebPlatform)
              Column(
                children: [
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(settingsNotifierProvider.notifier).openNotificationSettings();
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

            if (settingsData.isWebPlatform)
              Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use o aplicativo móvel para receber notificações',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(BuildContext context, WidgetRef ref, SettingsState settingsData) {
    final theme = Theme.of(context);
    final hasPermissions = settingsData.hasPermissionsGranted && !settingsData.isWebPlatform;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações Gerais',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Lembretes de Tarefas'),
              subtitle: const Text(
                'Receber notificações antes das tarefas vencerem',
              ),
              value: settingsData.notificationSettings.taskRemindersEnabled,
              onChanged: hasPermissions
                  ? (value) {
                      ref.read(settingsNotifierProvider.notifier).toggleTaskReminders(value);
                    }
                  : null,
              secondary: const Icon(Icons.task_alt),
            ),

            SwitchListTile(
              title: const Text('Tarefas em Atraso'),
              subtitle: const Text(
                'Notificações para tarefas que passaram do prazo',
              ),
              value: settingsData.notificationSettings.overdueNotificationsEnabled,
              onChanged: hasPermissions
                  ? (value) {
                      ref.read(settingsNotifierProvider.notifier).toggleOverdueNotifications(value);
                    }
                  : null,
              secondary: const Icon(Icons.warning),
            ),

            SwitchListTile(
              title: const Text('Resumo Diário'),
              subtitle: const Text('Resumo matinal das tarefas do dia'),
              value: settingsData.notificationSettings.dailySummaryEnabled,
              onChanged: hasPermissions
                  ? (value) {
                      ref.read(settingsNotifierProvider.notifier).toggleDailySummary(value);
                    }
                  : null,
              secondary: const Icon(Icons.today),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettings(BuildContext context, WidgetRef ref, SettingsState settingsData) {
    final theme = Theme.of(context);
    final hasPermissions = settingsData.hasPermissionsGranted && !settingsData.isWebPlatform;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horários',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Antecedência dos Lembretes'),
              subtitle: Text(
                '${settingsData.notificationSettings.reminderMinutesBefore} minutos antes',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: hasPermissions
                  ? () {
                      _showReminderTimeDialog(context, ref);
                    }
                  : null,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horário do Resumo Diário'),
              subtitle: Text(settingsData.notificationSettings.dailySummaryTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: hasPermissions && settingsData.notificationSettings.dailySummaryEnabled
                  ? () {
                      _showDailySummaryTimeDialog(context, ref);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTypeSettings(BuildContext context, WidgetRef ref, SettingsState settingsData) {
    final theme = Theme.of(context);
    final hasPermissions = settingsData.hasPermissionsGranted && !settingsData.isWebPlatform;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações por Tipo de Tarefa',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...settingsData.notificationSettings.taskTypeSettings.entries.map((entry) {
              return SwitchListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: hasPermissions
                    ? (value) {
                        ref.read(settingsNotifierProvider.notifier).toggleTaskType(entry.key, value);
                      }
                    : null,
                secondary: _getTaskTypeIcon(entry.key),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, SettingsState settingsData) {
    final theme = Theme.of(context);
    final hasPermissions = settingsData.hasPermissionsGranted && !settingsData.isWebPlatform;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: hasPermissions
                ? () {
                    _showTestNotification(context, ref);
                  }
                : null,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Testar Notificação'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showClearNotificationsDialog(context, ref);
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpar Todas as Notificações'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Icon _getTaskTypeIcon(String taskType) {
    switch (taskType) {
      case 'Regar':
        return const Icon(Icons.water_drop);
      case 'Adubar':
        return const Icon(Icons.eco);
      case 'Podar':
        return const Icon(Icons.content_cut);
      case 'Replantar':
        return const Icon(Icons.change_circle);
      case 'Limpar':
        return const Icon(Icons.cleaning_services);
      case 'Pulverizar':
        return const Icon(Icons.water);
      case 'Sol':
        return const Icon(Icons.wb_sunny);
      case 'Sombra':
        return const Icon(Icons.cloud);
      default:
        return const Icon(Icons.task_alt);
    }
  }

  void _showReminderTimeDialog(
    BuildContext context,
    Ref ref,
  ) {
    final currentValue = ref.read(settingsNotifierProvider).maybeWhen(
          data: (state) => state.notificationSettings.reminderMinutesBefore,
          orElse: () => 30);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Antecedência dos Lembretes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 30, 60, 120, 180].map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes minutos'),
              value: minutes,
              // ignore: deprecated_member_use
              groupValue: currentValue,
              // ignore: deprecated_member_use
              onChanged: (int? value) {
                if (value != null) {
                  ref.read(settingsNotifierProvider.notifier).setReminderMinutesBefore(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDailySummaryTimeDialog(
    BuildContext context,
    Ref ref,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: ref.read(settingsNotifierProvider).maybeWhen(
          data: (state) => state.notificationSettings.dailySummaryTime,
          orElse: () => const TimeOfDay(hour: 8, minute: 0)),
    );

    if (time != null) {
      await ref.read(settingsNotifierProvider.notifier).setDailySummaryTime(time);
    }
  }

  Future<void> _showTestNotification(
    BuildContext context,
    Ref ref,
  ) async {
    await ref.read(settingsNotifierProvider.notifier).sendTestNotification();
  }

  void _showClearNotificationsDialog(
    BuildContext context,
    Ref ref,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Notificações'),
        content: const Text(
          'Isso cancelará todas as notificações agendadas. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).clearAllNotifications();
              Navigator.of(context).pop();
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
