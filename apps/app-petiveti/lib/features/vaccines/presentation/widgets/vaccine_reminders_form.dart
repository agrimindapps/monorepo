import 'package:flutter/material.dart';

/// Widget responsible for vaccine reminders configuration following SRP
/// 
/// Single responsibility: Handle vaccine reminder settings and notifications
class VaccineRemindersForm extends StatefulWidget {
  final DateTime? reminderDate;
  final bool enableSmartReminders;
  final bool enableSeasonalReminders;
  final String? selectedSeason;
  final ValueChanged<DateTime?> onReminderDateChanged;
  final ValueChanged<bool> onSmartRemindersChanged;
  final ValueChanged<bool> onSeasonalRemindersChanged;
  final ValueChanged<String?> onSeasonChanged;

  const VaccineRemindersForm({
    super.key,
    this.reminderDate,
    required this.enableSmartReminders,
    required this.enableSeasonalReminders,
    this.selectedSeason,
    required this.onReminderDateChanged,
    required this.onSmartRemindersChanged,
    required this.onSeasonalRemindersChanged,
    required this.onSeasonChanged,
  });

  @override
  State<VaccineRemindersForm> createState() => _VaccineRemindersFormState();
}

class _VaccineRemindersFormState extends State<VaccineRemindersForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSmartRemindersSection(theme),
          const SizedBox(height: 16),
          _buildCustomReminderSection(theme),
          const SizedBox(height: 16),
          _buildSeasonalRemindersSection(theme),
        ],
      ),
    );
  }

  Widget _buildSmartRemindersSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema de Lembretes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              title: const Text('Lembretes Inteligentes'),
              subtitle: const Text('Sistema automático baseado no tipo de vacina'),
              value: widget.enableSmartReminders,
              onChanged: widget.onSmartRemindersChanged,
              activeColor: theme.colorScheme.primary,
            ),
            if (widget.enableSmartReminders) ...[
              const SizedBox(height: 16),
              _buildSmartRemindersInfo(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmartRemindersInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Lembretes Automáticos Ativados',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 7 dias antes do vencimento\n• 3 dias antes (lembrete urgente)\n• No dia do vencimento\n• Notificação de atraso',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomReminderSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lembrete Personalizado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectReminderDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notification_add,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lembrete Personalizado',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.reminderDate != null 
                                ? 'Agendado para ${_formatDateTime(widget.reminderDate!)}'
                                : 'Nenhum lembrete personalizado',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.reminderDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => widget.onReminderDateChanged(null),
                child: const Text('Remover Lembrete'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalRemindersSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lembretes Sazonais',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              title: const Text('Ativar Lembretes Sazonais'),
              subtitle: const Text('Para vacinas anuais como antirrábica'),
              value: widget.enableSeasonalReminders,
              onChanged: widget.onSeasonalRemindersChanged,
              activeColor: theme.colorScheme.primary,
            ),
            if (widget.enableSeasonalReminders) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: widget.selectedSeason,
                decoration: InputDecoration(
                  labelText: 'Época Preferencial',
                  prefixIcon: const Icon(Icons.wb_sunny),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'spring', child: Text('Primavera')),
                  DropdownMenuItem(value: 'summer', child: Text('Verão')),
                  DropdownMenuItem(value: 'autumn', child: Text('Outono')),
                  DropdownMenuItem(value: 'winter', child: Text('Inverno')),
                ],
                onChanged: widget.onSeasonChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectReminderDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.reminderDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(widget.reminderDate ?? DateTime.now()),
      );
      
      if (time != null && mounted) {
        final reminderDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        widget.onReminderDateChanged(reminderDateTime);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}