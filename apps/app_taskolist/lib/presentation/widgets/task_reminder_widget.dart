import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/notification_providers.dart';

class TaskReminderWidget extends ConsumerStatefulWidget {
  final TaskEntity task;
  final VoidCallback? onReminderSet;

  const TaskReminderWidget({
    super.key,
    required this.task,
    this.onReminderSet,
  });

  @override
  ConsumerState<TaskReminderWidget> createState() => _TaskReminderWidgetState();
}

class _TaskReminderWidgetState extends ConsumerState<TaskReminderWidget> {
  DateTime? selectedDateTime;
  bool isQuickReminder = false;
  Duration quickReminderDuration = const Duration(minutes: 30);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Lembrete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showReminderInfo(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Toggle entre lembrete rápido e personalizado
            ToggleButtons(
              isSelected: [isQuickReminder, !isQuickReminder],
              onPressed: (index) {
                setState(() {
                  isQuickReminder = index == 0;
                  if (isQuickReminder) {
                    selectedDateTime = null;
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Rápido'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Personalizado'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (isQuickReminder) ...[
              _buildQuickReminderSection(),
            ] else ...[
              _buildCustomReminderSection(),
            ],
            
            const SizedBox(height: 16),
            
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _scheduleDeadlineAlert(),
                    child: const Text('Alerta de Prazo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canScheduleReminder() ? _scheduleReminder : null,
                    child: const Text('Agendar Lembrete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lembrar em:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickReminderChip('15 min', const Duration(minutes: 15)),
            _buildQuickReminderChip('30 min', const Duration(minutes: 30)),
            _buildQuickReminderChip('1 hora', const Duration(hours: 1)),
            _buildQuickReminderChip('2 horas', const Duration(hours: 2)),
            _buildQuickReminderChip('Amanhã 9h', Duration(
              days: 1,
              hours: 9 - DateTime.now().hour,
              minutes: -DateTime.now().minute,
            )),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Lembrete em ${_formatDuration(quickReminderDuration)}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReminderChip(String label, Duration duration) {
    final isSelected = quickReminderDuration == duration;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            quickReminderDuration = duration;
          });
        }
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
    );
  }

  Widget _buildCustomReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data e hora do lembrete:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.event),
            title: Text(
              selectedDateTime != null
                  ? _formatDateTime(selectedDateTime!)
                  : 'Selecionar data e hora',
            ),
            subtitle: selectedDateTime != null
                ? Text(_getRelativeTime(selectedDateTime!))
                : null,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _selectDateTime(),
          ),
        ),
        
        if (selectedDateTime != null && selectedDateTime!.isBefore(DateTime.now())) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Data no passado. Selecione uma data futura.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _canScheduleReminder() {
    if (isQuickReminder) {
      return true;
    } else {
      return selectedDateTime != null && selectedDateTime!.isAfter(DateTime.now());
    }
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    
    // Selecionar data
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (selectedDate == null) return;
    
    // Selecionar hora
    if (!mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDateTime ?? now.add(const Duration(hours: 1)),
      ),
    );
    
    if (selectedTime == null) return;
    
    setState(() {
      selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _scheduleReminder() async {
    try {
      DateTime reminderTime;
      
      if (isQuickReminder) {
        reminderTime = DateTime.now().add(quickReminderDuration);
      } else {
        reminderTime = selectedDateTime!;
      }
      
      final actions = ref.read(notificationActionsProvider);
      final success = await actions.scheduleTaskReminder(
        taskId: widget.task.id,
        taskTitle: widget.task.title,
        reminderTime: reminderTime,
        description: widget.task.description,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lembrete agendado para ${_formatDateTime(reminderTime)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          widget.onReminderSet?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao agendar lembrete'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scheduleDeadlineAlert() async {
    if (widget.task.dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta tarefa não possui prazo definido'),
        ),
      );
      return;
    }
    
    try {
      final actions = ref.read(notificationActionsProvider);
      final success = await actions.scheduleTaskDeadlineAlert(
        taskId: widget.task.id,
        taskTitle: widget.task.title,
        deadline: widget.task.dueDate!,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta de prazo agendado'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao agendar alerta de prazo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReminderInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre os Lembretes'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Lembretes rápidos são baseados no momento atual'),
            SizedBox(height: 8),
            Text('• Lembretes personalizados permitem escolher data e hora específicas'),
            SizedBox(height: 8),
            Text('• Alertas de prazo são enviados 24h antes do vencimento'),
            SizedBox(height: 8),
            Text('• Você pode cancelar lembretes nas configurações de notificação'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      return 'No passado';
    } else if (difference.inMinutes < 60) {
      return 'Em ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Em ${difference.inHours} horas';
    } else {
      return 'Em ${difference.inDays} dias';
    }
  }
}