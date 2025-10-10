import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

/// Dialog para confirmação de conclusão de tarefa
///
/// Features:
/// - Confirmação visual da tarefa a ser marcada como concluída
/// - Campo opcional para observações
/// - Data ajustável da conclusão (padrão: hoje)
/// - Preview da próxima tarefa (quando aplicável)
/// - Validações de UX (data não pode ser muito no futuro)
class TaskCompletionDialog extends StatefulWidget {
  final Task task;
  final String plantName;
  final DateTime? nextTaskDate;
  final String? nextTaskDescription;
  final VoidCallback? onCancel;
  final void Function(DateTime completionDate, String? notes)? onConfirm;

  const TaskCompletionDialog({
    super.key,
    required this.task,
    required this.plantName,
    this.nextTaskDate,
    this.nextTaskDescription,
    this.onCancel,
    this.onConfirm,
  });

  /// Exibe o dialog e retorna os dados de conclusão ou null se cancelado
  static Future<TaskCompletionResult?> show({
    required BuildContext context,
    required Task task,
    required String plantName,
    DateTime? nextTaskDate,
    String? nextTaskDescription,
  }) async {
    return showDialog<TaskCompletionResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskCompletionDialog(
          task: task,
          plantName: plantName,
          nextTaskDate: nextTaskDate,
          nextTaskDescription: nextTaskDescription,
        );
      },
    );
  }

  @override
  State<TaskCompletionDialog> createState() => _TaskCompletionDialogState();
}

class _TaskCompletionDialogState extends State<TaskCompletionDialog> {
  late DateTime _completionDate;
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _completionDate = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: SizedBox(
          width:
              MediaQuery.of(context).size.width > 400
                  ? 400
                  : MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),

              const SizedBox(height: 24),
              _buildInfoCard(
                theme,
                Icons.calendar_today,
                'Data de vencimento',
                _formatDateDescription(widget.task.dueDate),
                theme.colorScheme.primary,
              ),

              const SizedBox(height: 12),
              _buildInfoCard(
                theme,
                Icons.schedule,
                'Próximo vencimento',
                _getNextDueDescription(),
                Colors.green,
              ),

              const SizedBox(height: 12),
              _buildInfoCard(
                theme,
                Icons.repeat,
                'Intervalo',
                _getIntervalDescription(),
                Colors.orange,
              ),

              const SizedBox(height: 12),
              _buildCompletionSection(theme),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _handleCancel,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outline),
                        ),
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Concluir'),
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

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTaskTypeIcon(),
            size: 24,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                widget.plantName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
    Color iconColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data de conclusão',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectCompletionDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(
                    _formatDate(_completionDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_month,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateDescription(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _getNextDueDescription() {
    final interval = _getTaskInterval();
    final nextDate = _completionDate.add(Duration(days: interval));
    final day = nextDate.day.toString().padLeft(2, '0');
    final month = nextDate.month.toString().padLeft(2, '0');
    final year = nextDate.year.toString();
    return '$day/$month/$year';
  }

  String _getIntervalDescription() {
    final interval = _getTaskInterval();
    if (interval == 1) {
      return '1 dia';
    } else if (interval < 7) {
      return '$interval dias';
    } else if (interval == 7) {
      return '1 semana';
    } else if (interval < 30) {
      final weeks = (interval / 7).round();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else {
      final months = (interval / 30).round();
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    }
  }

  int _getTaskInterval() {
    switch (widget.task.type) {
      case TaskType.watering:
        return 3; // 3 dias
      case TaskType.fertilizing:
        return 30; // 1 mês
      case TaskType.pruning:
        return 60; // 2 meses
      case TaskType.repotting:
        return 365; // 1 ano
      case TaskType.pestInspection:
        return 14; // 2 semanas
      default:
        return 7; // 1 semana
    }
  }

  Future<void> _selectCompletionDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _completionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Data da Conclusão',
      confirmText: 'CONFIRMAR',
      cancelText: 'CANCELAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(surface: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _completionDate = selectedDate;
      });
    }
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.of(context).pop();
  }

  void _handleConfirm() {
    // Validate form if it exists (safe check)
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    final notes = _notesController.text.trim();
    final result = TaskCompletionResult(
      completionDate: _completionDate,
      notes: notes.isEmpty ? null : notes,
    );

    if (widget.onConfirm != null) {
      widget.onConfirm!(_completionDate, notes.isEmpty ? null : notes);
    }

    Navigator.of(context).pop(result);
  }

  IconData _getTaskTypeIcon() {
    switch (widget.task.type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.eco;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.repotting:
        return Icons.change_circle;
      case TaskType.sunlight:
        return Icons.wb_sunny;
      case TaskType.pestInspection:
        return Icons.search;
      default:
        return Icons.task_alt;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hoje';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Resultado da conclusão de uma tarefa
class TaskCompletionResult {
  final DateTime completionDate;
  final String? notes;

  const TaskCompletionResult({required this.completionDate, this.notes});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCompletionResult &&
        other.completionDate == completionDate &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(completionDate, notes);

  @override
  String toString() {
    return 'TaskCompletionResult(completionDate: $completionDate, notes: $notes)';
  }
}
