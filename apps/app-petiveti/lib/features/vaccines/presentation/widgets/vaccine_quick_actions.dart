import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

/// Quick action buttons for common vaccine operations
class VaccineQuickActions extends ConsumerWidget {
  final Vaccine vaccine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;

  const VaccineQuickActions({
    super.key,
    required this.vaccine,
    this.onEdit,
    this.onDelete,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (!vaccine.isCompleted && vaccine.canBeMarkedAsCompleted())
          _buildQuickActionChip(
            context,
            theme,
            label: 'Marcar como Aplicada',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () => _markAsCompleted(context, ref),
          ),
        if (vaccine.nextDueDate != null && !vaccine.isCompleted)
          _buildQuickActionChip(
            context,
            theme,
            label: 'Definir Lembrete',
            icon: Icons.alarm_add,
            color: Colors.blue,
            onTap: () => _scheduleReminder(context, ref),
          ),
        if (vaccine.isOverdue)
          _buildQuickActionChip(
            context,
            theme,
            label: 'Reagendar',
            icon: Icons.event_repeat,
            color: Colors.orange,
            onTap: () => _rescheduleVaccine(context, ref),
          ),
        _buildQuickActionChip(
          context,
          theme,
          label: 'Ver Detalhes',
          icon: Icons.info_outline,
          color: theme.colorScheme.primary,
          onTap: onViewDetails,
        ),
        _buildQuickActionChip(
          context,
          theme,
          label: 'Editar',
          icon: Icons.edit,
          color: Colors.grey[600]!,
          onTap: onEdit,
        ),
        _buildQuickActionChip(
          context,
          theme,
          label: 'Excluir',
          icon: Icons.delete_outline,
          color: Colors.red,
          onTap: onDelete,
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context,
    ThemeData theme, {
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      onPressed: onTap,
    );
  }

  void _markAsCompleted(BuildContext context, WidgetRef ref) {
    if (!vaccine.canBeMarkedAsCompleted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta vacina não pode ser marcada como aplicada'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como Aplicada'),
        content: Text('Confirmar que a vacina "${vaccine.name}" foi aplicada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(vaccinesProvider.notifier).markAsCompleted(vaccine.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Vacina "${vaccine.name}" marcada como aplicada',
                  ),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(label: 'Desfazer', onPressed: () {}),
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _scheduleReminder(BuildContext context, WidgetRef ref) {
    if (vaccine.nextDueDate == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => _ReminderDatePicker(
        vaccine: vaccine,
        onReminderSet: (reminderDate) {
          ref
              .read(vaccinesProvider.notifier)
              .scheduleReminder(vaccine.id, reminderDate);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lembrete definido para ${_formatDate(reminderDate)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _rescheduleVaccine(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => _RescheduleDatePicker(
        vaccine: vaccine,
        onRescheduled: (newDate) {
          final updatedVaccine = vaccine.copyWith(nextDueDate: newDate);
          ref.read(vaccinesProvider.notifier).updateVaccine(updatedVaccine);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vacina reagendada para ${_formatDate(newDate)}'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Reminder date picker dialog
class _ReminderDatePicker extends StatefulWidget {
  final Vaccine vaccine;
  final void Function(DateTime) onReminderSet;

  const _ReminderDatePicker({
    required this.vaccine,
    required this.onReminderSet,
  });

  @override
  State<_ReminderDatePicker> createState() => _ReminderDatePickerState();
}

class _ReminderDatePickerState extends State<_ReminderDatePicker> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    final defaultReminderDate = widget.vaccine.nextDueDate!.subtract(
      const Duration(days: 1),
    );
    selectedDate = DateTime(
      defaultReminderDate.year,
      defaultReminderDate.month,
      defaultReminderDate.day,
    );
    selectedTime = const TimeOfDay(hour: 9, minute: 0); // 9 AM default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Definir Lembrete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vacina: ${widget.vaccine.name}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          Text('Lembrar em:', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_formatDate(selectedDate)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(selectedTime.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('1 dia antes'),
                selected: _isSelectedPreset(1),
                onSelected: (_) => _setPresetDays(1),
              ),
              FilterChip(
                label: const Text('3 dias antes'),
                selected: _isSelectedPreset(3),
                onSelected: (_) => _setPresetDays(3),
              ),
              FilterChip(
                label: const Text('1 semana antes'),
                selected: _isSelectedPreset(7),
                onSelected: (_) => _setPresetDays(7),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final reminderDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            Navigator.pop(context);
            widget.onReminderSet(reminderDateTime);
          },
          child: const Text('Definir'),
        ),
      ],
    );
  }

  bool _isSelectedPreset(int days) {
    final presetDate = widget.vaccine.nextDueDate!.subtract(
      Duration(days: days),
    );
    return selectedDate.year == presetDate.year &&
        selectedDate.month == presetDate.month &&
        selectedDate.day == presetDate.day;
  }

  void _setPresetDays(int days) {
    setState(() {
      selectedDate = widget.vaccine.nextDueDate!.subtract(Duration(days: days));
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate:
          widget.vaccine.nextDueDate ??
          DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Reschedule date picker dialog
class _RescheduleDatePicker extends StatefulWidget {
  final Vaccine vaccine;
  final void Function(DateTime) onRescheduled;

  const _RescheduleDatePicker({
    required this.vaccine,
    required this.onRescheduled,
  });

  @override
  State<_RescheduleDatePicker> createState() => _RescheduleDatePickerState();
}

class _RescheduleDatePickerState extends State<_RescheduleDatePicker> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate =
        widget.vaccine.nextDueDate ??
        DateTime.now().add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Reagendar Vacina'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vacina: ${widget.vaccine.name}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${widget.vaccine.displayStatus}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text('Nova data:', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_formatDate(selectedDate)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Amanhã'),
                selected: _isSelectedPreset(1),
                onSelected: (_) => _setPresetDays(1),
              ),
              FilterChip(
                label: const Text('Em 1 semana'),
                selected: _isSelectedPreset(7),
                onSelected: (_) => _setPresetDays(7),
              ),
              FilterChip(
                label: const Text('Em 1 mês'),
                selected: _isSelectedPreset(30),
                onSelected: (_) => _setPresetDays(30),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onRescheduled(selectedDate);
          },
          child: const Text('Reagendar'),
        ),
      ],
    );
  }

  bool _isSelectedPreset(int days) {
    final presetDate = DateTime.now().add(Duration(days: days));
    return selectedDate.year == presetDate.year &&
        selectedDate.month == presetDate.month &&
        selectedDate.day == presetDate.day;
  }

  void _setPresetDays(int days) {
    setState(() {
      selectedDate = DateTime.now().add(Duration(days: days));
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
