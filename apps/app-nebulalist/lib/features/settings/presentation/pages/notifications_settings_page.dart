import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Notifications settings page
class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  // TODO: Connect to actual settings provider
  bool _notificationsEnabled = true;
  bool _taskRemindersEnabled = true;
  bool _dailySummaryEnabled = false;
  bool _weeklyReportEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isWeb) ...[
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'As notificações não estão disponíveis na versão web. '
                        'Use o aplicativo móvel para receber lembretes.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Master Toggle
          Card(
            child: SwitchListTile(
              secondary: Icon(
                _notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _notificationsEnabled && !isWeb
                    ? theme.primaryColor
                    : Colors.grey,
              ),
              title: const Text(
                'Ativar Notificações',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isWeb
                    ? 'Não disponível na versão web'
                    : _notificationsEnabled
                    ? 'Receba lembretes sobre suas tarefas'
                    : 'Notificações desativadas',
              ),
              value: isWeb ? false : _notificationsEnabled,
              onChanged:
                  isWeb
                      ? null
                      : (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        _showSnackBar(
                          value
                              ? 'Notificações ativadas'
                              : 'Notificações desativadas',
                        );
                      },
            ),
          ),
          const SizedBox(height: 24),

          // Notification Types Section
          if (!isWeb) ...[
            Text(
              'Tipos de Notificação',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
          ],

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.alarm,
                    color:
                        _notificationsEnabled && _taskRemindersEnabled && !isWeb
                            ? theme.primaryColor
                            : Colors.grey,
                  ),
                  title: const Text('Lembretes de Tarefas'),
                  subtitle: const Text('Notificação quando uma tarefa está próxima'),
                  value:
                      isWeb ? false : _notificationsEnabled && _taskRemindersEnabled,
                  onChanged:
                      isWeb || !_notificationsEnabled
                          ? null
                          : (value) {
                            setState(() {
                              _taskRemindersEnabled = value;
                            });
                            _showSnackBar(
                              value
                                  ? 'Lembretes de tarefas ativados'
                                  : 'Lembretes de tarefas desativados',
                            );
                          },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.today,
                    color:
                        _notificationsEnabled && _dailySummaryEnabled && !isWeb
                            ? theme.primaryColor
                            : Colors.grey,
                  ),
                  title: const Text('Resumo Diário'),
                  subtitle: const Text('Resumo das tarefas do dia (8:00 AM)'),
                  value:
                      isWeb ? false : _notificationsEnabled && _dailySummaryEnabled,
                  onChanged:
                      isWeb || !_notificationsEnabled
                          ? null
                          : (value) {
                            setState(() {
                              _dailySummaryEnabled = value;
                            });
                            _showSnackBar(
                              value
                                  ? 'Resumo diário ativado'
                                  : 'Resumo diário desativado',
                            );
                          },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.calendar_month,
                    color:
                        _notificationsEnabled && _weeklyReportEnabled && !isWeb
                            ? theme.primaryColor
                            : Colors.grey,
                  ),
                  title: const Text('Relatório Semanal'),
                  subtitle: const Text('Resumo semanal (Domingos, 9:00 AM)'),
                  value:
                      isWeb ? false : _notificationsEnabled && _weeklyReportEnabled,
                  onChanged:
                      isWeb || !_notificationsEnabled
                          ? null
                          : (value) {
                            setState(() {
                              _weeklyReportEnabled = value;
                            });
                            _showSnackBar(
                              value
                                  ? 'Relatório semanal ativado'
                                  : 'Relatório semanal desativado',
                            );
                          },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (!isWeb) ...[
            // Additional Info
            Card(
              color: theme.primaryColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dica',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você pode ajustar as configurações de notificação do sistema '
                      'nas configurações do seu dispositivo.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
