import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';

class BottomInputBar extends ConsumerStatefulWidget {
  const BottomInputBar({super.key});

  @override
  ConsumerState<BottomInputBar> createState() => _BottomInputBarState();
}

class _BottomInputBarState extends ConsumerState<BottomInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isExpanded = _focusNode.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  Future<void> _createTask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    try {
      final newTask = TaskEntity(
        id: const Uuid().v4(),
        title: title,
        listId: 'default',
        createdById: 'user1', // TODO: Pegar do auth atual
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
      );

      await ref.read(taskNotifierProvider.notifier).createTask(newTask);
      
      _controller.clear();
      _focusNode.unfocus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa criada com sucesso!'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar tarefa: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: _isExpanded 
          ? const BorderRadius.vertical(top: Radius.circular(16))
          : null,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Ícone de adicionar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Campo de entrada
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Adicionar nova tarefa...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primaryColor),
                        onPressed: _createTask,
                      )
                    : null,
                ),
                onSubmitted: (_) => _createTask(),
                onChanged: (value) {
                  setState(() {}); // Para atualizar o suffixIcon
                },
                textInputAction: TextInputAction.send,
                maxLines: _isExpanded ? 3 : 1,
              ),
            ),
            
            // Botões de ação (quando expandido)
            if (_isExpanded) ...[
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.flag_outlined,
                color: AppColors.mediumPriority,
                onTap: () => _showPrioritySelector(),
              ),
              const SizedBox(width: 4),
              _buildActionButton(
                icon: Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
                onTap: () => _showDatePicker(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }

  void _showPrioritySelector() {
    showModalBottomSheet(
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
                Navigator.pop(context);
                // TODO: Implementar seleção de prioridade
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      // TODO: Implementar seleção de data
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
}