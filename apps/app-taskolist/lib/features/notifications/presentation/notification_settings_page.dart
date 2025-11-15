import 'package:core/core.dart' as core;
import 'package:core/core.dart' hide NotificationSettings, Column;
import 'package:flutter/material.dart';

import '../../../shared/providers/notification_providers.dart';
import 'notification_stats.dart' as local;

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(notificationPermissionProvider);
    final settings = ref.watch(notificationSettingsProvider);
    final statsAsync = ref.watch(notificationStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Notificação'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: permissionAsync.when(
        data: (permission) =>
            _buildContent(context, permission, settings, statsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar permissões: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    core.NotificationPermissionEntity permission,
    NotificationSettings settings,
    AsyncValue<local.NotificationStats> statsAsync,
  ) {
    if (!permission.isGranted) {
      return _buildPermissionRequiredView(context, permission);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(permission, statsAsync),
          const SizedBox(height: 24),
          _buildTaskNotificationsSection(settings),
          const SizedBox(height: 24),
          _buildProductivitySection(settings),
          const SizedBox(height: 24),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildPermissionRequiredView(
    BuildContext context,
    core.NotificationPermissionEntity permission,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Permissão necessária',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Para receber lembretes de tarefas e alertas de prazos, é necessário permitir notificações.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          if (permission.isPermanentlyDenied) ...[
            const Text(
              'As notificações foram permanentemente negadas. Você pode habilitá-las nas configurações do sistema.',
              style: TextStyle(fontSize: 14, color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notificationActionsProvider)
                    .openNotificationSettings();
              },
              child: const Text('Abrir Configurações'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(notificationActionsProvider)
                    .requestPermissions();
                ref.invalidate(notificationPermissionProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Permitir Notificações'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    core.NotificationPermissionEntity permission,
    AsyncValue<local.NotificationStats> statsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  permission.isGranted ? Icons.check_circle : Icons.error,
                  color: permission.isGranted ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  permission.isGranted
                      ? 'Notificações Ativadas'
                      : 'Notificações Desativadas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            statsAsync.when(
              data: (stats) => Column(
                children: [
                  _buildStatRow(
                    'Notificações pendentes',
                    stats.totalPending.toString(),
                  ),
                  _buildStatRow(
                    'Lembretes de tarefas',
                    stats.taskReminders.toString(),
                  ),
                  _buildStatRow(
                    'Alertas de prazo',
                    stats.taskDeadlines.toString(),
                  ),
                ],
              ),
              loading: () => const Text('Carregando estatísticas...'),
              error: (error, stack) =>
                  const Text('Erro ao carregar estatísticas'),
            ),

            if (!permission.canScheduleExactAlarms) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Agendamento exato não permitido. Alguns lembretes podem não funcionar corretamente.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTaskNotificationsSection(NotificationSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notificações de Tarefas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Lembretes de Tarefas'),
                subtitle: const Text(
                  'Receber notificações para tarefas agendadas',
                ),
                value: settings.taskRemindersEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .updateTaskReminders(value);
                },
              ),

              SwitchListTile(
                title: const Text('Alertas de Prazo'),
                subtitle: const Text(
                  'Ser notificado quando prazos estão vencendo',
                ),
                value: settings.deadlineAlertsEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .updateDeadlineAlerts(value);
                },
              ),

              if (settings.deadlineAlertsEnabled) ...[
                ListTile(
                  title: const Text('Avisar com antecedência'),
                  subtitle: Text(_formatDuration(settings.deadlineAlertBefore)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () =>
                      _showDeadlineAlertDialog(settings.deadlineAlertBefore),
                ),
              ],

              SwitchListTile(
                title: const Text('Confirmações de Conclusão'),
                subtitle: const Text(
                  'Mostrar notificação quando tarefas são completadas',
                ),
                value: settings.completionNotificationsEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .updateCompletionNotifications(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductivitySection(NotificationSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produtividade',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Revisão Semanal'),
                subtitle: const Text('Lembrete semanal para revisar progresso'),
                value: settings.weeklyReviewEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .updateWeeklyReview(value);
                  ref.read(notificationActionsProvider).updateWeeklyReview();
                },
              ),

              if (settings.weeklyReviewEnabled) ...[
                ListTile(
                  title: const Text('Horário da Revisão'),
                  subtitle: Text(
                    '${_getDayName(settings.weeklyReviewDayOfWeek)} às ${settings.weeklyReviewHour.toString().padLeft(2, '0')}:${settings.weeklyReviewMinute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showWeeklyReviewTimeDialog(settings),
                ),
              ],

              SwitchListTile(
                title: const Text('Lembrete de Produtividade'),
                subtitle: const Text('Lembrete diário para manter o foco'),
                value: settings.dailyProductivityEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .updateDailyProductivity(value);
                  ref
                      .read(notificationActionsProvider)
                      .updateDailyProductivityReminder();
                },
              ),

              if (settings.dailyProductivityEnabled) ...[
                ListTile(
                  title: const Text('Horário do Lembrete'),
                  subtitle: Text(
                    '${settings.dailyProductivityHour.toString().padLeft(2, '0')}:${settings.dailyProductivityMinute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showDailyProductivityTimeDialog(settings),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Ver Notificações Pendentes'),
            subtitle: const Text('Visualizar todas as notificações agendadas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showPendingNotificationsDialog(),
          ),

          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Cancelar Todas'),
            subtitle: const Text('Remover todas as notificações pendentes'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showCancelAllDialog(),
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações do Sistema'),
            subtitle: const Text(
              'Abrir configurações de notificação do sistema',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => ref
                .read(notificationActionsProvider)
                .openNotificationSettings(),
          ),
        ],
      ),
    );
  }

  void _showDeadlineAlertDialog(Duration currentDuration) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aviso de Prazo'),
        content: RadioGroup<Duration>(
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .updateDeadlineAlertTime(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Avisar com quantas horas de antecedência?'),
              const SizedBox(height: 16),
              ...DurationValues.values.map(
                (duration) => ListTile(
                  title: Text(_formatDuration(duration)),
                  leading: Radio<Duration>(value: duration),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeeklyReviewTimeDialog(NotificationSettings settings) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Horário da Revisão Semanal'),
        content: const Text('Dialog para escolher dia da semana e horário'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDailyProductivityTimeDialog(NotificationSettings settings) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Horário do Lembrete'),
        content: const Text('Dialog para escolher horário'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showPendingNotificationsDialog() {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificações Pendentes'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Consumer(
            builder: (context, WidgetRef ref, child) {
              final pendingAsync = ref.watch(pendingNotificationsProvider);

              return pendingAsync.when(
                data: (List<core.PendingNotificationEntity> notifications) {
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma notificação pendente'),
                    );
                  }

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return ListTile(
                        title: Text(notification.title),
                        subtitle: Text(notification.body),
                        trailing: Text('ID: ${notification.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Erro: $error')),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showCancelAllDialog() {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Todas'),
        content: const Text(
          'Tem certeza que deseja cancelar todas as notificações pendentes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              final bool success = await ref
                  .read(notificationActionsProvider)
                  .cancelAllNotifications();
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Todas as notificações foram canceladas'
                          : 'Erro ao cancelar notificações',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} dia${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  String _getDayName(int dayOfWeek) {
    const days = [
      '',
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return days[dayOfWeek];
  }
}

class DurationValues {
  static const values = [
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 6),
    Duration(hours: 12),
    Duration(hours: 24),
    Duration(days: 2),
    Duration(days: 7),
  ];
}
