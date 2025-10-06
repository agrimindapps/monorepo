import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/settings_notifier.dart';
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
    taskRemindersEnabled,
    overdueNotificationsEnabled,
    dailySummaryEnabled,
    hasPermissions,
  );
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
    reminderMinutesBefore,
    dailySummaryTime,
    dailySummaryEnabled,
    hasPermissions,
  );
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
  int get hashCode =>
      Object.hash(_mapHashCode(taskTypeSettings), hasPermissions);

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

    final statusData = NotificationStatusData(
      icon: settingsData.notificationStatusIcon,
      color: settingsData.notificationStatusColor,
      text: settingsData.notificationStatusText,
      hasPermissions: settingsData.hasPermissionsGranted,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusData.icon, color: statusData.color),
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

            if (!statusData.hasPermissions && !settingsData.isWebPlatform)
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
    WidgetRef ref,
  ) {
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
              groupValue: ref.read(settingsNotifierProvider).maybeWhen(
                  data: (state) => state.notificationSettings.reminderMinutesBefore,
                  orElse: () => 30),
              onChanged: (value) {
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
    WidgetRef ref,
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
    WidgetRef ref,
  ) async {
    await ref.read(settingsNotifierProvider.notifier).sendTestNotification();
  }

  void _showClearNotificationsDialog(
    BuildContext context,
    WidgetRef ref,
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
