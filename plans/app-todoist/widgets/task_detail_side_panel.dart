// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../constants/timeout_constants.dart';
import '../dependency_injection.dart';
import '../models/task_model.dart';

class TaskDetailSidePanel extends StatefulWidget {
  final Task task;

  const TaskDetailSidePanel({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailSidePanel> createState() => _TaskDetailSidePanelState();
}

class _TaskDetailSidePanelState extends State<TaskDetailSidePanel> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? _selectedDate;
  late TaskPriority _selectedPriority;
  late bool _isStarred;
  late List<String> _tags;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description ?? '');
    _selectedDate = widget.task.dueDate;
    _selectedPriority = widget.task.priority;
    _isStarred = widget.task.isStarred;
    _tags = List.from(widget.task.tags);

    // Adicionar listeners para auto-save
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);

    // RealtimeController gerencia automaticamente as subtarefas
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TimeoutConstants.debounceDelay, () {
      _autoSave();
    });
  }

  void _onDescriptionChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TimeoutConstants.debounceDelay, () {
      _autoSave();
    });
  }

  void _autoSave() async {
    if (!mounted) return;

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _selectedDate,
      priority: _selectedPriority,
      isStarred: _isStarred,
      tags: _tags,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await DependencyContainer.instance.taskController.updateTask(updatedTask.id, updatedTask);
    } catch (e) {
      // Silentemente ignorar erros de auto-save para não interromper a UX
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // SafeArea no topo
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE1E1E1), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detalhes da Tarefa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 24),
                  _buildOptionsSection(),
                  // Mostrar subtarefas apenas se não for uma subtarefa (evitar nesting infinito)
                  if (!widget.task.isSubtask) ...[
                    const SizedBox(height: 24),
                    _buildSubtasksSection(),
                  ],
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  _buildAttachmentsSection(),
                  const SizedBox(height: 24),
                  _buildDeleteButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Título',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFE1E1E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFE1E1E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF3A5998)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Adicionar descrição...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFE1E1E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFE1E1E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF3A5998)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opções',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),

        // Container agrupando todas as opções
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E1E1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Data de vencimento
              _buildOptionTile(
                icon: Icons.calendar_today_outlined,
                title: 'Data de vencimento',
                subtitle: _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : 'Nenhuma data definida',
                onTap: () => _selectDate(),
                isFirst: true,
              ),

              // Divider
              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE1E1E1),
                indent: 40,
              ),

              // Prioridade
              _buildOptionTile(
                icon: Icons.flag_outlined,
                title: 'Prioridade',
                subtitle: _getPriorityLabel(_selectedPriority),
                trailing: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_selectedPriority),
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => _selectPriority(),
              ),

              // Divider
              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE1E1E1),
                indent: 40,
              ),

              // Favorita
              _buildOptionTile(
                icon: _isStarred ? Icons.star : Icons.star_outline,
                title: 'Favorita',
                subtitle: _isStarred ? 'Sim' : 'Não',
                onTap: () {
                  setState(() {
                    _isStarred = !_isStarred;
                  });
                  _autoSave();
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF666666),
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF999999),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtasksSection() {
    return StreamBuilder<List<Task>>(
      stream: DependencyContainer.instance.taskRepository.tasksStream
          .map((tasks) => tasks.where((task) => task.parentTaskId == widget.task.id).toList()),
      builder: (context, snapshot) {
        return _buildSubtasksContent(snapshot.data ?? []);
      },
    );
  }

  Widget _buildSubtasksContent(List<Task> subtasks) {
    final completedCount = subtasks.where((task) => task.isCompleted).length;
    final totalCount = subtasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Subtarefas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const Spacer(),
            if (totalCount > 0)
              Text(
                '$completedCount de $totalCount',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Campo para adicionar nova subtarefa
        _buildAddSubtaskField(),

        if (subtasks.isNotEmpty) ...[
          const SizedBox(height: 6),
          // Lista de subtarefas
          ...subtasks.map((subtask) => _buildSubtaskItem(subtask)),
        ],
      ],
    );
  }

  Widget _buildAddSubtaskField() {
    final subtaskController = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E1E1)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFCCCCCC),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 8,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: subtaskController,
              decoration: const InputDecoration(
                hintText: 'Adicionar subtarefa',
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2C2C2C),
              ),
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  try {
                    final now = DateTime.now();
                    final subtask = widget.task.copyWith(
                      id: 'subtask_${now.millisecondsSinceEpoch}',
                      title: value.trim(),
                      parentTaskId: widget.task.id,
                      createdAt: now.millisecondsSinceEpoch,
                      updatedAt: now.millisecondsSinceEpoch,
                      isCompleted: false,
                    );
                    final success = await DependencyContainer
                        .instance.taskController
                        .createTask(subtask);
                    if (success) {
                      subtaskController.clear();
                    }
                  } catch (e) {}
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(Task subtask) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              DependencyContainer.instance.taskController
                  .toggleTaskComplete(subtask.id);
            },
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: subtask.isCompleted
                      ? const Color(0xFF3A5998)
                      : const Color(0xFFCCCCCC),
                  width: 1,
                ),
                color: subtask.isCompleted
                    ? const Color(0xFF3A5998)
                    : Colors.transparent,
              ),
              child: subtask.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 8,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 13,
                color: subtask.isCompleted
                    ? const Color(0xFF999999)
                    : const Color(0xFF2C2C2C),
                decoration:
                    subtask.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excluir subtarefa'),
                  content: Text(
                      'Tem certeza que deseja excluir "${subtask.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                DependencyContainer.instance.taskController
                    .deleteTask(subtask.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.delete_outline,
                size: 14,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(TimeoutConstants.oneYear),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _autoSave();
    }
  }

  void _selectPriority() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prioridade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskPriority.values.map((priority) {
            return ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(_getPriorityLabel(priority)),
              onTap: () {
                setState(() {
                  _selectedPriority = priority;
                });
                Navigator.of(context).pop();
                _autoSave();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgente';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.low:
        return 'Baixa';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.yellow[700]!;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arquivos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 12),

        // Área reservada para futuros anexos
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE1E1E1),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF9F9F9),
          ),
          child: Column(
            children: [
              Icon(
                Icons.attach_file_outlined,
                size: 32,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Adicionar arquivos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Em breve',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _deleteTask,
        icon: const Icon(
          Icons.delete_outline,
          size: 18,
        ),
        label: const Text(
          'Excluir Tarefa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.red[200]!, width: 1),
          ),
        ),
      ),
    );
  }

  void _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Tem certeza que deseja excluir a tarefa "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DependencyContainer.instance.taskController
            .deleteTask(widget.task.id);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa excluída com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
