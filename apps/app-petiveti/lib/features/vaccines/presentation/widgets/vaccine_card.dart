import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

class VaccineCard extends ConsumerWidget {
  final Vaccine vaccine;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showAnimalInfo;

  const VaccineCard({
    super.key,
    required this.vaccine,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showAnimalInfo = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(vaccine.status),
          width: vaccine.isOverdue ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vaccine.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: vaccine.isOverdue ? Colors.red[800] : null,
                      ),
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),

              const SizedBox(height: 8),
              if (vaccine.priorityLevel != 'Baixa')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      vaccine.priorityLevel,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPriorityColor(vaccine.priorityLevel),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPriorityIcon(vaccine.priorityLevel),
                        size: 14,
                        color: _getPriorityColor(vaccine.priorityLevel),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Prioridade ${vaccine.priorityLevel}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(vaccine.priorityLevel),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (vaccine.priorityLevel != 'Baixa') const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vaccine.veterinarian,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    vaccine.isCompleted
                        ? Icons.check_circle_outline
                        : Icons.schedule_outlined,
                    size: 16,
                    color: vaccine.isCompleted
                        ? Colors.green
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vaccine.isCompleted
                          ? 'Aplicada em ${_formatDate(vaccine.date)}'
                          : vaccine.nextDoseInfo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: vaccine.isCompleted
                            ? Colors.green[700]
                            : vaccine.isOverdue
                            ? Colors.red[700]
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                        fontWeight: vaccine.isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (vaccine.reminderDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 16,
                      color: vaccine.needsReminder
                          ? Colors.orange[700]
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vaccine.reminderInfo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: vaccine.needsReminder
                              ? Colors.orange[700]
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                          fontWeight: vaccine.needsReminder
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (vaccine.batch != null || vaccine.manufacturer != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                if (vaccine.batch != null)
                  _buildInfoRow(
                    context,
                    Icons.numbers,
                    'Lote: ${vaccine.batch}',
                  ),
                if (vaccine.manufacturer != null)
                  _buildInfoRow(
                    context,
                    Icons.business,
                    'Fabricante: ${vaccine.manufacturer}',
                  ),
              ],
              if (vaccine.notes != null &&
                  vaccine.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vaccine.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!vaccine.isCompleted && vaccine.canBeMarkedAsCompleted())
                    _buildActionChip(
                      context,
                      label: 'Marcar Concluída',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onPressed: () => _markAsCompleted(context, ref),
                    ),

                  if (vaccine.isCompleted)
                    _buildActionChip(
                      context,
                      label: 'Concluída',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onPressed: null, // Disabled
                    ),

                  const SizedBox(width: 8),
                  if (!vaccine.isCompleted && vaccine.nextDueDate != null)
                    _buildActionChip(
                      context,
                      label: vaccine.reminderDate != null
                          ? 'Lembrete Ativo'
                          : 'Lembrete',
                      icon: vaccine.reminderDate != null
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: vaccine.reminderDate != null
                          ? Colors.orange
                          : theme.colorScheme.primary,
                      onPressed: () => _showReminderDialog(context, ref),
                    ),

                  const Spacer(),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(vaccine.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        vaccine.displayStatus,
        style: theme.textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;

    return ActionChip(
      onPressed: onPressed,
      avatar: Icon(
        icon,
        size: 16,
        color: isEnabled ? color : theme.disabledColor,
      ),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isEnabled ? color : theme.disabledColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isEnabled
          ? color.withValues(alpha: 0.1)
          : theme.disabledColor.withValues(alpha: 0.1),
      side: BorderSide(
        color: isEnabled ? color : theme.disabledColor,
        width: 1,
      ),
    );
  }

  Color _getStatusColor(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.scheduled:
        return Colors.blue;
      case VaccineStatus.applied:
        return Colors.green;
      case VaccineStatus.overdue:
        return Colors.red;
      case VaccineStatus.completed:
        return Colors.green;
      case VaccineStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'média':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Icons.priority_high;
      case 'média':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _markAsCompleted(BuildContext context, WidgetRef ref) {
    ref.read(vaccinesProvider.notifier).markAsCompleted(vaccine.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vacina ${vaccine.name} marcada como concluída'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showReminderDialog(BuildContext context, WidgetRef ref) {
    DateTime selectedDate =
        vaccine.reminderDate ??
        (vaccine.nextDueDate?.subtract(const Duration(days: 3)) ??
            DateTime.now().add(const Duration(days: 1)));

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lembrete da Vacina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quando você quer ser lembrado sobre a vacina ${vaccine.name}?',
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Data: ${_formatDate(selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate:
                      vaccine.nextDueDate ??
                      DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
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
              ref
                  .read(vaccinesProvider.notifier)
                  .scheduleReminder(vaccine.id, selectedDate);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Lembrete agendado para ${_formatDate(selectedDate)}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Agendar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vacina'),
        content: Text(
          'Tem certeza que deseja excluir a vacina ${vaccine.name}? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
