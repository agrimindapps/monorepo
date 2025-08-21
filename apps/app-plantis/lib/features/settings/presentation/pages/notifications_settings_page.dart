import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_settings_provider.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsSettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Notificações'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Consumer<NotificationsSettingsProvider>(
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
    );
  }

  Widget _buildNotificationStatusCard(
    BuildContext context,
    NotificationsSettingsProvider provider,
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
                  provider.areNotificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color:
                      provider.areNotificationsEnabled
                          ? Colors.green
                          : Colors.red,
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
              provider.areNotificationsEnabled
                  ? 'As notificações estão habilitadas para este aplicativo'
                  : 'As notificações estão desabilitadas. Habilite nas configurações do dispositivo para receber lembretes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    provider.areNotificationsEnabled
                        ? Colors.green.shade700
                        : Colors.red.shade700,
              ),
            ),

            if (!provider.areNotificationsEnabled) ...[
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
    NotificationsSettingsProvider provider,
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
              value: provider.taskRemindersEnabled,
              onChanged:
                  provider.areNotificationsEnabled
                      ? provider.toggleTaskReminders
                      : null,
              secondary: const Icon(Icons.task_alt),
            ),

            SwitchListTile(
              title: const Text('Tarefas em Atraso'),
              subtitle: const Text(
                'Notificações para tarefas que passaram do prazo',
              ),
              value: provider.overdueNotificationsEnabled,
              onChanged:
                  provider.areNotificationsEnabled
                      ? provider.toggleOverdueNotifications
                      : null,
              secondary: const Icon(Icons.warning),
            ),

            SwitchListTile(
              title: const Text('Resumo Diário'),
              subtitle: const Text('Resumo matinal das tarefas do dia'),
              value: provider.dailySummaryEnabled,
              onChanged:
                  provider.areNotificationsEnabled
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
    NotificationsSettingsProvider provider,
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
              subtitle: Text('${provider.reminderMinutesBefore} minutos antes'),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  provider.areNotificationsEnabled
                      ? () => _showReminderTimeDialog(context, provider)
                      : null,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horário do Resumo Diário'),
              subtitle: Text(provider.dailySummaryTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  provider.areNotificationsEnabled &&
                          provider.dailySummaryEnabled
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
    NotificationsSettingsProvider provider,
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

            ...provider.taskTypeSettings.entries.map((entry) {
              return SwitchListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged:
                    provider.areNotificationsEnabled
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
    NotificationsSettingsProvider provider,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                provider.areNotificationsEnabled
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
    NotificationsSettingsProvider provider,
  ) {
    showDialog(
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
                      groupValue: provider.reminderMinutesBefore,
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
    NotificationsSettingsProvider provider,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: provider.dailySummaryTime,
    );

    if (time != null) {
      provider.setDailySummaryTime(time);
    }
  }

  void _showTestNotification(
    BuildContext context,
    NotificationsSettingsProvider provider,
  ) {
    provider.sendTestNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificação de teste enviada!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearNotificationsDialog(
    BuildContext context,
    NotificationsSettingsProvider provider,
  ) {
    showDialog(
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas as notificações foram canceladas'),
                    ),
                  );
                },
                child: const Text('Limpar'),
              ),
            ],
          ),
    );
  }
}
