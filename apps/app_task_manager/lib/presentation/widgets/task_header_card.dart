import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';

class TaskHeaderCard extends ConsumerStatefulWidget {
  final TaskEntity task;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const TaskHeaderCard({
    super.key,
    required this.task,
    required this.isEditing,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  ConsumerState<TaskHeaderCard> createState() => _TaskHeaderCardState();
}

class _TaskHeaderCardState extends ConsumerState<TaskHeaderCard> {
  Future<void> _toggleCompleted() async {
    final updatedTask = widget.task.copyWith(
      status: widget.task.status == TaskStatus.completed 
        ? TaskStatus.pending 
        : TaskStatus.completed,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedTask.status == TaskStatus.completed 
                ? 'Tarefa concluída!' 
                : 'Tarefa reaberta!'
            ),
            backgroundColor: updatedTask.status == TaskStatus.completed 
              ? AppColors.success 
              : AppColors.info,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar tarefa: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleStarred() async {
    final updatedTask = widget.task.copyWith(
      isStarred: !widget.task.isStarred,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar favorito: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.completed;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com checkbox e star
            Row(
              children: [
                // Checkbox para marcar como concluída
                GestureDetector(
                  onTap: _toggleCompleted,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? AppColors.success : AppColors.border,
                        width: 2,
                      ),
                      color: isCompleted ? AppColors.success : Colors.transparent,
                    ),
                    child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Indicador de prioridade
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.getPriorityColor(widget.task.priority.name),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Título
                Expanded(
                  child: widget.isEditing
                    ? TextField(
                        controller: widget.titleController,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        maxLines: 2,
                      )
                    : Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                
                // Botão de favoritar
                GestureDetector(
                  onTap: _toggleStarred,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      widget.task.isStarred ? Icons.star : Icons.star_border,
                      color: widget.task.isStarred 
                        ? AppColors.starredYellow 
                        : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            // Descrição (se houver)
            if (widget.task.description != null || widget.isEditing) ...[
              const SizedBox(height: 12),
              if (widget.isEditing)
                TextField(
                  controller: widget.descriptionController,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Adicionar descrição...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  maxLines: 3,
                )
              else if (widget.task.description != null)
                Text(
                  widget.task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? AppColors.textSecondary : AppColors.textSecondary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
            
            // Tags (se houver)
            if (widget.task.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.task.tags.map((tag) => Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: AppColors.primaryColor.withAlpha(26),
                  side: BorderSide(
                    color: AppColors.primaryColor.withAlpha(77),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}