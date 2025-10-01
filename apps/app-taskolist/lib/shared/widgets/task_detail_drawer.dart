import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_providers.dart';
import 'notes_expansion_dialog.dart';
import 'subtask_list_widget.dart';
import 'task_comments_section.dart';
import 'task_details_card.dart';
import 'task_header_card.dart';

class TaskDetailDrawer extends ConsumerStatefulWidget {
  final TaskEntity task;
  final VoidCallback onClose;

  const TaskDetailDrawer({
    super.key,
    required this.task,
    required this.onClose,
  });

  @override
  ConsumerState<TaskDetailDrawer> createState() => _TaskDetailDrawerState();
}

class _TaskDetailDrawerState extends ConsumerState<TaskDetailDrawer> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  late bool _isStarred;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _selectedStatus = widget.task.status;
    _selectedPriority = widget.task.priority;
    _isStarred = widget.task.isStarred;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título não pode estar vazio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        isStarred: _isStarred,
        updatedAt: DateTime.now(),
      );

      await ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar tarefa: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      try {
        await ref.read(taskNotifierProvider.notifier).deleteTask(widget.task.id);
        
        if (mounted) {
          widget.onClose(); // Fechar o drawer
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa excluída com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir tarefa: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _openNotesDialog() {
    showDialog<dynamic>(
      context: context,
      builder: (context) => NotesExpansionDialog(
        initialNotes: _notesController.text,
        onSave: (notes) {
          setState(() {
            _notesController.text = notes ?? '';
          });
        },
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      // Atualizar a data de vencimento da tarefa
      final updatedTask = widget.task.copyWith(
        dueDate: date,
        updatedAt: DateTime.now(),
      );
      
      await ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📅 Data de vencimento atualizada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? 'Editar Tarefa' : 'Detalhes da Tarefa',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isEditing) ...[ 
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: _isLoading ? null : _deleteTask,
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _isEditing = false),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: _isLoading ? null : _saveChanges,
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      // Header Card
                      SliverToBoxAdapter(
                        child: TaskHeaderCard(
                          task: widget.task,
                          isEditing: _isEditing,
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                        ),
                      ),
                      
                      // Details Card
                      SliverToBoxAdapter(
                        child: TaskDetailsCard(
                          task: widget.task,
                          isEditing: _isEditing,
                          selectedStatus: _selectedStatus,
                          selectedPriority: _selectedPriority,
                          onStatusChanged: (status) {
                            setState(() => _selectedStatus = status);
                          },
                          onPriorityChanged: (priority) {
                            setState(() => _selectedPriority = priority);
                          },
                          onDateTap: _showDatePicker,
                        ),
                      ),
                      
                      // Anotações Card
                      SliverToBoxAdapter(
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Anotações',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (_isEditing)
                                      IconButton(
                                        icon: const Icon(Icons.open_in_full),
                                        onPressed: _openNotesDialog,
                                        tooltip: 'Expandir editor',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _notesController,
                                  enabled: _isEditing,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: 'Digite suas anotações aqui...',
                                    border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
                                    filled: !_isEditing,
                                    fillColor: Colors.grey[100],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Subtarefas Card
                      SliverToBoxAdapter(
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Subtarefas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SubtaskListWidget(parentTaskId: widget.task.id),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Comentários Section
                      SliverToBoxAdapter(
                        child: TaskCommentsSection(taskId: widget.task.id),
                      ),
                      
                      // Bottom spacing
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

}