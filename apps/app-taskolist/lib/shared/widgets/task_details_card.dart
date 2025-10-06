import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/tasks/domain/task_entity.dart';

class TaskDetailsCard extends StatefulWidget {
  final TaskEntity task;
  final bool isEditing;
  final TaskStatus selectedStatus;
  final TaskPriority selectedPriority;
  final void Function(TaskStatus)? onStatusChanged;
  final void Function(TaskPriority)? onPriorityChanged;
  final VoidCallback? onDateTap;

  const TaskDetailsCard({
    super.key,
    required this.task,
    required this.isEditing,
    required this.selectedStatus,
    required this.selectedPriority,
    this.onStatusChanged,
    this.onPriorityChanged,
    this.onDateTap,
  });

  @override
  State<TaskDetailsCard> createState() => _TaskDetailsCardState();
}

class _TaskDetailsCardState extends State<TaskDetailsCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalhes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.radio_button_unchecked,
              iconColor: AppColors.getStatusColor(widget.selectedStatus.name),
              label: 'Status',
              value: _getStatusName(widget.selectedStatus),
              isEditing: widget.isEditing,
              onTap: widget.isEditing ? _showStatusSelector : null,
            ),
            
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.flag,
              iconColor: AppColors.getPriorityColor(widget.selectedPriority.name),
              label: 'Prioridade',
              value: _getPriorityName(widget.selectedPriority),
              isEditing: widget.isEditing,
              onTap: widget.isEditing ? _showPrioritySelector : null,
            ),
            
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.calendar_today,
              iconColor: widget.task.dueDate != null && widget.task.isOverdue 
                ? AppColors.error 
                : AppColors.textSecondary,
              label: 'Vencimento',
              value: widget.task.dueDate != null 
                ? _formatDate(widget.task.dueDate!)
                : 'Não definido',
              isEditing: widget.isEditing,
              onTap: widget.isEditing ? widget.onDateTap : null,
            ),
            
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.access_time,
              iconColor: AppColors.textSecondary,
              label: 'Criado em',
              value: _formatDateTime(widget.task.createdAt),
              isEditing: false,
            ),
            if (widget.task.updatedAt != widget.task.createdAt) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.edit,
                iconColor: AppColors.textSecondary,
                label: 'Atualizado em',
                value: _formatDateTime(widget.task.updatedAt),
                isEditing: false,
              ),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.format_list_numbered,
              iconColor: AppColors.textSecondary,
              label: 'Posição',
              value: '#${widget.task.position + 1}',
              isEditing: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isEditing,
    VoidCallback? onTap,
  }) {
    Widget content = Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isEditing && onTap != null)
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
      ],
    );

    if (isEditing && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }

    return content;
  }

  void _showStatusSelector() {
    if (widget.onStatusChanged == null) return;
    
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecionar Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...TaskStatus.values.map((status) => ListTile(
              leading: Icon(
                status == TaskStatus.completed ? Icons.check_circle :
                status == TaskStatus.inProgress ? Icons.access_time :
                Icons.radio_button_unchecked,
                color: AppColors.getStatusColor(status.name),
              ),
              title: Text(_getStatusName(status)),
              onTap: () {
                widget.onStatusChanged!(status);
                Navigator.pop(context);
              },
              selected: status == widget.selectedStatus,
            )),
          ],
        ),
      ),
    );
  }

  void _showPrioritySelector() {
    if (widget.onPriorityChanged == null) return;
    
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecionar Prioridade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...TaskPriority.values.map((priority) => ListTile(
              leading: Icon(
                Icons.flag,
                color: AppColors.getPriorityColor(priority.name),
              ),
              title: Text(_getPriorityName(priority)),
              onTap: () {
                widget.onPriorityChanged!(priority);
                Navigator.pop(context);
              },
              selected: priority == widget.selectedPriority,
            )),
          ],
        ),
      ),
    );
  }

  String _getStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendente';
      case TaskStatus.inProgress:
        return 'Em Progresso';
      case TaskStatus.completed:
        return 'Concluída';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
