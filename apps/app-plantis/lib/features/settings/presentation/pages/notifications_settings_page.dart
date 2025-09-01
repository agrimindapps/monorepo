import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../providers/settings_provider.dart';

// Data classes for granular Selector optimization
class NotificationStatusData {
  final IconData icon;
  final Color color;
  final String text;
  final bool hasPermissions;

  const NotificationStatusData({
    required this.icon,
    required this.color,
    required this.text,
    required this.hasPermissions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationStatusData &&
          icon == other.icon &&
          color == other.color &&
          text == other.text &&
          hasPermissions == other.hasPermissions;

  @override
  int get hashCode => Object.hash(icon, color, text, hasPermissions);
}

class GeneralSettingsData {
  final bool taskRemindersEnabled;
  final bool overdueNotificationsEnabled;
  final bool dailySummaryEnabled;
  final bool hasPermissions;

  const GeneralSettingsData({
    required this.taskRemindersEnabled,
    required this.overdueNotificationsEnabled,
    required this.dailySummaryEnabled,
    required this.hasPermissions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralSettingsData &&
          taskRemindersEnabled == other.taskRemindersEnabled &&
          overdueNotificationsEnabled == other.overdueNotificationsEnabled &&
          dailySummaryEnabled == other.dailySummaryEnabled &&
          hasPermissions == other.hasPermissions;

  @override
  int get hashCode => Object.hash(
      taskRemindersEnabled, overdueNotificationsEnabled, dailySummaryEnabled, hasPermissions);
}

class TimeSettingsData {
  final int reminderMinutesBefore;
  final TimeOfDay dailySummaryTime;
  final bool dailySummaryEnabled;
  final bool hasPermissions;

  const TimeSettingsData({
    required this.reminderMinutesBefore,
    required this.dailySummaryTime,
    required this.dailySummaryEnabled,
    required this.hasPermissions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSettingsData &&
          reminderMinutesBefore == other.reminderMinutesBefore &&
          dailySummaryTime == other.dailySummaryTime &&
          dailySummaryEnabled == other.dailySummaryEnabled &&
          hasPermissions == other.hasPermissions;

  @override
  int get hashCode => Object.hash(
      reminderMinutesBefore, dailySummaryTime, dailySummaryEnabled, hasPermissions);
}

class TaskTypeSettingsData {
  final Map<String, bool> taskTypeSettings;
  final bool hasPermissions;

  const TaskTypeSettingsData({
    required this.taskTypeSettings,
    required this.hasPermissions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeSettingsData &&
          _mapEquals(taskTypeSettings, other.taskTypeSettings) &&
          hasPermissions == other.hasPermissions;

  @override
  int get hashCode => Object.hash(_mapHashCode(taskTypeSettings), hasPermissions);

  bool _mapEquals(Map<String, bool> map1, Map<String, bool> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  int _mapHashCode(Map<String, bool> map) {
    return Object.hashAll(map.entries.map((e) => Object.hash(e.key, e.value)));
  }
}

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
        body: Selector<SettingsProvider, bool>(
          selector: (context, provider) => provider.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status das notificações
                  _buildNotificationStatusCard(context),

                  const SizedBox(height: 24),

                  // Configurações gerais
                  _buildGeneralSettings(context),

                  const SizedBox(height: 24),

                  // Configurações de horários
                  _buildTimeSettings(context),

                  const SizedBox(height: 24),

                  // Configurações por tipo de tarefa
                  _buildTaskTypeSettings(context),

                  const SizedBox(height: 32),

                  // Ações
                  _buildActions(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationStatusCard(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<SettingsProvider, NotificationStatusData>(
      selector: (context, provider) => NotificationStatusData(
        icon: provider.notificationStatusIcon,
        color: provider.notificationStatusColor,
        text: provider.notificationStatusText,
        hasPermissions: provider.hasPermissionsGranted,
      ),
      builder: (context, statusData, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      statusData.icon,
                      color: statusData.color,
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
                  statusData.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusData.color,
                  ),
                ),

                if (!statusData.hasPermissions) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final provider = context.read<SettingsProvider>();
                      provider.openNotificationSettings();
                    },
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
      },
    );
  }

  Widget _buildGeneralSettings(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<SettingsProvider, GeneralSettingsData>(
      selector: (context, provider) => GeneralSettingsData(
        taskRemindersEnabled: provider.notificationSettings.taskRemindersEnabled,
        overdueNotificationsEnabled: provider.notificationSettings.overdueNotificationsEnabled,
        dailySummaryEnabled: provider.notificationSettings.dailySummaryEnabled,
        hasPermissions: provider.hasPermissionsGranted,
      ),
      builder: (context, settingsData, child) {
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
                  value: settingsData.taskRemindersEnabled,
                  onChanged:
                      settingsData.hasPermissions
                          ? (value) {
                              final provider = context.read<SettingsProvider>();
                              provider.toggleTaskReminders(value);
                            }
                          : null,
                  secondary: const Icon(Icons.task_alt),
                ),

                SwitchListTile(
                  title: const Text('Tarefas em Atraso'),
                  subtitle: const Text(
                    'Notificações para tarefas que passaram do prazo',
                  ),
                  value: settingsData.overdueNotificationsEnabled,
                  onChanged:
                      settingsData.hasPermissions
                          ? (value) {
                              final provider = context.read<SettingsProvider>();
                              provider.toggleOverdueNotifications(value);
                            }
                          : null,
                  secondary: const Icon(Icons.warning),
                ),

                SwitchListTile(
                  title: const Text('Resumo Diário'),
                  subtitle: const Text('Resumo matinal das tarefas do dia'),
                  value: settingsData.dailySummaryEnabled,
                  onChanged:
                      settingsData.hasPermissions
                          ? (value) {
                              final provider = context.read<SettingsProvider>();
                              provider.toggleDailySummary(value);
                            }
                          : null,
                  secondary: const Icon(Icons.today),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSettings(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<SettingsProvider, TimeSettingsData>(
      selector: (context, provider) => TimeSettingsData(
        reminderMinutesBefore: provider.notificationSettings.reminderMinutesBefore,
        dailySummaryTime: provider.notificationSettings.dailySummaryTime,
        dailySummaryEnabled: provider.notificationSettings.dailySummaryEnabled,
        hasPermissions: provider.hasPermissionsGranted,
      ),
      builder: (context, timeData, child) {
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
                  subtitle: Text('${timeData.reminderMinutesBefore} minutos antes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:
                      timeData.hasPermissions
                          ? () {
                              final provider = context.read<SettingsProvider>();
                              _showReminderTimeDialog(context, provider);
                            }
                          : null,
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Horário do Resumo Diário'),
                  subtitle: Text(timeData.dailySummaryTime.format(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:
                      timeData.hasPermissions && timeData.dailySummaryEnabled
                          ? () {
                              final provider = context.read<SettingsProvider>();
                              _showDailySummaryTimeDialog(context, provider);
                            }
                          : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskTypeSettings(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<SettingsProvider, TaskTypeSettingsData>(
      selector: (context, provider) => TaskTypeSettingsData(
        taskTypeSettings: provider.notificationSettings.taskTypeSettings,
        hasPermissions: provider.hasPermissionsGranted,
      ),
      builder: (context, taskTypeData, child) {
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

                ...taskTypeData.taskTypeSettings.entries.map((entry) {
                  return SwitchListTile(
                    title: Text(entry.key),
                    value: entry.value,
                    onChanged:
                        taskTypeData.hasPermissions
                            ? (value) {
                                final provider = context.read<SettingsProvider>();
                                provider.toggleTaskType(entry.key, value);
                              }
                            : null,
                    secondary: _getTaskTypeIcon(entry.key),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<SettingsProvider, bool>(
      selector: (context, provider) => provider.hasPermissionsGranted,
      builder: (context, hasPermissions, child) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    hasPermissions
                        ? () {
                            final provider = context.read<SettingsProvider>();
                            _showTestNotification(context, provider);
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
                  final provider = context.read<SettingsProvider>();
                  _showClearNotificationsDialog(context, provider);
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
      },
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
