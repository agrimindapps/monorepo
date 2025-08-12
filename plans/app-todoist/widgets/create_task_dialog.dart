// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../constants/timeout_constants.dart';
import '../models/task_model.dart';

class CreateTaskDialog extends StatefulWidget {
  final String listId;
  final String userId;
  final Task? editingTask;

  const CreateTaskDialog({
    super.key,
    required this.listId,
    required this.userId,
    this.editingTask,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _selectedReminderDate;
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _isStarred = false;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editingTask != null) {
      _populateFormWithTask(widget.editingTask!);
    }
  }

  void _populateFormWithTask(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedDate = task.dueDate;
    _selectedReminderDate = task.reminderDate;
    _selectedPriority = task.priority;
    _isStarred = task.isStarred;
    _tags.addAll(task.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header estilo Wunderlist
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF3A5998),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.editingTask != null
                          ? 'Editar Tarefa'
                          : 'Nova Tarefa',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildQuickOptions(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        hintText: 'Título da tarefa',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: Color(0xFFE1E1E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: Color(0xFFE1E1E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: Color(0xFF3A5998)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, insira um título';
        }
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 2,
      decoration: const InputDecoration(
        hintText: 'Adicionar nota (opcional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: Color(0xFFE1E1E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: Color(0xFFE1E1E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: Color(0xFF3A5998)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildQuickOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionButton(
            icon: _selectedDate != null
                ? Icons.calendar_today
                : Icons.calendar_today_outlined,
            label: _selectedDate != null
                ? DateFormat('dd/MM').format(_selectedDate!)
                : 'Data',
            isActive: _selectedDate != null,
            onTap: () => _selectDate(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOptionButton(
            icon: _isStarred ? Icons.star : Icons.star_outline,
            label: 'Favorita',
            isActive: _isStarred,
            onTap: () {
              setState(() {
                _isStarred = !_isStarred;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        _buildPriorityButton(),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? const Color(0xFF3A5998) : const Color(0xFFE1E1E1),
          ),
          borderRadius: BorderRadius.circular(6),
          color: isActive
              ? const Color(0xFF3A5998).withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF3A5998) : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? const Color(0xFF3A5998) : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton() {
    final priorityColors = {
      TaskPriority.urgent: Colors.red,
      TaskPriority.high: Colors.orange,
      TaskPriority.medium: Colors.yellow[700],
      TaskPriority.low: Colors.green,
    };

    final priorityLabels = {
      TaskPriority.urgent: 'Urgente',
      TaskPriority.high: 'Alta',
      TaskPriority.medium: 'Média',
      TaskPriority.low: 'Baixa',
    };

    return InkWell(
      onTap: () => _showPriorityPicker(),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE1E1E1)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: priorityColors[_selectedPriority],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              priorityLabels[_selectedPriority]!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de Vencimento',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
              : 'Selecionar data',
        ),
      ),
    );
  }

  Widget _buildReminderPicker() {
    return InkWell(
      onTap: () => _selectReminderDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Lembrete',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.alarm),
        ),
        child: Text(
          _selectedReminderDate != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedReminderDate!)
              : 'Selecionar lembrete',
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prioridade:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TaskPriority.values.map((priority) {
            return ChoiceChip(
              label: Text(_getPriorityLabel(priority)),
              selected: _selectedPriority == priority,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                }
              },
              backgroundColor:
                  _getPriorityColor(priority).withValues(alpha: 0.1),
              selectedColor: _getPriorityColor(priority).withValues(alpha: 0.3),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStarredToggle() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 8),
        const Text('Marcar como favorita'),
        const Spacer(),
        Switch(
          value: _isStarred,
          onChanged: (value) {
            setState(() {
              _isStarred = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Adicionar tag',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A5998),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            child: Text(
              widget.editingTask != null ? 'Atualizar' : 'Criar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPriorityPicker() {
    const priorities = [
      TaskPriority.low,
      TaskPriority.medium,
      TaskPriority.high,
      TaskPriority.urgent,
    ];

    final priorityColors = {
      TaskPriority.urgent: Colors.red,
      TaskPriority.high: Colors.orange,
      TaskPriority.medium: Colors.yellow[700],
      TaskPriority.low: Colors.green,
    };

    final priorityLabels = {
      TaskPriority.urgent: 'Urgente',
      TaskPriority.high: 'Alta',
      TaskPriority.medium: 'Média',
      TaskPriority.low: 'Baixa',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prioridade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: priorities.map((priority) {
            return ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: priorityColors[priority],
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(priorityLabels[priority]!),
              onTap: () {
                setState(() {
                  _selectedPriority = priority;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
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
    }
  }

  Future<void> _selectReminderDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(TimeoutConstants.oneYear),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedReminderDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedReminderDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;
      final task = Task(
        id: widget.editingTask?.id ?? 'task_$nowMs',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        listId: widget.listId,
        createdById: widget.userId,
        createdAt: widget.editingTask?.createdAt ?? nowMs,
        updatedAt: nowMs,
        dueDate: _selectedDate,
        reminderDate: _selectedReminderDate,
        isStarred: _isStarred,
        priority: _selectedPriority,
        tags: _tags,
      );

      Navigator.of(context).pop(task);
    }
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
        return Colors.yellow;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}
