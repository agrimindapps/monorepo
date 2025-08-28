import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../providers/settings_provider.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<SettingsProvider>.value(
      value: di.sl<SettingsProvider>(), // Using pre-initialized singleton
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurações de Notificações'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status das notificações
                  _buildNotificationStatusCard(context, provider),

                  const SizedBox(height: 24),

                  // Configurações gerais
                  _buildGeneralSettings(context, provider),

                  const SizedBox(height: 24),

                  // Configurações de horários
                  _buildTimeSettings(context, provider),

                  const SizedBox(height: 24),

                  // Configurações por tipo de tarefa
                  _buildTaskTypeSettings(context, provider),

                  const SizedBox(height: 32),

                  // Ações
                  _buildActions(context, provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationStatusCard(
    BuildContext context,
    SettingsProvider provider,
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
                  provider.notificationStatusIcon,
                  color: provider.notificationStatusColor,
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
              provider.notificationStatusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: provider.notificationStatusColor,
              ),
            ),

            if (!provider.hasPermissionsGranted) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => provider.openNotificationSettings(),
                icon: const Icon(Icons.settings),
                label: const Text('Abrir Configurações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(
    BuildContext context,
    SettingsProvider provider,
  ) {
    final theme = Theme.of(context);

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
              value: provider.notificationSettings.taskRemindersEnabled,
              onChanged:
                  provider.hasPermissionsGranted
                      ? provider.toggleTaskReminders
                      : null,
              secondary: const Icon(Icons.task_alt),
            ),

            SwitchListTile(
              title: const Text('Tarefas em Atraso'),
              subtitle: const Text(
                'Notificações para tarefas que passaram do prazo',
              ),
              value: provider.notificationSettings.overdueNotificationsEnabled,
              onChanged:
                  provider.hasPermissionsGranted
                      ? provider.toggleOverdueNotifications
                      : null,
              secondary: const Icon(Icons.warning),
            ),

            SwitchListTile(
              title: const Text('Resumo Diário'),
              subtitle: const Text('Resumo matinal das tarefas do dia'),
              value: provider.notificationSettings.dailySummaryEnabled,
              onChanged:
                  provider.hasPermissionsGranted
                      ? provider.toggleDailySummary
                      : null,
              secondary: const Icon(Icons.today),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettings(
    BuildContext context,
    SettingsProvider provider,
  ) {
    final theme = Theme.of(context);

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
              subtitle: Text('${provider.notificationSettings.reminderMinutesBefore} minutos antes'),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  provider.hasPermissionsGranted
                      ? () => _showReminderTimeDialog(context, provider)
                      : null,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horário do Resumo Diário'),
              subtitle: Text(provider.notificationSettings.dailySummaryTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  provider.hasPermissionsGranted &&
                          provider.notificationSettings.dailySummaryEnabled
                      ? () => _showDailySummaryTimeDialog(context, provider)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTypeSettings(
    BuildContext context,
    SettingsProvider provider,
  ) {
    final theme = Theme.of(context);

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

            ...provider.notificationSettings.taskTypeSettings.entries.map((entry) {
              return SwitchListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged:
                    provider.hasPermissionsGranted
                        ? (value) => provider.toggleTaskType(entry.key, value)
                        : null,
                secondary: _getTaskTypeIcon(entry.key),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    SettingsProvider provider,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                provider.hasPermissionsGranted
                    ? () => _showTestNotification(context, provider)
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
            onPressed: () => _showClearNotificationsDialog(context, provider),
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
    SettingsProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Antecedência dos Lembretes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  [15, 30, 60, 120, 180].map((minutes) {
                    return RadioListTile<int>(
                      title: Text('$minutes minutos'),
                      value: minutes,
                      groupValue: provider.notificationSettings.reminderMinutesBefore,
                      onChanged: (value) {
                        if (value != null) {
                          provider.setReminderMinutesBefore(value);
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
    SettingsProvider provider,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: provider.notificationSettings.dailySummaryTime,
    );

    if (time != null) {
      await provider.setDailySummaryTime(time);
    }
  }

  Future<void> _showTestNotification(
    BuildContext context,
    SettingsProvider provider,
  ) async {
    await provider.sendTestNotification();
  }

  void _showClearNotificationsDialog(
    BuildContext context,
    SettingsProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
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
                  provider.clearAllNotifications();
                  Navigator.of(context).pop();
                },
                child: const Text('Limpar'),
              ),
            ],
          ),
    );
  }
}
