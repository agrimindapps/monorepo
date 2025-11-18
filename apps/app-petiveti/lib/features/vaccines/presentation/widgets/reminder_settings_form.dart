import 'package:flutter/material.dart';

import '../../../reminders/domain/constants/reminder_constants.dart';
import '../../domain/entities/reminder_config.dart';

/// Settings section for reminder configuration
///
/// **SRP**: Única responsabilidade de configurar preferências de lembretes
class ReminderSettingsForm extends StatefulWidget {
  final ReminderConfig config;
  final void Function(ReminderConfig) onConfigChanged;

  const ReminderSettingsForm({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<ReminderSettingsForm> createState() => _ReminderSettingsFormState();
}

class _ReminderSettingsFormState extends State<ReminderSettingsForm> {
  late ReminderConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações de Notificações',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Smart reminders
            SwitchListTile(
              title: const Text('Lembretes Inteligentes'),
              subtitle: const Text(
                'Sistema adapta automaticamente os horários',
              ),
              value: _config.enableSmartReminders,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(enableSmartReminders: value);
                });
                widget.onConfigChanged(_config);
              },
            ),
            const Divider(),

            // Notification channels
            Text('Canais de Notificação', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),

            CheckboxListTile(
              title: const Text('Notificações Push'),
              value: _config.enablePushNotifications,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(enablePushNotifications: value);
                });
                widget.onConfigChanged(_config);
              },
            ),

            CheckboxListTile(
              title: const Text('Email'),
              value: _config.enableEmailReminders,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(enableEmailReminders: value);
                });
                widget.onConfigChanged(_config);
              },
            ),

            CheckboxListTile(
              title: const Text('SMS'),
              value: _config.enableSmsReminders,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(enableSmsReminders: value);
                });
                widget.onConfigChanged(_config);
              },
            ),
            const Divider(),

            // Timing settings
            ListTile(
              title: const Text('Antecedência do Lembrete'),
              subtitle: Text('${_config.daysBeforeReminder} dias antes'),
              trailing: SizedBox(
                width: 100,
                child: DropdownButton<int>(
                  value: _config.daysBeforeReminder,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 dia')),
                    DropdownMenuItem(value: 3, child: Text('3 dias')),
                    DropdownMenuItem(value: 7, child: Text('7 dias')),
                    DropdownMenuItem(value: 14, child: Text('14 dias')),
                    DropdownMenuItem(value: 30, child: Text('30 dias')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _config = _config.copyWith(daysBeforeReminder: value);
                      });
                      widget.onConfigChanged(_config);
                    }
                  },
                ),
              ),
            ),

            ListTile(
              title: const Text('Frequência de Lembretes'),
              subtitle: Text(
                ReminderConstants.getFrequencyDisplayName(
                  _config.reminderFrequency,
                ),
              ),
              trailing: SizedBox(
                width: 120,
                child: DropdownButton<String>(
                  value: _config.reminderFrequency,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Diário')),
                    DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                    DropdownMenuItem(value: 'monthly', child: Text('Mensal')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _config = _config.copyWith(reminderFrequency: value);
                      });
                      widget.onConfigChanged(_config);
                    }
                  },
                ),
              ),
            ),

            // Preferred time
            ListTile(
              title: const Text('Horário Preferido'),
              subtitle: Text(_formatTime(_config.preferredTime)),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _selectTime(context),
              ),
            ),

            SwitchListTile(
              title: const Text('Lembretes aos Finais de Semana'),
              value: _config.weekendReminders,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(weekendReminders: value);
                });
                widget.onConfigChanged(_config);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _config.preferredTime,
    );

    if (picked != null) {
      setState(() {
        _config = _config.copyWith(preferredTime: picked);
      });
      widget.onConfigChanged(_config);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
